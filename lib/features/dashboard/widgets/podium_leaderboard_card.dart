import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/department.dart';
import '../../../core/models/member_profile.dart';

class PodiumLeaderboardCard extends StatelessWidget {
  const PodiumLeaderboardCard({
    super.key,
    required this.members,
    required this.onTapMember,
  });

  final List<MemberProfile> members;
  final void Function(MemberProfile member) onTapMember;

  @override
  Widget build(BuildContext context) {
    final sorted = List<MemberProfile>.from(members)
      ..sort((a, b) => b.totalVerifiedPoints.compareTo(a.totalVerifiedPoints));

    final top3 = sorted.take(3).toList();
    final remaining = sorted.skip(3).take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GwdColors.obsidian,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: GwdColors.primaryRed.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Leaders & Crew',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Campus-to-Corporate Verified Impact',
                    style: TextStyle(color: GwdColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GwdColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GwdColors.amber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: GwdColors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'TIER-1 RANK',
                      style: TextStyle(color: GwdColors.amber, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // PODIUM STAGE (Rank 2 - Silver, Rank 1 - Gold Center, Rank 3 - Bronze)
          if (top3.length >= 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Rank 2 (Silver)
                _buildPodiumPillar(
                  member: top3[1],
                  rank: 2,
                  badgeColor: const Color(0xFF94A3B8),
                  height: 120,
                  rating: '4.9',
                  onTap: () => onTapMember(top3[1]),
                ),

                // Rank 1 (Gold) - Elevated Center
                _buildPodiumPillar(
                  member: top3[0],
                  rank: 1,
                  badgeColor: const Color(0xFFFBBF24),
                  height: 148,
                  rating: '5.0',
                  isGold: true,
                  onTap: () => onTapMember(top3[0]),
                ),

                // Rank 3 (Bronze)
                _buildPodiumPillar(
                  member: top3[2],
                  rank: 3,
                  badgeColor: const Color(0xFFD97706),
                  height: 108,
                  rating: '4.9',
                  onTap: () => onTapMember(top3[2]),
                ),
              ],
            ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 12),

          // Honor Roll List (from UI reference)
          ...remaining.map((m) {
            return InkWell(
              onTap: () => onTapMember(m),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: m.role.color.withValues(alpha: 0.2),
                      child: Text(
                        m.initials,
                        style: TextStyle(color: m.role.color, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            '${m.role.title} · ${m.department.shortName}',
                            style: const TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: GwdColors.amber),
                        const SizedBox(width: 4),
                        Text(
                          (m.reliabilityRate / 20).toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${m.totalVerifiedPoints} XP',
                          style: const TextStyle(color: GwdColors.primaryRed, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar({
    required MemberProfile member,
    required int rank,
    required Color badgeColor,
    required double height,
    required String rating,
    bool isGold = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: isGold ? 64 : 52,
                height: isGold ? 64 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor, width: isGold ? 2.5 : 2),
                  boxShadow: isGold
                      ? [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF18181B),
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: isGold ? 16 : 13,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 12, color: GwdColors.amber),
              const SizedBox(width: 2),
              Text(
                rating,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            member.name.split(' ').first,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Text(
            '${member.totalVerifiedPoints} XP',
            style: TextStyle(color: isGold ? GwdColors.amber : GwdColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          // Gradient Pillar base
          Container(
            width: 72,
            height: isGold ? 48 : 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: 0.3),
                  badgeColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
