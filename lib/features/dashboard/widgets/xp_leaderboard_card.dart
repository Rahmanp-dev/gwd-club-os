import 'package:flutter/material.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/department.dart';
import '../../../core/models/member_profile.dart';

class XpLeaderboardCard extends StatelessWidget {
  const XpLeaderboardCard({
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

    final topMembers = sorted.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GwdColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GwdColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.military_tech_outlined, color: GwdColors.amber, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus-to-Corporate Value Scoreboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: GwdColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Verified outcome points & industry skill XP',
                      style: TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final rank = index + 1;

            return InkWell(
              onTap: () => onTapMember(member),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? GwdColors.amber.withValues(alpha: 0.2)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: rank == 1 ? GwdColors.amber : GwdColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: member.role.color.withValues(alpha: 0.18),
                      child: Text(
                        member.initials,
                        style: TextStyle(
                          color: member.role.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: GwdColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${member.role.shortBadge} · ${member.department.shortName}',
                            style: const TextStyle(
                              color: GwdColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${member.totalVerifiedPoints} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: GwdColors.primaryIndigo,
                          ),
                        ),
                        Text(
                          '${member.reliabilityRate.toStringAsFixed(1)}% Rel.',
                          style: const TextStyle(
                            fontSize: 10,
                            color: GwdColors.emerald,
                            fontWeight: FontWeight.w600,
                          ),
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
}
