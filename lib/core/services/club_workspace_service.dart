import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/club_event.dart';
import '../models/club_role.dart';
import '../models/club_task.dart';
import '../models/collaboration.dart';
import '../models/department.dart';
import '../models/member_profile.dart';
import 'ai_event_architect.dart';
import 'seed_workspace.dart';

/// ---------------------------------------------------------------------------
/// CLUB WORKSPACE
///
/// Single source of truth for the whole app. Three things changed here from the
/// original in-memory prototype:
///
///  1. **There is a person.** [currentMember] is who is signed in on this
///     device. Every derived list below is computed for that person, which is
///     what makes one member's home screen genuinely different from another's.
///  2. **State survives.** The workspace is serialised to device storage on
///     every mutation, so closing the app (or refreshing the web build) no
///     longer wipes the club's work.
///  3. **Noise is graded.** Mutations emit typed [ActivityEvent]s carrying a
///     severity. Only the ones that clear the bar reach [latestAlert].
/// ---------------------------------------------------------------------------

class ClubWorkspaceService extends ChangeNotifier {
  ClubWorkspaceService() {
    final seed = SeedWorkspace.build();
    _events = List.of(seed.events);
    _tasks = List.of(seed.tasks);
    _members = List.of(seed.members);
    _handoffs = List.of(seed.handoffs);
    _messages = List.of(seed.messages);
    _activity = List.of(seed.activity);
    _currentMember = _members.where((m) => m.role == ClubRole.president).firstOrNull ??
        _members.firstOrNull;
  }

  static const _storageKey = 'gwd_club_os_workspace_v2';
  static const _sessionKey = 'gwd_club_os_session_v2';

  late List<ClubEvent> _events;
  late List<ClubTask> _tasks;
  late List<MemberProfile> _members;
  late List<Handoff> _handoffs;
  late List<CollabMessage> _messages;
  late List<ActivityEvent> _activity;

  MemberProfile? _currentMember;
  ActivityEvent? _latestAlert;
  bool _restored = false;
  Timer? _saveDebounce;

  // --- Identity -----------------------------------------------------------

  /// The person using this device. Null until someone signs in.
  MemberProfile? get currentMember => _currentMember;

  bool get isSignedIn => _currentMember != null;

  /// Whose lens the app is rendered through. Falls back to a plain member view
  /// so nothing can accidentally render an executive surface while signed out.
  ClubRole get activeRole => _currentMember?.role ?? ClubRole.clubMember;

  String? get currentMemberId => _currentMember?.id;

  void signInAs(String memberId) {
    final member = _members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return;
    _currentMember = member;
    _record(
      kind: ActivityKind.sessionChanged,
      title: 'Signed in',
      body: '${member.name} opened ${member.role.title}.',
      actor: member,
    );
    _persistSession();
    _persist();
    notifyListeners();
  }

  void signOut() {
    _currentMember = null;
    _latestAlert = null;
    _persistSession();
    notifyListeners();
  }

  /// Kept so the existing role simulator (executives previewing another desk)
  /// keeps working. It swaps to the canonical member holding that role.
  void switchRole(ClubRole newRole) {
    final member = _members.where((m) => m.role == newRole).firstOrNull;
    if (member != null) {
      signInAs(member.id);
      return;
    }
    _currentMember = _currentMember?.copyWith(role: newRole);
    notifyListeners();
  }

  // --- Collections --------------------------------------------------------

  List<ClubEvent> get events => List.unmodifiable(_events);
  List<ClubTask> get tasks => List.unmodifiable(_tasks);
  List<MemberProfile> get members => List.unmodifiable(_members);
  List<Handoff> get handoffs => List.unmodifiable(_handoffs);
  List<ActivityEvent> get activity => List.unmodifiable(_activity);

  /// Plain-text feed retained for the older widgets that render strings.
  List<String> get notifications =>
      _activity.map((e) => e.body).toList(growable: false);

  ClubEvent? get flagshipEvent =>
      _events.where((e) => e.isFlagship).firstOrNull ?? _events.firstOrNull;

  ClubEvent? eventById(String? id) =>
      id == null ? null : _events.where((e) => e.id == id).firstOrNull;

  MemberProfile? memberById(String? id) =>
      id == null ? null : _members.where((m) => m.id == id).firstOrNull;

