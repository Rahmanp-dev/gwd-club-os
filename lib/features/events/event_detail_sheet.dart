import 'package:flutter/material.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';

class EventDetailSheet extends StatelessWidget {
  const EventDetailSheet({
    super.key,
    required this.event,
    required this.tasks,
    required this.onViewDepartmentTasks,
  });

  final ClubEvent event;
  final List<ClubTask> tasks;
  final void Function(DepartmentType department) onViewDepartmentTasks;

  @override
  Widget build(BuildContext context) {
    final eventTasks = tasks.where((t) => t.eventId == event.id).toList();
    final verifiedCount = eventTasks.where((t) => t.status == TaskStatus.verified).length;
    final progress = eventTasks.isNotEmpty ? (verifiedCount / eventTasks.length).clamp(0.0, 1.0) : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.category.label.toUpperCase(),
                    style: TextStyle(
                      color: event.category.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: GwdColors.line),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GwdColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.themeTagline,
                    style: const TextStyle(color: GwdColors.textSecondary, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: GwdColors.primaryIndigo),
                            const SizedBox(width: 8),
                            Text(
                              event.formattedDate,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: GwdColors.coral.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.countdownLabel,
                                style: const TextStyle(
                                  color: GwdColors.coral,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: GwdColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.venue,
                                style: const TextStyle(color: GwdColors.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: GwdColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              '${event.expectedFootfall} Expected Attendees',
                              style: const TextStyle(color: GwdColors.textSecondary, fontSize: 12),
                            ),
                            const Spacer(),
                            const Icon(Icons.account_balance_wallet_outlined, size: 16, color: GwdColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              event.budgetLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Readiness & Task Velocity',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '$verifiedCount/${eventTasks.length} Done (${(progress * 100).toInt()}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GwdColors.primaryIndigo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(GwdColors.emerald),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Department Synchronization',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ...DepartmentType.values.map((dept) {
                    final deptTasks = eventTasks.where((t) => t.department == dept).toList();
                    if (deptTasks.isEmpty) return const SizedBox.shrink();
                    final deptVerified = deptTasks.where((t) => t.status == TaskStatus.verified).length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: GwdColors.line),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: dept.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(dept.icon, color: dept.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dept.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Text(
                                  '$deptVerified/${deptTasks.length} tasks completed',
                                  style: const TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onViewDepartmentTasks(dept);
                            },
                            child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (event.runOfShow.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Master Run of Show (Day of Event)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    ...event.runOfShow.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GwdColors.obsidian,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.time,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(
                                    '${item.department} · ${item.ownerName}',
                                    style: const TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                                  ),
                                  if (item.notes != null)
                                    Text(
                                      'Note: ${item.notes!}',
                                      style: const TextStyle(color: GwdColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
