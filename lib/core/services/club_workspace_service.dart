import 'package:flutter/material.dart';
import '../models/club_event.dart';
import '../models/club_role.dart';
import '../models/club_task.dart';
import '../models/department.dart';
import '../models/member_profile.dart';
import 'ai_event_architect.dart';

class ClubWorkspaceService extends ChangeNotifier {
  ClubWorkspaceService() {
    _bootstrapSeedData();
  }

  ClubRole _activeRole = ClubRole.president;
  ClubRole get activeRole => _activeRole;

  List<ClubEvent> _events = [];
  List<ClubEvent> get events => List.unmodifiable(_events);

  List<ClubTask> _tasks = [];
  List<ClubTask> get tasks => List.unmodifiable(_tasks);

  List<MemberProfile> _members = [];
  List<MemberProfile> get members => List.unmodifiable(_members);

  final List<String> _notifications = [];
  List<String> get notifications => List.unmodifiable(_notifications);

  ClubLiveNotification? _latestAlert;
  ClubLiveNotification? get latestAlert => _latestAlert;

  void dismissAlert() {
    _latestAlert = null;
    notifyListeners();
  }

  void switchRole(ClubRole newRole) {
    if (_activeRole == newRole) return;
    _activeRole = newRole;
    _pushNotification('Switched command profile to ${newRole.title}', title: 'PROFILE SWITCHED', type: 'role');
    notifyListeners();
  }

  List<ClubTask> get tasksForActiveRole {
    return _tasks.where((t) {
      if (_activeRole.isExecutive) return true; // Executive sees all
      if (t.assigneeRole == _activeRole) return true;
      // If active role is a Lead, show all tasks in their department
      if (_activeRole == ClubRole.marketingLead && t.department == DepartmentType.marketing) return true;
      if (_activeRole == ClubRole.prLead && t.department == DepartmentType.publicRelations) return true;
      if (_activeRole == ClubRole.eventManagementLead && t.department == DepartmentType.eventManagement) return true;
      if (_activeRole == ClubRole.creativeLead && t.department == DepartmentType.creative) return true;
      if (_activeRole == ClubRole.productionLead && t.department == DepartmentType.production) return true;
      if (_activeRole == ClubRole.cinematographerLead && t.department == DepartmentType.cinematography) return true;
      return false;
    }).toList();
  }

  List<ClubTask> get pendingVerificationsForActiveRole {
    return _tasks.where((t) {
      if (t.status != TaskStatus.submitted) return false;
      if (_activeRole.isExecutive) return true; // Executives can verify any submission
      if (_activeRole == ClubRole.marketingLead && t.department == DepartmentType.marketing) return true;
      if (_activeRole == ClubRole.prLead && t.department == DepartmentType.publicRelations) return true;
      if (_activeRole == ClubRole.eventManagementLead && t.department == DepartmentType.eventManagement) return true;
      if (_activeRole == ClubRole.creativeLead && t.department == DepartmentType.creative) return true;
      if (_activeRole == ClubRole.productionLead && t.department == DepartmentType.production) return true;
      if (_activeRole == ClubRole.cinematographerLead && t.department == DepartmentType.cinematography) return true;
      return false;
    }).toList();
  }

  List<ClubTask> get blockedTasks {
    return _tasks.where((t) => t.status == TaskStatus.blocked).toList();
  }

  int get totalVerifiedPoints {
    return _tasks
        .where((t) => t.status == TaskStatus.verified)
        .fold(0, (sum, t) => sum + t.points);
  }

  int get totalCommittedPoints {
    return _tasks
        .where((t) => t.status != TaskStatus.requested)
        .fold(0, (sum, t) => sum + t.points);
  }

  int getDepartmentVerifiedPoints(DepartmentType department) {
    return _tasks
        .where((t) => t.department == department && t.status == TaskStatus.verified)
        .fold(0, (sum, t) => sum + t.points);
  }

  int getDepartmentTotalPoints(DepartmentType department) {
    return _tasks
        .where((t) => t.department == department)
        .fold(0, (sum, t) => sum + t.points);
  }

