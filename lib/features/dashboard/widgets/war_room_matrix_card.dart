import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';

class WarRoomMatrixCard extends StatelessWidget {
  const WarRoomMatrixCard({
    super.key,
    required this.tasks,
    required this.onNudgeDepartment,
  });

  final List<ClubTask> tasks;
  final void Function(DepartmentType dept, String reason) onNudgeDepartment;

  @override
  Widget build(BuildContext context) {
    final blockedTasks = tasks.where((t) => t.status == TaskStatus.blocked).toList();
    final submittedTasks = tasks.where((t) => t.status == TaskStatus.submitted).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GwdColors.obsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: GwdColors.primaryRed.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33DC2626),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hub_outlined, color: GwdColors.primaryRed, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE WAR ROOM & HANDSHAKE MESH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Real-time dependency signals across all chapter leads',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GwdColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: GwdColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LIVE MESH',
                      style: TextStyle(color: GwdColors.emerald, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Inter-Department Nodes Representation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Column(
              children: [
                // Top Core: Executive Board
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNodeBadge('EXEC BOARD', GwdColors.primaryRed, Icons.military_tech_outlined),
                    const SizedBox(width: 8),
                    Container(width: 30, height: 1.5, color: const Color(0xFF3F3F46)),
                    const SizedBox(width: 8),
                    _buildNodeBadge('GWD GLOBAL', GwdColors.primaryRed, Icons.shield),
                  ],
                ),

                const SizedBox(height: 12),
                Container(width: 1.5, height: 20, color: const Color(0xFF3F3F46)),
                const SizedBox(height: 12),

                // Department Orbit
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: DepartmentType.values.where((d) => d != DepartmentType.executive).map((dept) {
                    final deptBlocked = blockedTasks.any((t) => t.department == dept);
                    final deptSubmitted = submittedTasks.any((t) => t.department == dept);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: deptBlocked
                              ? GwdColors.primaryRed
                              : (deptSubmitted ? GwdColors.primaryRed : dept.color.withValues(alpha: 0.6)),
                          width: deptBlocked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(dept.icon, size: 14, color: deptBlocked ? GwdColors.primaryRed : dept.color),
                          const SizedBox(width: 6),
                          Text(
                            dept.shortName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (deptBlocked) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.error, size: 12, color: GwdColors.primaryRed),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Active Critical Handshakes
          const Text(
            'ACTIVE INTER-LEAD HANDSHAKES',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          _buildHandshakeRow(
            fromLead: 'PR Lead (Tuba)',
            toLead: 'Creative Lead (Nishta)',
            detail: 'Title sponsor vector logo lockups & VIP pass branding',
            isBlocked: false,
          ),
          const SizedBox(height: 8),
          _buildHandshakeRow(
            fromLead: 'Cinema Lead (Burhan)',
            toLead: 'Event Ops (Bhavya)',
            detail: 'Auditorium stage layout coordinates for multi-cam',
            isBlocked: true,
            onNudge: () => onNudgeDepartment(DepartmentType.eventManagement, 'Camera coordinates needed immediately for video crew.'),
          ),
          const SizedBox(height: 8),
          _buildHandshakeRow(
            fromLead: 'Marketing Lead (Anvitha)',
            toLead: 'Gen Secretary (Sravya)',
            detail: 'Dean administrative clearance for campus poster displays',
            isBlocked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNodeBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHandshakeRow({
    required String fromLead,
    required String toLead,
    required String detail,
    required bool isBlocked,
    VoidCallback? onNudge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isBlocked ? GwdColors.primaryRed.withValues(alpha: 0.5) : const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Icon(
            isBlocked ? Icons.warning_amber_rounded : Icons.sync_alt,
            size: 16,
            color: isBlocked ? GwdColors.primaryRed : GwdColors.primaryRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(fromLead, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 10, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(toLead, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(color: isBlocked ? const Color(0xFFFDA4AF) : Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          if (isBlocked && onNudge != null)
            TextButton(
              onPressed: onNudge,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: GwdColors.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('NUDGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
