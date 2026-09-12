import 'package:flutter/material.dart';

import 'club_role.dart';
import 'department.dart';

/// ---------------------------------------------------------------------------
/// COLLABORATION PRIMITIVES
///
/// The club runs on work passing between departments. These three types model
/// that explicitly: an [ActivityEvent] records what happened, a [CollabMessage]
/// is the conversation around one deliverable, and a [Handoff] is a formal
/// request from one department to another with an owner and a deadline.
/// ---------------------------------------------------------------------------

/// How loudly an event is allowed to interrupt.
///
/// This is the switch that stops the app shouting. Only [critical] events —
/// and events personally addressed to the viewer — are permitted to take over
/// the Dynamic Island. Everything else lands quietly in the activity feed.
enum ActivitySeverity {
  /// Background record. Feed only, never interrupts.
  ambient,

  /// Worth knowing. Interrupts only if the viewer is a named target.
  notable,

  /// Blocks someone's work or needs a decision. Always interrupts.
  critical,
}

enum ActivityKind {
  taskAssigned,
  taskAccepted,
  proofSubmitted,
  taskVerified,
  blockerRaised,
  blockerCleared,
  handoffRequested,
  handoffAccepted,
  handoffDelivered,
  handoffDeclined,
  comment,
  mention,
  nudge,
  eventCreated,
  sessionChanged,
  systemNote,
}

extension ActivityKindDetails on ActivityKind {
  /// The default loudness for this kind of event. Personal targeting can
  /// promote a [notable] event, but nothing can promote an [ambient] one.
  ActivitySeverity get severity => switch (this) {
        ActivityKind.blockerRaised => ActivitySeverity.critical,
        ActivityKind.handoffRequested => ActivitySeverity.critical,
        ActivityKind.mention => ActivitySeverity.critical,
        ActivityKind.taskVerified => ActivitySeverity.notable,
        ActivityKind.handoffAccepted => ActivitySeverity.notable,
        ActivityKind.handoffDelivered => ActivitySeverity.notable,
        ActivityKind.handoffDeclined => ActivitySeverity.notable,
        ActivityKind.blockerCleared => ActivitySeverity.notable,
        ActivityKind.proofSubmitted => ActivitySeverity.notable,
        ActivityKind.taskAssigned => ActivitySeverity.notable,
        ActivityKind.nudge => ActivitySeverity.notable,
        ActivityKind.eventCreated => ActivitySeverity.notable,
        ActivityKind.taskAccepted => ActivitySeverity.ambient,
        ActivityKind.comment => ActivitySeverity.ambient,
        ActivityKind.sessionChanged => ActivitySeverity.ambient,
        ActivityKind.systemNote => ActivitySeverity.ambient,
      };

  IconData get icon => switch (this) {
        ActivityKind.taskAssigned => Icons.assignment_outlined,
        ActivityKind.taskAccepted => Icons.handshake_outlined,
        ActivityKind.proofSubmitted => Icons.fact_check_outlined,
        ActivityKind.taskVerified => Icons.verified_outlined,
        ActivityKind.blockerRaised => Icons.report_problem_outlined,
        ActivityKind.blockerCleared => Icons.lock_open_outlined,
        ActivityKind.handoffRequested => Icons.swap_horiz_rounded,
        ActivityKind.handoffAccepted => Icons.check_circle_outline,
        ActivityKind.handoffDelivered => Icons.local_shipping_outlined,
        ActivityKind.handoffDeclined => Icons.do_not_disturb_alt_outlined,
        ActivityKind.comment => Icons.mode_comment_outlined,
        ActivityKind.mention => Icons.alternate_email_rounded,
        ActivityKind.nudge => Icons.notifications_active_outlined,
        ActivityKind.eventCreated => Icons.auto_awesome_outlined,
        ActivityKind.sessionChanged => Icons.badge_outlined,
        ActivityKind.systemNote => Icons.info_outline,
      };