  MemberProfile? memberByName(String name) =>
      _members.where((m) => m.name == name).firstOrNull;

  /// Everyone who sits in a department, lead first.
  List<MemberProfile> membersOf(DepartmentType department) {
    final list = _members.where((m) => m.department == department).toList();
    list.sort((a, b) {
      final aLead = a.role == department.leadRole ? 0 : 1;
      final bLead = b.role == department.leadRole ? 0 : 1;
      if (aLead != bLead) return aLead.compareTo(bLead);
      return b.totalVerifiedPoints.compareTo(a.totalVerifiedPoints);
    });
    return list;
  }

  // --- Alerts -------------------------------------------------------------

  /// The one event currently allowed to take over the Dynamic Island.
  ActivityEvent? get latestAlert => _latestAlert;

  void dismissAlert() {
    _latestAlert = null;
    notifyListeners();
  }

  int get unreadActivityCount => _activity.where((e) => !e.read).length;

  void markActivityRead() {
    if (_activity.every((e) => e.read)) return;
    _activity = _activity.map((e) => e.copyWith(read: true)).toList();
    _persist();
    notifyListeners();
  }

  /// Feed entries relevant to a member: club-wide events plus anything
  /// addressed to them or touching their department.
  List<ActivityEvent> activityFor(MemberProfile? member) {
    if (member == null) return activity;
    return _activity.where((e) {
      if (e.targetMemberIds.contains(member.id)) return true;
      if (e.actorId == member.id) return true;
      if (e.department != null && e.department == member.department) return true;
      return e.severity != ActivitySeverity.ambient;
    }).toList();
  }

  // --- Task views for the signed-in person --------------------------------

  /// Work this person personally owns.
  List<ClubTask> get myTasks {
    final me = _currentMember;
    if (me == null) return const [];
    return _tasks
        .where((t) => t.assigneeName == me.name || t.assigneeRole == me.role)
        .toList();
  }

  /// The single most important list in the app: everything waiting on this
  /// person right now, ordered by how much it is holding others up.
  List<ClubTask> get myInbox {
    final me = _currentMember;
    if (me == null) return const [];

    final items = _tasks.where((t) {
      final mine = t.assigneeName == me.name || t.assigneeRole == me.role;
      // Something I own that has not been handed in yet.
      if (mine &&
          (t.status == TaskStatus.requested ||
              t.status == TaskStatus.inProgress ||
              t.status == TaskStatus.committed ||
              t.status == TaskStatus.blocked)) {
        return true;
      }
      // Something handed in that I am the one who has to verify.
      if (t.status == TaskStatus.submitted && canVerify(t, me)) return true;
      return false;
    }).toList();

    items.sort((a, b) {
      final aRank = _inboxRank(a);
      final bRank = _inboxRank(b);
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.dueDate.compareTo(b.dueDate);
    });
    return items;
  }

  int _inboxRank(ClubTask task) => switch (task.status) {
        TaskStatus.blocked => 0,
        TaskStatus.submitted => 1,
        TaskStatus.requested => 2,
        TaskStatus.inProgress => 3,
        TaskStatus.committed => 4,
        TaskStatus.verified => 5,
      };

  /// Whether [member] is allowed to sign off [task].
  bool canVerify(ClubTask task, MemberProfile? member) {
    if (member == null) return false;
    if (member.role.isExecutive) return true;
    if (!member.role.canVerifyTasks) return false;
    return task.department == member.department;
  }

  List<ClubTask> get tasksForActiveRole {
    final me = _currentMember;
    if (me == null) return tasks;
    if (me.role.isExecutive) return tasks;
    return _tasks
        .where((t) =>
            t.department == me.department ||
            t.assigneeName == me.name ||
            t.assigneeRole == me.role)
        .toList();
  }

  List<ClubTask> get pendingVerificationsForActiveRole {
    final me = _currentMember;
    return _tasks
        .where((t) => t.status == TaskStatus.submitted && canVerify(t, me))
        .toList();
  }

  List<ClubTask> get blockedTasks =>
      _tasks.where((t) => t.status == TaskStatus.blocked).toList();

