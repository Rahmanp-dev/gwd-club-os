import 'package:flutter/material.dart';
import 'club_role.dart';
import 'department.dart';

enum TaskStatus {
  requested,
  committed,
  inProgress,
  submitted,
  verified,
  blocked,
}

extension TaskStatusDetails on TaskStatus {
  String get label => switch (this) {
        TaskStatus.requested => 'Needs Acceptance',
        TaskStatus.committed => 'Committed (Pact Signed)',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.submitted => 'Awaiting Verification',
        TaskStatus.verified => 'Verified (Outcome Done)',
        TaskStatus.blocked => 'Blocked',
      };

  Color get color => switch (this) {
        TaskStatus.requested => const Color(0xFF71717A),
        TaskStatus.committed => const Color(0xFF18181B),
        TaskStatus.inProgress => const Color(0xFFF59E0B),
        TaskStatus.submitted => const Color(0xFFDC2626),
        TaskStatus.verified => const Color(0xFF16A34A),
        TaskStatus.blocked => const Color(0xFFDC2626),
      };

  IconData get icon => switch (this) {
        TaskStatus.requested => Icons.assignment_late_outlined,
        TaskStatus.committed => Icons.handshake_outlined,
        TaskStatus.inProgress => Icons.timelapse_outlined,
        TaskStatus.submitted => Icons.fact_check_outlined,
        TaskStatus.verified => Icons.verified_outlined,
        TaskStatus.blocked => Icons.report_problem_outlined,
      };
}

enum TaskSeverity {
  standard,
  highImpact,
  missionCritical,
}

extension TaskSeverityDetails on TaskSeverity {
  String get label => switch (this) {
        TaskSeverity.standard => 'Standard',
        TaskSeverity.highImpact => 'High Impact',
        TaskSeverity.missionCritical => 'MISSION CRITICAL',
      };

  Color get color => switch (this) {
        TaskSeverity.standard => const Color(0xFF64748B),
        TaskSeverity.highImpact => const Color(0xFFF59E0B),
        TaskSeverity.missionCritical => const Color(0xFFEF4444),
      };
}

class ClubTask {
  const ClubTask({
    required this.id,
    this.eventId,
    required this.title,
    required this.department,
    required this.assigneeRole,
    required this.assigneeName,
    required this.creatorRole,
    required this.points,
    required this.dueLabel,
    required this.dueDate,
    required this.definitionOfDone,
    required this.status,
    required this.corporateValueSkill,
    this.scopeOfWork = '',
    this.downstreamImpact = '',
    this.upstreamDependency = '',
    this.deliveryPactSigned = false,
    this.severity = TaskSeverity.standard,
    this.proof,
    this.blocker,
    this.blockedByDepartment,
    this.verifiedByRole,
    this.verifiedByName,
  });

  final String id;
  final String? eventId;
  final String title;
  final DepartmentType department;
  final ClubRole assigneeRole;
  final String assigneeName;
  final ClubRole creatorRole;
  final int points;
  final String dueLabel;
  final DateTime dueDate;
  final String definitionOfDone;
  final TaskStatus status;
  final String corporateValueSkill;
  final String scopeOfWork;
  final String downstreamImpact;
  final String upstreamDependency;
  final bool deliveryPactSigned;
  final TaskSeverity severity;
  final String? proof;
  final String? blocker;
  final DepartmentType? blockedByDepartment;
  final ClubRole? verifiedByRole;
  final String? verifiedByName;

  ClubTask copyWith({
    TaskStatus? status,
    String? proof,
    String? blocker,
    DepartmentType? blockedByDepartment,
    ClubRole? verifiedByRole,
    String? verifiedByName,
    bool? deliveryPactSigned,
    String? scopeOfWork,
    String? downstreamImpact,
    String? upstreamDependency,
    TaskSeverity? severity,
  }) {
    return ClubTask(
      id: id,
      eventId: eventId,
      title: title,
      department: department,
      assigneeRole: assigneeRole,
      assigneeName: assigneeName,
      creatorRole: creatorRole,
      points: points,
      dueLabel: dueLabel,
      dueDate: dueDate,
      definitionOfDone: definitionOfDone,
      status: status ?? this.status,
      corporateValueSkill: corporateValueSkill,
      scopeOfWork: scopeOfWork ?? this.scopeOfWork,
      downstreamImpact: downstreamImpact ?? this.downstreamImpact,
      upstreamDependency: upstreamDependency ?? this.upstreamDependency,
      deliveryPactSigned: deliveryPactSigned ?? this.deliveryPactSigned,
      severity: severity ?? this.severity,
      proof: proof ?? this.proof,
      blocker: blocker ?? this.blocker,
      blockedByDepartment: blockedByDepartment ?? this.blockedByDepartment,
      verifiedByRole: verifiedByRole ?? this.verifiedByRole,
      verifiedByName: verifiedByName ?? this.verifiedByName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'title': title,
        'department': department.name,
        'assigneeRole': assigneeRole.name,
        'assigneeName': assigneeName,
        'creatorRole': creatorRole.name,
        'points': points,
        'dueLabel': dueLabel,
        'dueDate': dueDate.toIso8601String(),
        'definitionOfDone': definitionOfDone,
        'status': status.name,
        'corporateValueSkill': corporateValueSkill,
        'scopeOfWork': scopeOfWork,
        'downstreamImpact': downstreamImpact,
        'upstreamDependency': upstreamDependency,
        'deliveryPactSigned': deliveryPactSigned,
        'severity': severity.name,
        'proof': proof,
        'blocker': blocker,
        'blockedByDepartment': blockedByDepartment?.name,
        'verifiedByRole': verifiedByRole?.name,
        'verifiedByName': verifiedByName,
      };

  factory ClubTask.fromJson(Map<String, dynamic> json) => ClubTask(
        id: json['id'] as String,
        eventId: json['eventId'] as String?,
        title: json['title'] as String,
        department: DepartmentType.values.byName(json['department'] as String),
        assigneeRole: ClubRole.values.byName(json['assigneeRole'] as String),
        assigneeName: json['assigneeName'] as String,
        creatorRole: ClubRole.values.byName(json['creatorRole'] as String),
        points: (json['points'] as num).toInt(),
        dueLabel: json['dueLabel'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        definitionOfDone: json['definitionOfDone'] as String,
        status: TaskStatus.values.byName(json['status'] as String),
        corporateValueSkill: json['corporateValueSkill'] as String,
        scopeOfWork: (json['scopeOfWork'] as String?) ?? '',
        downstreamImpact: (json['downstreamImpact'] as String?) ?? '',
        upstreamDependency: (json['upstreamDependency'] as String?) ?? '',
        deliveryPactSigned: (json['deliveryPactSigned'] as bool?) ?? false,
        severity: json['severity'] != null
            ? TaskSeverity.values.byName(json['severity'] as String)
            : TaskSeverity.standard,
        proof: json['proof'] as String?,
        blocker: json['blocker'] as String?,
        blockedByDepartment: json['blockedByDepartment'] != null
            ? DepartmentType.values.byName(json['blockedByDepartment'] as String)
            : null,
        verifiedByRole: json['verifiedByRole'] != null
            ? ClubRole.values.byName(json['verifiedByRole'] as String)
            : null,
        verifiedByName: json['verifiedByName'] as String?,
      );
}
