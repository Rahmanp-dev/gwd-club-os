import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';

class DepartmentInterconnectCard extends StatelessWidget {
  const DepartmentInterconnectCard({
    super.key,
    required this.department,
    required this.tasks,
    required this.onTap,
  });

  final DepartmentType department;
  final List<ClubTask> tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deptTasks = tasks.where((t) => t.department == department).toList();
    final verified = deptTasks.where((t) => t.status == TaskStatus.verified).length;
    final blocked = deptTasks.where((t) => t.status == TaskStatus.blocked).length;
    final submitted = deptTasks.where((t) => t.status == TaskStatus.submitted).length;
    final total = deptTasks.length;

    final progress = total > 0 ? (verified / total).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: blocked > 0
                ? GwdColors.coral.withValues(alpha: 0.6)
                : GwdColors.line,
            width: blocked > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: department.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(department.icon, color: department.color, size: 20),
                ),
                const Spacer(),
                if (blocked > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: GwdColors.coral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$blocked BLOCKED',
                      style: const TextStyle(
                        color: GwdColors.coral,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (submitted > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: GwdColors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$submitted TO VERIFY',
                      style: const TextStyle(
                        color: GwdColors.purple,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: GwdColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$verified/$total DONE',
                      style: const TextStyle(
                        color: GwdColors.emerald,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              department.shortName,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: GwdColors.textPrimary,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              department.leadRole.title,
              style: const TextStyle(
                color: GwdColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(department.color),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