  /// Work my department is holding up for somebody else. This is the number a
  /// lead should feel responsible for.
  List<ClubTask> get tasksMyDepartmentIsBlocking {
    final me = _currentMember;
    if (me == null) return const [];
    return _tasks
        .where((t) =>
            t.status == TaskStatus.blocked &&
            t.blockedByDepartment == me.department)
        .toList();
  }

  // --- Scores -------------------------------------------------------------

  int get totalVerifiedPoints => _tasks
      .where((t) => t.status == TaskStatus.verified)
      .fold(0, (sum, t) => sum + t.points);

  int get totalCommittedPoints => _tasks
      .where((t) => t.status != TaskStatus.requested)
      .fold(0, (sum, t) => sum + t.points);

  int getDepartmentVerifiedPoints(DepartmentType department) => _tasks
      .where((t) => t.department == department && t.status == TaskStatus.verified)
      .fold(0, (sum, t) => sum + t.points);

  int getDepartmentTotalPoints(DepartmentType department) => _tasks
      .where((t) => t.department == department)
      .fold(0, (sum, t) => sum + t.points);

  /// Share of a department's committed work that has been signed off, 0..1.
  double departmentProgress(DepartmentType department) {
    final total = getDepartmentTotalPoints(department);
    if (total == 0) return 0;
    return getDepartmentVerifiedPoints(department) / total;
  }

  /// Club-wide delivery rate, 0..1.
  double get clubProgress {
    if (_tasks.isEmpty) return 0;
    final verified = _tasks.where((t) => t.status == TaskStatus.verified).length;
    return verified / _tasks.length;
  }

  // --- Threads ------------------------------------------------------------

