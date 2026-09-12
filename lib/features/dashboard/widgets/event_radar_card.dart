import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_event.dart';

class EventRadarCard extends StatelessWidget {
  const EventRadarCard({
    super.key,
    required this.event,
    required this.completedTasks,
    required this.totalTasks,
    required this.onTap,
  });

  final ClubEvent event;
  final int completedTasks;
  final int totalTasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GwdColors.obsidian,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: GwdColors.primaryRed.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x33DC2626),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GwdColors.primaryRed),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: GwdColors.primaryRed, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        event.isFlagship ? 'FLAGSHIP INITIATIVE' : event.category.label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.amberAccent, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        event.countdownLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.themeTagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.6), size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    event.venue,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.people_alt_outlined, color: Colors.white.withValues(alpha: 0.6), size: 15),
                const SizedBox(width: 5),
                Text(
                  '${event.expectedFootfall} Attendees',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cross-Department Readiness',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completedTasks/$totalTasks verified ($pct%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(GwdColors.emerald),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
