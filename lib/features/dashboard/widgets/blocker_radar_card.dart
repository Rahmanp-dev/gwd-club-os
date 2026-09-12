import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';

class BlockerRadarCard extends StatelessWidget {
  const BlockerRadarCard({
    super.key,
    required this.blockedTasks,
    required this.onNudge,
    required this.onResolve,
  });

  final List<ClubTask> blockedTasks;
  final void Function(ClubTask task) onNudge;
  final void Function(ClubTask task) onResolve;

  @override
  Widget build(BuildContext context) {
    if (blockedTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GwdColors.emerald.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GwdColors.emerald.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: GwdColors.emerald, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Blockers Across Departments',
                    style: TextStyle(
                      color: GwdColors.emerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'All inter-lead handshakes and milestones are progressing smoothly.',
                    style: TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: blockedTasks.map((task) {
        final blockingDept = task.blockedByDepartment;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2), // Pale red
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: GwdColors.coral.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: GwdColors.coral, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${task.department.shortName.toUpperCase()} BLOCKED',
                    style: const TextStyle(
                      color: GwdColors.coral,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  if (blockingDept != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 12, color: GwdColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Waiting on ${blockingDept.displayName}',
                      style: const TextStyle(
                        color: GwdColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: GwdColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: GwdColors.coral),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.blocker ?? 'Blocker details unspecified.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9F1239),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onNudge(task),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GwdColors.coral,
                      side: const BorderSide(color: GwdColors.coral),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.notifications_active_outlined, size: 14),
                    label: const Text('Nudge Lead', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => onResolve(task),
                    style: FilledButton.styleFrom(
                      backgroundColor: GwdColors.obsidian,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Mark Resolved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
