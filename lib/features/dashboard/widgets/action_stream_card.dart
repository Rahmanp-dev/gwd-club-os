import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';

class ActionStreamCard extends StatelessWidget {
  const ActionStreamCard({
    super.key,
    required this.task,
    required this.viewerRole,
    required this.onTap,
    required this.onQuickAction,
  });

  final ClubTask task;
  final ClubRole viewerRole;
  final VoidCallback onTap;
  final VoidCallback onQuickAction;

  @override
  Widget build(BuildContext context) {
    final isSubmitted = task.status == TaskStatus.submitted;
    final isOwner = task.assigneeRole == viewerRole;
    final canVerify = viewerRole.canVerifyTasks && isSubmitted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSubmitted ? GwdColors.purple.withValues(alpha: 0.35) : GwdColors.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.department.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.department.shortName.toUpperCase(),
                      style: TextStyle(
                        color: task.department.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.status.label.toUpperCase(),
                      style: TextStyle(
                        color: task.status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${task.points} PTS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: GwdColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: GwdColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: GwdColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${task.assigneeName} (${task.assigneeRole.shortBadge})',
                    style: const TextStyle(color: GwdColors.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 14, color: GwdColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    task.dueLabel,
                    style: const TextStyle(color: GwdColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              if (task.proof != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: GwdColors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.proof!,
                          style: const TextStyle(fontSize: 12, color: GwdColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Skill: ${task.corporateValueSkill}',
                      style: const TextStyle(
                        color: GwdColors.textMuted,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canVerify)
                    FilledButton.icon(
                      onPressed: onQuickAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: GwdColors.emerald,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Verify Proof', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    )
                  else if (isOwner && task.status == TaskStatus.inProgress)
                    OutlinedButton.icon(
                      onPressed: onQuickAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GwdColors.primaryIndigo,
                        side: const BorderSide(color: GwdColors.primaryIndigo),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.upload_file_outlined, size: 16),
                      label: const Text('Submit Proof', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    )
                  else if (isOwner && task.status == TaskStatus.requested)
                    FilledButton.icon(
                      onPressed: onQuickAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: GwdColors.primaryIndigo,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
