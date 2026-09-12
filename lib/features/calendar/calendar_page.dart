import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.events,
    required this.tasks,
    required this.onTapTask,
  });

  final List<ClubEvent> events;
  final List<ClubTask> tasks;
  final void Function(ClubTask task) onTapTask;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Tasks on selected date
    final selectedDayTasks = widget.tasks.where((t) {
      return t.dueDate.year == _selectedDate.year &&
          t.dueDate.month == _selectedDate.month &&
          t.dueDate.day == _selectedDate.day;
    }).toList();

    // Events on selected date
    final selectedDayEvents = widget.events.where((e) {
      return e.targetDate.year == _selectedDate.year &&
          e.targetDate.month == _selectedDate.month &&
          e.targetDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 100),
          children: [
            // Top Apple SF Header with Search and Plus
            Row(
              children: [
                const Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: GwdColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                AppleBouncy(
                  scaleFactor: 0.90,
                  onTap: () {},
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: GwdColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.search,
                        size: 18, color: GwdColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                AppleBouncy(
                  scaleFactor: 0.90,
                  onTap: () => setState(() => _selectedDate = DateTime.now()),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: GwdColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add,
                        size: 20, color: GwdColors.textPrimary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Apple Month Card (from UI reference 1)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: GwdColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month Name & Dropdown pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GwdColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'This Month',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GwdColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                size: 14, color: GwdColors.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Weekday Header: M T W T F S S
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .map((day) => SizedBox(
                              width: 32,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GwdColors.textMuted,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 10),

                  // Month Dates Grid
                  _buildMonthGrid(now),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Today / Deliverables Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSameDay(_selectedDate, now)
                      ? 'Today'
                      : DateFormat('EEE, MMM d').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: GwdColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selectedDayTasks.length + selectedDayEvents.length} Items',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GwdColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Schedule Cards matching UI reference 1
            if (selectedDayEvents.isEmpty && selectedDayTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: GwdColors.line),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GwdColors.emerald.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: GwdColors.emerald, size: 28),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'All clear for this date',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: GwdColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap other calendar dates above to inspect chapter runs.',
                        style: TextStyle(
                            fontSize: 11, color: GwdColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              ...selectedDayEvents.map((e) => _buildEventScheduleCard(e)),
              ...selectedDayTasks.map((t) => _buildTaskScheduleCard(t)),
            ],

            const SizedBox(height: 20),

            // Upcoming Milestones
            const Text(
              'Upcoming Flagship Milestones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: GwdColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.events.map((e) => _buildMilestoneTile(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(DateTime now) {
    // Generate dates for current selected month
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    // Weekday offset (Monday = 1, Sunday = 7)
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;

    final cells = <Widget>[];

    // Empty offset cells
    for (var i = 0; i < startOffset; i++) {
      cells.add(const SizedBox(width: 34, height: 34));
    }

    // Days in month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, now);

      final hasEvent = widget.events.any((e) => _isSameDay(e.targetDate, date));
      final hasTask = widget.tasks.any((t) => _isSameDay(t.dueDate, date));

      cells.add(
        AppleBouncy(
          scaleFactor: 0.88,
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? GwdColors.primaryRed
                  : (isToday ? GwdColors.rubyLight : Colors.transparent),
              border: isToday && !isSelected
                  ? Border.all(color: GwdColors.primaryRed, width: 1.5)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w900
                        : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isToday
                            ? GwdColors.primaryRed
                            : GwdColors.textPrimary),
                  ),
                ),
                if ((hasEvent || hasTask) && !isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasEvent ? GwdColors.primaryRed : GwdColors.emerald,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      alignment: WrapAlignment.spaceAround,
      children: cells,
    );
  }

  Widget _buildEventScheduleCard(ClubEvent event) {
    return AppleBouncy(
      scaleFactor: 0.97,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GwdColors.primaryRed, GwdColors.rubyDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.videocam_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: GwdColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.venue} · Run-of-Show Staging',
                    style: const TextStyle(
                        fontSize: 11, color: GwdColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GwdColors.obsidian,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '4:30 PM',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskScheduleCard(ClubTask task) {
    return AppleBouncy(
      scaleFactor: 0.97,
      onTap: () => widget.onTapTask(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: task.department.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(task.department.icon,
                  color: task.department.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: GwdColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${task.assigneeName} (${task.assigneeRole.shortBadge}) · ${task.status.label}',
                    style: TextStyle(
                        fontSize: 11,
                        color: task.status.color,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GwdColors.obsidian,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                task.dueLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneTile(ClubEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GwdColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(event.category.icon,
                size: 18, color: event.category.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text('${event.formattedDate} · ${event.venue}',
                    style: const TextStyle(
                        fontSize: 11, color: GwdColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GwdColors.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.countdownLabel,
              style: const TextStyle(
                  color: GwdColors.coral,
                  fontSize: 11,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
