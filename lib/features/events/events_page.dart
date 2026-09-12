import 'package:flutter/material.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import 'ai_event_generator_sheet.dart';
import 'event_detail_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({
    super.key,
    required this.events,
    required this.tasks,
    required this.onGenerateAiEvent,
    required this.onViewDepartmentTasks,
  });

  final List<ClubEvent> events;
  final List<ClubTask> tasks;
  final void Function({
    required String title,
    required String themeTagline,
    required EventCategory category,
    required DateTime targetDate,
    required String venue,
    required int expectedFootfall,
    required String budgetLabel,
    String? customInstructions,
  }) onGenerateAiEvent;
  final void Function(DepartmentType department) onViewDepartmentTasks;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  EventCategory? _selectedCategory;

  void _showAiGenerator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiEventGeneratorSheet(
        onGenerate: widget.onGenerateAiEvent,
      ),
    );
  }

  void _showEventDetail(ClubEvent event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailSheet(
        event: event,
        tasks: widget.tasks,
        onViewDepartmentTasks: widget.onViewDepartmentTasks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.events.where((e) {
      if (_selectedCategory == null) return true;
      return e.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: GwdColors.canvasLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parallel Events & Summits',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: GwdColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Flagships, workshops, & hackathons running in parallel',
                          style: TextStyle(
                              color: GwdColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  AppleBouncy(
                    scaleFactor: 0.92,
                    onTap: _showAiGenerator,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: GwdColors.obsidian,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: GwdColors.primaryRed.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GwdColors.primaryRed.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: GwdColors.primaryRed, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            'AI Architect',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: GwdColors.rubyLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DEV',
                              style: TextStyle(
                                color: GwdColors.primaryRed,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All Concepts'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                      selectedColor: GwdColors.obsidian,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null
                            ? Colors.white
                            : GwdColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...EventCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (val) => setState(
                            () => _selectedCategory = val ? cat : null),
                        selectedColor: GwdColors.obsidian,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : GwdColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final event = filtered[index];
                  final eventTasks =
                      widget.tasks.where((t) => t.eventId == event.id).toList();
                  final verifiedCount = eventTasks
                      .where((t) => t.status == TaskStatus.verified)
                      .length;
                  final progress = eventTasks.isNotEmpty
                      ? (verifiedCount / eventTasks.length).clamp(0.0, 1.0)
                      : 0.0;

                  return AppleStaggerItem(
                    index: index,
                    offsetY: 18,
                    child: AppleBouncy(
                      scaleFactor: 0.97,
                      onTap: () => _showEventDetail(event),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: GwdColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: event.category.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(event.category.icon,
                                          size: 14,
                                          color: event.category.color),
                                      const SizedBox(width: 5),
                                      Text(
                                        event.category.label.toUpperCase(),
                                        style: TextStyle(
                                          color: event.category.color,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined,
                                          size: 14, color: GwdColors.coral),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.countdownLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: GwdColors.coral,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: GwdColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.themeTagline,
                              style: const TextStyle(
                                  color: GwdColors.textSecondary, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 13, color: GwdColors.textMuted),
                                const SizedBox(width: 4),
                                Text(event.formattedDate,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: GwdColors.textSecondary)),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: GwdColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.venue,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: GwdColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Team Velocity: $verifiedCount/${eventTasks.length} tasks',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: GwdColors.textSecondary),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}% Done',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: GwdColors.emerald),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    GwdColors.emerald),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