  List<CollabMessage> messagesFor(String taskId) {
    final list = _messages.where((m) => m.taskId == taskId).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  int messageCountFor(String taskId) =>
      _messages.where((m) => m.taskId == taskId).length;

  /// Posts to a deliverable's thread. Names written as @First are resolved to
  /// members and notified personally.
  void postMessage(String taskId, String body, {bool isDecision = false}) {
    final me = _currentMember;
    if (me == null || body.trim().isEmpty) return;

    final mentioned = _resolveMentions(body);
    final message = CollabMessage(
      id: _newId('msg'),
      taskId: taskId,
      authorId: me.id,
      authorName: me.name,
      authorRole: me.role,
      body: body.trim(),
      createdAt: DateTime.now(),
      mentions: mentioned.map((m) => m.id).toList(),
      isDecision: isDecision,
    );
    _messages = [..._messages, message];

    final task = _tasks.where((t) => t.id == taskId).firstOrNull;
    final owner = task == null ? null : memberByName(task.assigneeName);
    final targets = <String>{
      ...mentioned.map((m) => m.id),
      if (owner != null && owner.id != me.id) owner.id,
    }.toList();

    _record(
      kind: mentioned.isEmpty ? ActivityKind.comment : ActivityKind.mention,
      title: mentioned.isEmpty ? 'New comment' : 'You were mentioned',
      body: '${me.name}: ${body.trim()}',
      actor: me,
      targetMemberIds: targets,
      taskId: taskId,
      department: task?.department,
    );
    _persist();
    notifyListeners();
  }

  List<MemberProfile> _resolveMentions(String body) {
    final matches = RegExp(r'@([A-Za-z][A-Za-z.\-]*)').allMatches(body);
    final found = <MemberProfile>{};
    for (final match in matches) {
      final handle = match.group(1)!.toLowerCase();
      for (final member in _members) {
        final first = member.name.split(' ').first.toLowerCase();
        if (first == handle) found.add(member);
      }
    }
    return found.toList();
  }

  // --- Handoffs -----------------------------------------------------------

  List<Handoff> get openHandoffs => _handoffs.where((h) => h.isOpen).toList();

  /// Handoffs this person is expected to act on — requests pointed at their
  /// department that nobody has answered yet.
  List<Handoff> get handoffsAwaitingMe {
    final me = _currentMember;
    if (me == null) return const [];
    return _handoffs
        .where((h) =>
            h.status == HandoffStatus.requested && h.toDepartment == me.department)
        .toList();
  }

  /// Handoffs this person raised and is still waiting on.
  List<Handoff> get handoffsIAmWaitingOn {
    final me = _currentMember;
    if (me == null) return const [];
    return _handoffs
        .where((h) => h.isOpen && h.requestedById == me.id)
        .toList();
  }

  List<Handoff> handoffsForDepartment(DepartmentType department) => _handoffs
      .where((h) =>
          h.toDepartment == department || h.fromDepartment == department)
      .toList();

  void requestHandoff({
    required String title,
    required String need,
    required DepartmentType toDepartment,
    required DateTime neededBy,
    String? taskId,
  }) {
    final me = _currentMember;
    if (me == null) return;

    final handoff = Handoff(
      id: _newId('ho'),
      title: title,
      need: need,
      fromDepartment: me.department,
      toDepartment: toDepartment,
      requestedById: me.id,
      requestedByName: me.name,
      createdAt: DateTime.now(),
      neededBy: neededBy,
      taskId: taskId,
    );
    _handoffs = [handoff, ..._handoffs];

    _record(
      kind: ActivityKind.handoffRequested,
      title: 'Handoff requested',
      body:
          '${me.department.shortName} needs "$title" from ${toDepartment.shortName} by ${_shortDate(neededBy)}.',
      actor: me,
      targetMemberIds: membersOf(toDepartment).map((m) => m.id).toList(),
      department: toDepartment,
      handoffId: handoff.id,
      taskId: taskId,
    );
    _persist();
    notifyListeners();
  }

  void respondToHandoff(String handoffId, HandoffStatus status, {String? note}) {
    final index = _handoffs.indexWhere((h) => h.id == handoffId);
    if (index == -1) return;
    final me = _currentMember;
    final handoff = _handoffs[index];

    _handoffs[index] = handoff.copyWith(
      status: status,
      respondedById: me?.id,
      respondedByName: me?.name,
      respondedAt: DateTime.now(),
      responseNote: note,
    );
    _handoffs = List.of(_handoffs);

    final kind = switch (status) {
      HandoffStatus.accepted => ActivityKind.handoffAccepted,
      HandoffStatus.delivered => ActivityKind.handoffDelivered,
      HandoffStatus.declined => ActivityKind.handoffDeclined,
      HandoffStatus.requested => ActivityKind.handoffRequested,
    };

    _record(
      kind: kind,
      title: 'Handoff ${status.name}',
      body:
          '${me?.name ?? handoff.toDepartment.shortName} marked "${handoff.title}" as ${status.label.toLowerCase()}.',
      actor: me,
      targetMemberIds: [handoff.requestedById],
      department: handoff.fromDepartment,
      handoffId: handoff.id,
      taskId: handoff.taskId,
    );
    _persist();
    notifyListeners();
  }

  // --- Task lifecycle -----------------------------------------------------

  void addEvent(ClubEvent event) {
    _events = [event, ..._events];
    _record(
      kind: ActivityKind.eventCreated,
      title: 'Event created',
      body: '${event.title} is on the calendar for ${event.formattedDate}.',
      actor: _currentMember,
    );
    _persist();
    notifyListeners();
  }

  void addTask(ClubTask task) {
    _tasks = [task, ..._tasks];
    final owner = memberByName(task.assigneeName);
    _record(
      kind: ActivityKind.taskAssigned,
      title: 'New assignment',
      body: '"${task.title}" went to ${task.assigneeName}.',
      actor: _currentMember,
      targetMemberIds: [if (owner != null) owner.id],
      taskId: task.id,
      department: task.department,
    );
    _persist();
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    _tasks[index] = task.copyWith(status: newStatus);
    _tasks = List.of(_tasks);

    if (newStatus == TaskStatus.committed) {
      _record(
        kind: ActivityKind.taskAccepted,
        title: 'Commitment made',
        body: '${task.assigneeName} accepted "${task.title}".',
        actor: _currentMember,
        taskId: taskId,
        department: task.department,
      );
    }
    _persist();
    notifyListeners();
  }

  void submitProof(String taskId, String proof) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.submitted,
      proof: proof,
      blocker: null,
      blockedByDepartment: null,
    );
    _tasks = List.of(_tasks);
    final task = _tasks[index];

    // Whoever has to sign this off is the one who needs to know.
    final verifiers = _members
        .where((m) => canVerify(task, m))
        .map((m) => m.id)
        .toList();