  // --- ACTIONS ---

  void addEvent(ClubEvent event) {
    _events.insert(0, event);
    notifyListeners();
  }

  void addTask(ClubTask task) {
    _tasks.insert(0, task);
    _pushNotification(
      'New assignment: "${task.title}" allocated to ${task.assigneeRole.title}',
      title: 'TASK DISPATCHED',
      type: 'assignment',
    );
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(status: newStatus);
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
    _pushNotification(
      'Proof submitted for "${_tasks[index].title}". Ready for Lead verification.',
      title: 'PROOF SUBMITTED',
      type: 'proof',
    );
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
    _awardPointsToMember(task.assigneeName, task.points, task.corporateValueSkill);
    _pushNotification(
      'Verified: "${task.title}" (+${task.points} Corporate XP to ${task.assigneeName})',
      title: 'TASK VERIFIED · XP AWARDED',
      type: 'verification',
    );
    notifyListeners();
  }

  void reportBlocker(String taskId, String blockerReason, DepartmentType? blockedBy) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.blocked,
      blocker: blockerReason,
      blockedByDepartment: blockedBy,
    );
    _pushNotification(
      'Blocker on "${_tasks[index].title}": $blockerReason',
      title: '🚨 CRITICAL BLOCKER ESCALATED',
      type: 'blocker',
    );
    notifyListeners();
  }

  void resolveBlocker(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.inProgress,
      blocker: null,
      blockedByDepartment: null,
    );
    _pushNotification(
      'Blocker cleared on "${_tasks[index].title}". Workflow resumed.',
      title: '✅ BLOCKER RESOLVED',
      type: 'resolved',
    );
    notifyListeners();
  }

  void nudgeDepartment(DepartmentType department, String reason) {
    _pushNotification(
      'Nudge dispatched to ${department.displayName}: "$reason"',
      title: 'OPERATIONAL NUDGE',
      type: 'nudge',
    );
    notifyListeners();
  }

  void generateAiEvent({
    required String title,
    required String themeTagline,
    required EventCategory category,
    required DateTime targetDate,
    required String venue,
    int expectedFootfall = 300,
    String budgetLabel = '₹50,000 / \$600',
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

    _events.insert(0, blueprint.event);
    _tasks.insertAll(0, blueprint.tasks);
    _pushNotification('✨ AI Architect synthesized "${blueprint.event.title}" and generated ${blueprint.tasks.length} synchronized department tasks!');
    notifyListeners();
  }

  void _pushNotification(
    String message, {
    String title = 'CLUB DISPATCH',
    String type = 'info',
    String? actionLabel,
  }) {
    _notifications.insert(0, message);
    if (_notifications.length > 25) _notifications.removeLast();
    _latestAlert = ClubLiveNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      actionLabel: actionLabel,
    );
  }

  void _awardPointsToMember(String memberName, int points, String skillTag) {
    final index = _members.indexWhere((m) => m.name == memberName);
    if (index == -1) return;
    final member = _members[index];
    final updatedSkills = Map<String, int>.from(member.corporateSkillsEarned);
    updatedSkills[skillTag] = (updatedSkills[skillTag] ?? 0) + points;
    _members[index] = MemberProfile(
      id: member.id,
      name: member.name,
      role: member.role,
      department: member.department,
      yearAndMajor: member.yearAndMajor,
      totalVerifiedPoints: member.totalVerifiedPoints + points,
      reliabilityRate: (member.reliabilityRate + 0.5).clamp(80.0, 99.8),
      badges: member.badges,
      corporateSkillsEarned: updatedSkills,
    );
  }

  // --- SEED DATA ---
  void _bootstrapSeedData() {
    final now = DateTime.now();

    final flagshipEvent = ClubEvent(
      id: 'ev-flagship-gwd-2026',
      title: 'GWD TechConnect 2026: Campus to Corporate Summit',
      themeTagline: 'Bridging the Gap Between Academic Theory and Industry 4.0 Standards',
      category: EventCategory.flagship,
      targetDate: now.add(const Duration(days: 16)),
      venue: 'Main University Convention Center & Innovation Lab',
      expectedFootfall: 550,
      status: EventStatus.inProgress,
      budgetLabel: '₹85,000 / \$1,020',
      isFlagship: true,
      runOfShow: [
        const EventRunOfShowItem(
          time: '09:00 AM',
          title: 'Delegate Registration & GWD Welcome Kits',
          department: 'Event Logistics & Ops',
          ownerName: 'Bhavya (Event Lead)',
          notes: 'Pre-printed badges, QR scanner gates open',
        ),
        const EventRunOfShowItem(
          time: '10:00 AM',
          title: 'Opening Keynote: GWD Global Leadership',
          department: 'Executive Board',
          ownerName: 'Aldrin Paul (President)',
          notes: 'Keynote deck on main LED wall',
        ),
        const EventRunOfShowItem(
          time: '11:30 AM',
          title: 'Industry Panel: Corporate Expectations vs Student Readiness',
          department: 'PR & Corporate Relations',
          ownerName: 'Tuba Azeem (PR Lead)',
          notes: 'Panelists from Google Cloud & Tier-1 FinTech',
        ),
        const EventRunOfShowItem(
          time: '01:00 PM',
          title: 'Keynote & Stage LED Visual Brand Verification',
          department: 'Creative & Brand Design',
          ownerName: 'Nishta (Creative Lead)',
          notes: 'Stage backdrop motion graphics verified and locked',
        ),
        const EventRunOfShowItem(
          time: '02:00 PM',
          title: 'Breakout Tech Tracks & Live Demos',
          department: 'Production & AV Tech',
          ownerName: 'Mohd Abdul Rahman Pasha (CEO - Temp)',
          notes: 'Hands-on code sprint tracks',
        ),
        const EventRunOfShowItem(
          time: '04:30 PM',
          title: 'Awards Ceremony & Same-Day Cinematic Aftermovie',
          department: 'Cinematography & Media',
          ownerName: 'Burhan (Cinema Lead)',
          notes: 'Same-day 90s cut played on main screen',
        ),
      ],
    );

    final workshopEvent = ClubEvent(
      id: 'ev-workshop-genai',
      title: 'Corporate GenAI & Full-Stack Cloud Architecture Workshop',
      themeTagline: 'Hands-on Real World Engineering with Production Docker & Vector DBs',
      category: EventCategory.workshop,
      targetDate: now.add(const Duration(days: 6)),
      venue: 'Advanced Engineering Lab 4',
      expectedFootfall: 140,
      status: EventStatus.inProgress,
      budgetLabel: '₹22,000 / \$270',
      isFlagship: false,
    );

    _events = [flagshipEvent, workshopEvent];

    _tasks = [
      // Verified Tasks
      ClubTask(
        id: 'task-seed-1',
        eventId: flagshipEvent.id,
        title: 'Draft and confirm official College Dean permission & security escort sanction',
        department: DepartmentType.executive,
        assigneeRole: ClubRole.generalSecretary,
        assigneeName: 'Sravya',
        creatorRole: ClubRole.president,
        points: 8,
        dueLabel: 'Completed · Yesterday',
        dueDate: now.subtract(const Duration(days: 1)),
        definitionOfDone: 'Signed letter from Dean of Student Affairs uploaded to Drive.',
        status: TaskStatus.verified,
        corporateValueSkill: 'Executive Governance & Clearance',
        proof: 'Signed letter uploaded: gwd.global/drive/perm-dean-techconnect.pdf',
        verifiedByRole: ClubRole.president,
        verifiedByName: 'Aldrin Paul',
      ),
      ClubTask(
        id: 'task-seed-2',
        eventId: flagshipEvent.id,
        title: 'Pitch and confirm Title Sponsor & 2 Associate Industry Partners',
        department: DepartmentType.publicRelations,
        assigneeRole: ClubRole.prLead,
        assigneeName: 'Tuba Azeem',
        creatorRole: ClubRole.president,
        points: 13,
        dueLabel: 'Completed · 2 days ago',
        dueDate: now.subtract(const Duration(days: 2)),
        definitionOfDone: 'Corporate MoUs signed for ₹50,000 sponsorship pool.',
        status: TaskStatus.verified,
        corporateValueSkill: 'Corporate Sponsorship Pitching',
        proof: 'Signed MoU with CloudPartner & TechVentures: gwd.global/pr/mou-2026.pdf',
        verifiedByRole: ClubRole.president,
        verifiedByName: 'Aldrin Paul',
      ),

      // Submitted Tasks (Awaiting Verification)
      ClubTask(
        id: 'task-seed-3',
        eventId: flagshipEvent.id,
        title: 'Edit and export official 60s Cinematic Teaser Reel with sound fx & titles',
        department: DepartmentType.cinematography,
        assigneeRole: ClubRole.cinematographerLead,
        assigneeName: 'Burhan',
        creatorRole: ClubRole.vicePresident,
        points: 13,
        dueLabel: 'Today · 5:00 PM',
        dueDate: now,
        definitionOfDone: '4K video file delivered in 9:16 and 16:9 formats with captions.',
        status: TaskStatus.submitted,
        corporateValueSkill: 'High-Impact Video Production',
        proof: 'Draft render on Frame.io: https://frame.io/v/gwd-teaser-v2. MP4 ready.',
      ),
      ClubTask(
        id: 'task-seed-4',
        eventId: flagshipEvent.id,
        title: 'Design official GWD TechConnect keynote slide deck, stage visual graphics & badge system',
        department: DepartmentType.creative,
        assigneeRole: ClubRole.creativeLead,
        assigneeName: 'Nishta',
        creatorRole: ClubRole.gwdCmo,
        points: 12,
        dueLabel: 'Today · 4:00 PM',
        dueDate: now,
        definitionOfDone: 'Figma package with all keynote 4K templates, stage motion graphics and participant badge designs.',
        status: TaskStatus.submitted,
        corporateValueSkill: 'Brand Design Systems & UX',
        proof: 'Figma workspace: figma.com/file/gwd-techconnect-creative with all keynote templates.',
      ),

      // Blocked Task (Cross-department dependency!)
      ClubTask(
        id: 'task-seed-5',
        eventId: flagshipEvent.id,
        title: 'Finalize multi-camera stage shooting cues & speaker lighting angles',
        department: DepartmentType.cinematography,
        assigneeRole: ClubRole.cinematographerLead,
        assigneeName: 'Burhan',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'Tomorrow',
        dueDate: now.add(const Duration(days: 1)),
        definitionOfDone: 'Camera placement map aligned with auditorium stage flow.',
        status: TaskStatus.blocked,
        blocker: 'Awaiting finalized Stage Layout and Podium Position from Bhavya (Event Ops Lead).',
        blockedByDepartment: DepartmentType.eventManagement,
        corporateValueSkill: 'Broadcast Technical Direction',
      ),

      // In Progress Tasks
      ClubTask(
        id: 'task-seed-6',
        eventId: flagshipEvent.id,
        title: 'Execute campus registration drive targeting 400 engineering & MBA students',
        department: DepartmentType.marketing,
        assigneeRole: ClubRole.marketingLead,
        assigneeName: 'Anvitha',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'Friday',
        dueDate: now.add(const Duration(days: 3)),
        definitionOfDone: 'Registration tally reaches 350+ verified student ticket bookings.',
        status: TaskStatus.inProgress,
        corporateValueSkill: 'Growth Funnel & Acquisition',
      ),
      ClubTask(
        id: 'task-seed-7',
        eventId: flagshipEvent.id,
        title: 'Coordinate VIP speaker transportation, green room & hospitality kits',
        department: DepartmentType.publicRelations,
        assigneeRole: ClubRole.clubMember,
        assigneeName: 'Rhea Sen',
        creatorRole: ClubRole.prLead,
        points: 5,
        dueLabel: 'In 4 days',
        dueDate: now.add(const Duration(days: 4)),
        definitionOfDone: 'Flight timings, hotel booking, and college vehicle passes confirmed.',
        status: TaskStatus.inProgress,
        corporateValueSkill: 'VIP Hospitality & Logistics',
      ),
      ClubTask(
        id: 'task-seed-8',
        eventId: flagshipEvent.id,
        title: 'Procure 500 branded lanyards, delegate ID cards & QR scanners',
        department: DepartmentType.eventManagement,
        assigneeRole: ClubRole.eventManagementLead,
        assigneeName: 'Bhavya',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'In 5 days',
        dueDate: now.add(const Duration(days: 5)),
        definitionOfDone: 'Delivery received at club room and quantity cross-checked.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Vendor Procurement & Negotiation',
      ),
    ];

    _members = [
      const MemberProfile(
        id: 'mem-cmo',
        name: 'Mohammed Abdul Mudabbir',
        role: ClubRole.gwdCmo,
        department: DepartmentType.executive,
        yearAndMajor: 'GWD Global · Chief Marketing Officer',
        totalVerifiedPoints: 118,
        reliabilityRate: 99.6,
        badges: ['Brand Custodian', 'Global CMO', 'Youth Leadership Mentor'],
        corporateSkillsEarned: {
          'Global Brand Architecture': 48,
          'Corporate Sponsorship Closures': 44,
          'Creative Quality Audit': 40,
        },
      ),
      const MemberProfile(
        id: 'mem-ceo',
        name: 'Mohd Abdul Rahman Pasha',
        role: ClubRole.gwdCeo,
        department: DepartmentType.executive,
        yearAndMajor: 'GWD Global · CEO & Founder',
        totalVerifiedPoints: 125,
        reliabilityRate: 99.8,
        badges: ['Company Founder', 'Global Club Supervisor', 'Corporate Mentor'],
        corporateSkillsEarned: {
          'Enterprise Governance': 50,
          'Campus-to-Corporate Strategy': 45,
          'Strategic Budget Allocation': 42,
        },
      ),
      const MemberProfile(
        id: 'mem-president',
        name: 'Aldrin Paul',
        role: ClubRole.president,
        department: DepartmentType.executive,
        yearAndMajor: '4th Year · President & Executive Lead',
        totalVerifiedPoints: 78,
        reliabilityRate: 98.6,
        badges: ['Executive Leader', 'GWD Global Ambassador', 'Keynote Speaker'],
        corporateSkillsEarned: {
          'Executive Governance': 28,
          'Strategic Budgeting': 22,
          'Corporate Sponsorship Pitching': 28,
        },
      ),
      const MemberProfile(
        id: 'mem-vp',
        name: 'Mohd Ismail',
        role: ClubRole.vicePresident,
        department: DepartmentType.executive,
        yearAndMajor: '4th Year · Vice President & Operations Lead',
        totalVerifiedPoints: 68,
        reliabilityRate: 98.2,
        badges: ['Operations Maestro', 'Cross-Functional Catalyst'],
        corporateSkillsEarned: {
          'Cross-functional Alignment': 36,
          'Timeline Velocity': 28,
        },
      ),
      const MemberProfile(
        id: 'mem-gensec',
        name: 'Sravya',
        role: ClubRole.generalSecretary,
        department: DepartmentType.executive,
        yearAndMajor: '3rd Year · General Secretary & Governance',
        totalVerifiedPoints: 56,
        reliabilityRate: 97.0,
        badges: ['Governance Master', 'Official Liaison', 'Dean Protocol'],
        corporateSkillsEarned: {
          'Institutional Clearance': 32,
          'Statutory Documentation': 24,
        },
      ),
      const MemberProfile(
        id: 'mem-marketing',
        name: 'Anvitha',
        role: ClubRole.marketingLead,
        department: DepartmentType.marketing,
        yearAndMajor: '3rd Year · Marketing & Growth Lead',
        totalVerifiedPoints: 62,
        reliabilityRate: 96.8,
        badges: ['Growth Hacker', 'Campus Viralist', 'Conversion Queen'],
        corporateSkillsEarned: {
          'Campaign ROI & Growth': 38,
          'Audience Acquisition': 24,
        },
      ),
      const MemberProfile(
        id: 'mem-pr',
        name: 'Tuba Azeem',
        role: ClubRole.prLead,
        department: DepartmentType.publicRelations,
        yearAndMajor: '4th Year · PR & Corporate Relations Lead',
        totalVerifiedPoints: 70,
        reliabilityRate: 98.5,
        badges: ['Sponsorship Closer', 'VIP Diplomat', 'MoU Specialist'],
        corporateSkillsEarned: {
          'Corporate Sponsorship Pitching': 42,
          'Keynote Negotiation': 28,
        },
      ),
      const MemberProfile(
        id: 'mem-events',
        name: 'Bhavya',
        role: ClubRole.eventManagementLead,
        department: DepartmentType.eventManagement,
        yearAndMajor: '3rd Year · Event Management & Logistics Lead',
        totalVerifiedPoints: 58,
        reliabilityRate: 96.2,
        badges: ['Logistics Commander', 'Run-of-Show Architect'],
        corporateSkillsEarned: {
          'Run-of-Show Protocol': 32,
          'Crowd Engineering': 26,
        },
      ),
      const MemberProfile(
        id: 'mem-creative',
        name: 'Nishta',
        role: ClubRole.creativeLead,
        department: DepartmentType.creative,
        yearAndMajor: '3rd Year · Creative & Brand Lead',
        totalVerifiedPoints: 64,
        reliabilityRate: 97.5,
        badges: ['Design Visionary', 'Keynote Stylist', 'Brand Maestro'],
        corporateSkillsEarned: {
          'Brand Design Systems': 36,
          'Visual Storytelling & UI': 28,
        },
      ),
      const MemberProfile(
        id: 'mem-production',
        name: 'Mohd Abdul Rahman Pasha (CEO - Temp)',
        role: ClubRole.productionLead,
        department: DepartmentType.production,
        yearAndMajor: 'Production & AV Tech Lead (CEO - Temp)',
        totalVerifiedPoints: 60,
        reliabilityRate: 98.0,
        badges: ['AV Virtuoso', 'Stage Tech Director'],
        corporateSkillsEarned: {
          'Stage AV Engineering': 35,
          'Live Technical Setup': 25,
        },
      ),
      const MemberProfile(
        id: 'mem-cinema',
        name: 'Burhan',
        role: ClubRole.cinematographerLead,
        department: DepartmentType.cinematography,
        yearAndMajor: '3rd Year · Cinematographer & Media Lead',
        totalVerifiedPoints: 66,
        reliabilityRate: 98.0,
        badges: ['Cinematic Visionary', 'Rapid Turnaround Pro'],
        corporateSkillsEarned: {
          'Commercial Video Production': 40,
          'Aftermovie Storyboarding': 26,
        },
      ),
      const MemberProfile(
        id: 'mem-member',
        name: 'Rhea Sen',
        role: ClubRole.clubMember,
        department: DepartmentType.publicRelations,
        yearAndMajor: '2nd Year · Club Associate & Crew',
        totalVerifiedPoints: 38,
        reliabilityRate: 95.5,
        badges: ['Rising PR Associate', 'Hospitality Star'],
        corporateSkillsEarned: {
          'VIP Hospitality & Logistics': 24,
          'Corporate Outreach': 14,
        },
      ),
    ];

    _notifications.addAll([
      '⚡ GWD TechConnect 2026 entered active countdown (16 days remaining)',
      '🚨 Blocker flagged: Cinematographer needs Stage Layout from Event Ops',
      '✨ AI Event Architect blueprint generated for Corporate GenAI Bootcamp',
    ]);
  }
}

class ClubLiveNotification {
  const ClubLiveNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = 'info',
    this.actionLabel,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'verification', 'blocker', 'event', 'nudge', 'proof', 'role', 'info'
  final String? actionLabel;
}

