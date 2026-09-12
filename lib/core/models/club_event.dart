import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EventCategory {
  flagship,
  workshop,
  hackathon,
  industryTalk,
  bootcamp,
}

extension EventCategoryDetails on EventCategory {
  String get label => switch (this) {
        EventCategory.flagship => 'Flagship Summit',
        EventCategory.workshop => 'Corporate Workshop',
        EventCategory.hackathon => '24h Hackathon',
        EventCategory.industryTalk => 'Industry Keynote',
        EventCategory.bootcamp => 'Skill Bootcamp',
      };

  Color get color => switch (this) {
        EventCategory.flagship => const Color(0xFFDC2626), // GWD Crimson Red
        EventCategory.workshop => const Color(0xFF0D9488),
        EventCategory.hackathon => const Color(0xFFEF4444),
        EventCategory.industryTalk => const Color(0xFF991B1B), // Deep Ruby
        EventCategory.bootcamp => const Color(0xFFF59E0B),
      };

  IconData get icon => switch (this) {
        EventCategory.flagship => Icons.star_outline,
        EventCategory.workshop => Icons.architecture_outlined,
        EventCategory.hackathon => Icons.terminal_outlined,
        EventCategory.industryTalk => Icons.record_voice_over_outlined,
        EventCategory.bootcamp => Icons.rocket_launch_outlined,
      };
}

enum EventStatus {
  planning,
  inProgress,
  live,
  completed,
}

extension EventStatusDetails on EventStatus {
  String get label => switch (this) {
        EventStatus.planning => 'Planning & Pre-production',
        EventStatus.inProgress => 'Campaign & Logistics Active',
        EventStatus.live => 'LIVE Today',
        EventStatus.completed => 'Completed & De-briefed',
      };

  Color get color => switch (this) {
        EventStatus.planning => const Color(0xFF71717A),
        EventStatus.inProgress => const Color(0xFFDC2626),
        EventStatus.live => const Color(0xFF16A34A),
        EventStatus.completed => const Color(0xFF18181B),
      };
}

class EventRunOfShowItem {
  const EventRunOfShowItem({
    required this.time,
    required this.title,
    required this.department,
    required this.ownerName,
    this.notes,
  });

  final String time;
  final String title;
  final String department;
  final String ownerName;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'time': time,
        'title': title,
        'department': department,
        'ownerName': ownerName,
        'notes': notes,
      };

  factory EventRunOfShowItem.fromJson(Map<String, dynamic> json) =>
      EventRunOfShowItem(
        time: json['time'] as String,
        title: json['title'] as String,
        department: json['department'] as String,
        ownerName: json['ownerName'] as String,
        notes: json['notes'] as String?,
      );
}

class ClubEvent {
  const ClubEvent({
    required this.id,
    required this.title,
    required this.themeTagline,
    required this.category,
    required this.targetDate,
    required this.venue,
    required this.expectedFootfall,
    required this.status,
    required this.budgetLabel,
    this.isFlagship = false,
    this.runOfShow = const [],
  });

  final String id;
  final String title;
  final String themeTagline;
  final EventCategory category;
  final DateTime targetDate;
  final String venue;
  final int expectedFootfall;
  final EventStatus status;
  final String budgetLabel;
  final bool isFlagship;
  final List<EventRunOfShowItem> runOfShow;

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  String get formattedDate {
    return DateFormat('EEE, MMM d, yyyy').format(targetDate);
  }

  String get countdownLabel {
    final days = daysRemaining;
    if (days == 0) return 'TODAY';
    if (days == 1) return 'Tomorrow';
    return '$days days left';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'themeTagline': themeTagline,
        'category': category.name,
        'targetDate': targetDate.toIso8601String(),
        'venue': venue,
        'expectedFootfall': expectedFootfall,
        'status': status.name,
        'budgetLabel': budgetLabel,
        'isFlagship': isFlagship,
        'runOfShow': runOfShow.map((item) => item.toJson()).toList(),
      };

  factory ClubEvent.fromJson(Map<String, dynamic> json) => ClubEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        themeTagline: json['themeTagline'] as String,
        category: EventCategory.values.byName(json['category'] as String),
        targetDate: DateTime.parse(json['targetDate'] as String),
        venue: json['venue'] as String,
        expectedFootfall: (json['expectedFootfall'] as num).toInt(),
        status: EventStatus.values.byName(json['status'] as String),
        budgetLabel: json['budgetLabel'] as String,
        isFlagship: json['isFlagship'] as bool? ?? false,
        runOfShow: (json['runOfShow'] as List<dynamic>?)
                ?.map((e) =>
                    EventRunOfShowItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const [],
      );

  ClubEvent copyWith({
    String? title,
    String? themeTagline,
    EventCategory? category,
    DateTime? targetDate,
    String? venue,
    int? expectedFootfall,
    EventStatus? status,
    String? budgetLabel,
    bool? isFlagship,
    List<EventRunOfShowItem>? runOfShow,
  }) {
    return ClubEvent(
      id: id,
      title: title ?? this.title,
      themeTagline: themeTagline ?? this.themeTagline,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      venue: venue ?? this.venue,
      expectedFootfall: expectedFootfall ?? this.expectedFootfall,
      status: status ?? this.status,
      budgetLabel: budgetLabel ?? this.budgetLabel,
      isFlagship: isFlagship ?? this.isFlagship,
      runOfShow: runOfShow ?? this.runOfShow,
    );
  }
}