  String get label => switch (this) {
        ActivityKind.taskAssigned => 'Assigned',
        ActivityKind.taskAccepted => 'Accepted',
        ActivityKind.proofSubmitted => 'Proof in',
        ActivityKind.taskVerified => 'Verified',
        ActivityKind.blockerRaised => 'Blocked',
        ActivityKind.blockerCleared => 'Unblocked',
        ActivityKind.handoffRequested => 'Handoff',
        ActivityKind.handoffAccepted => 'Accepted',
        ActivityKind.handoffDelivered => 'Delivered',
        ActivityKind.handoffDeclined => 'Declined',
        ActivityKind.comment => 'Comment',
        ActivityKind.mention => 'Mention',
        ActivityKind.nudge => 'Nudge',
        ActivityKind.eventCreated => 'New event',
        ActivityKind.sessionChanged => 'Session',
        ActivityKind.systemNote => 'Note',
      };
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.timestamp,
    this.actorId,
    this.actorName,
    this.targetMemberIds = const [],
    this.taskId,
    this.handoffId,
    this.department,
    this.read = false,
  });

  final String id;
  final ActivityKind kind;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? actorId;
  final String? actorName;

  /// Members this event is personally addressed to. A [notable] event
  /// addressed to the viewer is promoted to an interruption; the same event
  /// seen by anyone else stays in the feed.
  final List<String> targetMemberIds;
  final String? taskId;
  final String? handoffId;
  final DepartmentType? department;
  final bool read;

  ActivitySeverity get severity => kind.severity;

  /// Whether this event should take over the Dynamic Island for [memberId].
  bool interruptsFor(String? memberId) {
    if (severity == ActivitySeverity.critical) return true;
    if (severity == ActivitySeverity.ambient) return false;
    return memberId != null && targetMemberIds.contains(memberId);
  }

  ActivityEvent copyWith({bool? read}) => ActivityEvent(
        id: id,
        kind: kind,
        title: title,
        body: body,
        timestamp: timestamp,
        actorId: actorId,
        actorName: actorName,
        targetMemberIds: targetMemberIds,
        taskId: taskId,
        handoffId: handoffId,
        department: department,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'actorId': actorId,
        'actorName': actorName,
        'targetMemberIds': targetMemberIds,
        'taskId': taskId,
        'handoffId': handoffId,
        'department': department?.name,
        'read': read,
      };

  factory ActivityEvent.fromJson(Map<String, dynamic> json) => ActivityEvent(
        id: json['id'] as String,
        kind: ActivityKind.values.byName(json['kind'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        actorId: json['actorId'] as String?,
        actorName: json['actorName'] as String?,
        targetMemberIds:
            List<String>.from(json['targetMemberIds'] as List? ?? const []),
        taskId: json['taskId'] as String?,
        handoffId: json['handoffId'] as String?,
        department: json['department'] == null
            ? null
            : DepartmentType.values.byName(json['department'] as String),
        read: json['read'] as bool? ?? false,
      );
}

/// One message on a deliverable's thread. [isDecision] pins a message as the
/// agreed outcome so the thread does not have to be re-read to find it.
class CollabMessage {
  const CollabMessage({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.body,
    required this.createdAt,
    this.mentions = const [],
    this.isDecision = false,
  });

  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final ClubRole authorRole;
  final String body;
  final DateTime createdAt;
  final List<String> mentions;
  final bool isDecision;

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'authorId': authorId,
        'authorName': authorName,
        'authorRole': authorRole.name,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'mentions': mentions,
        'isDecision': isDecision,
      };

  factory CollabMessage.fromJson(Map<String, dynamic> json) => CollabMessage(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        authorRole: ClubRole.values.byName(json['authorRole'] as String),
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        mentions: List<String>.from(json['mentions'] as List? ?? const []),
        isDecision: json['isDecision'] as bool? ?? false,
      );
}

enum HandoffStatus { requested, accepted, delivered, declined }

extension HandoffStatusDetails on HandoffStatus {
  String get label => switch (this) {
        HandoffStatus.requested => 'Awaiting response',
        HandoffStatus.accepted => 'Accepted',
        HandoffStatus.delivered => 'Delivered',
        HandoffStatus.declined => 'Declined',
      };

  Color get color => switch (this) {
        HandoffStatus.requested => const Color(0xFFD97706),
        HandoffStatus.accepted => const Color(0xFF2563EB),
        HandoffStatus.delivered => const Color(0xFF16A34A),
        HandoffStatus.declined => const Color(0xFF9A9AA4),
      };