    _record(
      kind: ActivityKind.proofSubmitted,
      title: 'Proof submitted',
      body: '"${task.title}" is ready for sign-off.',
      actor: _currentMember,
      targetMemberIds: verifiers,
      taskId: taskId,
      department: task.department,
    );
    _persist();
    notifyListeners();
  }

  void verifyTask(String taskId, ClubRole verifierRole, String verifierName) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    _tasks[index] = task.copyWith(
      status: TaskStatus.verified,
      verifiedByRole: verifierRole,
      verifiedByName: verifierName,
    );
    _tasks = List.of(_tasks);
    _awardPoints(task.assigneeName, task.points, task.corporateValueSkill);

    final owner = memberByName(task.assigneeName);
    _record(
      kind: ActivityKind.taskVerified,
      title: 'Outcome verified',
      body:
          '"${task.title}" signed off by $verifierName · +${task.points} XP to ${task.assigneeName}.',
      actor: _currentMember,
      targetMemberIds: [if (owner != null) owner.id],
      taskId: taskId,
      department: task.department,
    );
    _persist();
    notifyListeners();
  }

  void reportBlocker(
      String taskId, String blockerReason, DepartmentType? blockedBy) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.blocked,
      blocker: blockerReason,
      blockedByDepartment: blockedBy,
    );
    _tasks = List.of(_tasks);
    final task = _tasks[index];

    _record(
      kind: ActivityKind.blockerRaised,
      title: 'Blocker raised',
      body: blockedBy == null
          ? '"${task.title}" is blocked: $blockerReason'
          : '${blockedBy.shortName} is blocking "${task.title}": $blockerReason',
      actor: _currentMember,
      targetMemberIds:
          blockedBy == null ? const [] : membersOf(blockedBy).map((m) => m.id).toList(),
      taskId: taskId,
      department: blockedBy ?? task.department,
    );
    _persist();
    notifyListeners();
  }

  void resolveBlocker(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final wasBlockedBy = _tasks[index].blockedByDepartment;
    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.inProgress,
      blocker: null,
      blockedByDepartment: null,
    );
    _tasks = List.of(_tasks);
    final task = _tasks[index];
    final owner = memberByName(task.assigneeName);

    _record(
      kind: ActivityKind.blockerCleared,
      title: 'Blocker cleared',
      body: '"${task.title}" is moving again.',
      actor: _currentMember,
      targetMemberIds: [if (owner != null) owner.id],
      taskId: taskId,
      department: wasBlockedBy ?? task.department,
    );
    _persist();
    notifyListeners();
  }

  void nudgeDepartment(DepartmentType department, String reason) {
    _record(
      kind: ActivityKind.nudge,
      title: 'Nudge sent',
      body: '${department.shortName}: $reason',
      actor: _currentMember,
      targetMemberIds: membersOf(department).map((m) => m.id).toList(),
      department: department,
    );
    _persist();
    notifyListeners();
  }

  void generateAiEvent({
    required String title,
    required String themeTagline,
    required EventCategory category,
    required DateTime targetDate,
    required String venue,
    int expectedFootfall = 300,
    String budgetLabel = '₹50,000',
    String? customInstructions,
  }) {
    final blueprint = AiEventArchitectService.generateBlueprint(
      title: title,
      themeTagline: themeTagline,
      category: category,
      targetDate: targetDate,
      venue: venue,
      expectedFootfall: expectedFootfall,
      budgetLabel: budgetLabel,
      customInstructions: customInstructions,
    );

    _events = [blueprint.event, ..._events];
    _tasks = [...blueprint.tasks, ..._tasks];

    _record(
      kind: ActivityKind.eventCreated,
      title: 'Blueprint generated',
      body:
          '"${blueprint.event.title}" created with ${blueprint.tasks.length} department tasks.',
      actor: _currentMember,
    );
    _persist();
    notifyListeners();
  }

  // --- Internals ----------------------------------------------------------

  void _awardPoints(String memberName, int points, String skillTag) {
    final index = _members.indexWhere((m) => m.name == memberName);
    if (index == -1) return;
    final member = _members[index];
    final skills = Map<String, int>.from(member.corporateSkillsEarned);
    skills[skillTag] = (skills[skillTag] ?? 0) + points;

    final updated = member.copyWith(
      totalVerifiedPoints: member.totalVerifiedPoints + points,
      reliabilityRate: (member.reliabilityRate + 0.4).clamp(80.0, 99.9),
      corporateSkillsEarned: skills,
    );

    final mutableMembers = List<MemberProfile>.of(_members);
    mutableMembers[index] = updated;
    _members = mutableMembers;

    if (_currentMember?.id == member.id) {
      _currentMember = updated;
    }
  }

  void _record({
    required ActivityKind kind,
    required String title,
    required String body,
    MemberProfile? actor,
    List<String> targetMemberIds = const [],
    String? taskId,
    String? handoffId,
    DepartmentType? department,
  }) {
    final event = ActivityEvent(
      id: _newId('act'),
      kind: kind,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      actorId: actor?.id,
      actorName: actor?.name,
      targetMemberIds: targetMemberIds,
      taskId: taskId,
      handoffId: handoffId,
      department: department,
    );

    _activity = [event, ..._activity];
    if (_activity.length > 80) {
      _activity = _activity.sublist(0, 80);
    }

    // The noise gate. An event only takes over the Dynamic Island if it is
    // critical to the club, or personally addressed to whoever is signed in.
    // Anything the current user did themselves never interrupts them.
    final selfAuthored = actor != null && actor.id == _currentMember?.id;
    if (!selfAuthored && event.interruptsFor(_currentMemberId)) {
      _latestAlert = event;
    }
  }

  String? get _currentMemberId => _currentMember?.id;

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  static String _shortDate(DateTime date) =>
      '${date.day}/${date.month}';

  // --- Persistence --------------------------------------------------------

  /// Loads the saved workspace. Safe to call once at startup; if nothing has
  /// been saved yet the seeded workspace stays in place.
  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _events = (data['events'] as List)
            .map((e) => ClubEvent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _tasks = (data['tasks'] as List)
            .map((e) => ClubTask.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _members = (data['members'] as List)
            .map((e) =>
                MemberProfile.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _handoffs = (data['handoffs'] as List? ?? const [])
            .map((e) => Handoff.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _messages = (data['messages'] as List? ?? const [])
            .map((e) =>
                CollabMessage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _activity = (data['activity'] as List? ?? const [])
            .map((e) =>
                ActivityEvent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      final sessionId = prefs.getString(_sessionKey);
      if (sessionId != null) {
        _currentMember =
            _members.where((m) => m.id == sessionId).firstOrNull ?? _currentMember;
      }
    } catch (error, stack) {
      // A corrupt snapshot must never stop the app booting — fall back to seed.
      debugPrint('Workspace restore failed, using seed data: $error');
      debugPrintStack(stackTrace: stack);
    }
    _latestAlert = null;
    notifyListeners();
  }

  /// Wipes the saved snapshot and returns to the seeded workspace.
  Future<void> resetWorkspace() async {
    final seed = SeedWorkspace.build();
    _events = List.of(seed.events);
    _tasks = List.of(seed.tasks);
    _members = List.of(seed.members);
    _handoffs = List.of(seed.handoffs);
    _messages = List.of(seed.messages);
    _activity = List.of(seed.activity);
    _currentMember = _members.where((m) => m.role == ClubRole.president).firstOrNull ??
        _members.firstOrNull;
    _latestAlert = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_sessionKey);
    } catch (_) {
      // Storage is best-effort.
    }
    notifyListeners();
  }

  void _persist() {
    // Writes are coalesced: a burst of mutations produces one disk write.
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), _writeSnapshot);
  }

  Future<void> _writeSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'events': _events.map((e) => e.toJson()).toList(),
        'tasks': _tasks.map((e) => e.toJson()).toList(),
        'members': _members.map((e) => e.toJson()).toList(),
        'handoffs': _handoffs.map((e) => e.toJson()).toList(),
        'messages': _messages.map((e) => e.toJson()).toList(),
        'activity': _activity.map((e) => e.toJson()).toList(),
      });
      await prefs.setString(_storageKey, payload);
    } catch (error) {
      debugPrint('Workspace save failed: $error');
    }
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentMember == null) {
        await prefs.remove(_sessionKey);
      } else {
        await prefs.setString(_sessionKey, _currentMember!.id);
      }
    } catch (error) {
      debugPrint('Session save failed: $error');
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