  IconData get icon => switch (this) {
        HandoffStatus.requested => Icons.hourglass_top_rounded,
        HandoffStatus.accepted => Icons.check_circle_outline,
        HandoffStatus.delivered => Icons.verified_outlined,
        HandoffStatus.declined => Icons.do_not_disturb_alt_outlined,
      };
}

/// A formal request for work to cross a department boundary. This is the
/// object the blocker radar has always implied but never actually modelled:
/// Cinematography waiting on Event Ops for a stage layout is a handoff, with
/// a named requester, a named responder and a date it is needed by.
class Handoff {
  const Handoff({
    required this.id,
    required this.title,
    required this.need,
    required this.fromDepartment,
    required this.toDepartment,
    required this.requestedById,
    required this.requestedByName,
    required this.createdAt,
    required this.neededBy,
    this.status = HandoffStatus.requested,
    this.taskId,
    this.respondedById,
    this.respondedByName,
    this.respondedAt,
    this.responseNote,
  });

  final String id;
  final String title;
  final String need;
  final DepartmentType fromDepartment;
  final DepartmentType toDepartment;
  final String requestedById;
  final String requestedByName;
  final DateTime createdAt;
  final DateTime neededBy;
  final HandoffStatus status;
  final String? taskId;
  final String? respondedById;
  final String? respondedByName;
  final DateTime? respondedAt;
  final String? responseNote;

  bool get isOpen =>
      status == HandoffStatus.requested || status == HandoffStatus.accepted;

  bool get isOverdue =>
      isOpen && neededBy.isBefore(DateTime.now());

  int get daysUntilNeeded {
    final diff = neededBy.difference(DateTime.now()).inHours;
    return (diff / 24).ceil();
  }

  Handoff copyWith({
    HandoffStatus? status,
    String? respondedById,
    String? respondedByName,
    DateTime? respondedAt,
    String? responseNote,
  }) =>
      Handoff(
        id: id,
        title: title,
        need: need,
        fromDepartment: fromDepartment,
        toDepartment: toDepartment,
        requestedById: requestedById,
        requestedByName: requestedByName,
        createdAt: createdAt,
        neededBy: neededBy,
        status: status ?? this.status,
        taskId: taskId,
        respondedById: respondedById ?? this.respondedById,
        respondedByName: respondedByName ?? this.respondedByName,
        respondedAt: respondedAt ?? this.respondedAt,
        responseNote: responseNote ?? this.responseNote,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'need': need,
        'fromDepartment': fromDepartment.name,
        'toDepartment': toDepartment.name,
        'requestedById': requestedById,
        'requestedByName': requestedByName,
        'createdAt': createdAt.toIso8601String(),
        'neededBy': neededBy.toIso8601String(),
        'status': status.name,
        'taskId': taskId,
        'respondedById': respondedById,
        'respondedByName': respondedByName,
        'respondedAt': respondedAt?.toIso8601String(),
        'responseNote': responseNote,
      };

  factory Handoff.fromJson(Map<String, dynamic> json) => Handoff(
        id: json['id'] as String,
        title: json['title'] as String,
        need: json['need'] as String,
        fromDepartment:
            DepartmentType.values.byName(json['fromDepartment'] as String),
        toDepartment:
            DepartmentType.values.byName(json['toDepartment'] as String),
        requestedById: json['requestedById'] as String,
        requestedByName: json['requestedByName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        neededBy: DateTime.parse(json['neededBy'] as String),
        status: HandoffStatus.values.byName(json['status'] as String),
        taskId: json['taskId'] as String?,
        respondedById: json['respondedById'] as String?,
        respondedByName: json['respondedByName'] as String?,
        respondedAt: json['respondedAt'] == null
            ? null
            : DateTime.parse(json['respondedAt'] as String),
        responseNote: json['responseNote'] as String?,
      );
}

/// Relative time used across the feed, threads and handoff cards.
String relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.isNegative) {
    final ahead = time.difference(DateTime.now());
    if (ahead.inDays >= 1) return 'in ${ahead.inDays}d';
    if (ahead.inHours >= 1) return 'in ${ahead.inHours}h';
    return 'soon';
  }
  if (diff.inSeconds < 45) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
