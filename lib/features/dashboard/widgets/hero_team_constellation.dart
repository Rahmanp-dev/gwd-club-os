import 'package:flutter/material.dart';
import '../../../app/theme/apple_motion.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/member_profile.dart';

class HeroTeamConstellation extends StatelessWidget {
  const HeroTeamConstellation({
    super.key,
    required this.activeRole,
    required this.members,
    required this.overallEfficiency,
    required this.onTapMember,
  });

  final ClubRole activeRole;
  final List<MemberProfile> members;
  final int overallEfficiency;
  final void Function(MemberProfile member) onTapMember;

  @override
  Widget build(BuildContext context) {
    final activeMember = members.where((m) => m.role == activeRole).firstOrNull ?? members.first;
    final otherMembers = members.where((m) => m.role != activeRole).take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: GwdColors.obsidian,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: GwdColors.primaryRed.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cute Live Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: GwdColors.emerald,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: GwdColors.emerald, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE CHAPTER CONSTELLATION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Constellation: Floating Orbits with Halo & Apple Motion
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient pulsating glow behind central avatar
                AppleFloat(
                  offsetY: 3.0,
                  duration: const Duration(milliseconds: 2800),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeRole.color.withValues(alpha: 0.45),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),

                // Orbit 1: Top Left (Floating with bounce)
                if (otherMembers.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 20,
                    child: AppleFloat(
                      offsetY: 6.0,
                      duration: const Duration(milliseconds: 2200),
                      child: _buildOrbiter(otherMembers[0]),
                    ),
                  ),

                // Orbit 2: Top Right
                if (otherMembers.length > 1)
                  Positioned(
                    top: 16,
                    right: 22,
                    child: AppleFloat(
                      offsetY: 5.0,
                      duration: const Duration(milliseconds: 2600),
                      child: _buildOrbiter(otherMembers[1]),
                    ),
                  ),

                // Orbit 3: Bottom Left
                if (otherMembers.length > 2)
                  Positioned(
                    bottom: 12,
                    left: 30,
                    child: AppleFloat(
                      offsetY: 4.5,
                      duration: const Duration(milliseconds: 2400),
                      child: _buildOrbiter(otherMembers[2]),
                    ),
                  ),

                // Orbit 4: Bottom Right
                if (otherMembers.length > 3)
                  Positioned(
                    bottom: 15,
                    right: 28,
                    child: AppleFloat(
                      offsetY: 5.5,
                      duration: const Duration(milliseconds: 2900),
                      child: _buildOrbiter(otherMembers[3]),
                    ),
                  ),

                // Central Active Leader Avatar with Apple Pulse Halo & Bouncy interaction
                AppleBouncy(
                  scaleFactor: 0.94,
                  onTap: () => onTapMember(activeMember),
                  child: ApplePulseRing(
                    glowColor: activeRole.color,
                    maxBlur: 28,
                    maxSpread: 6,
                    child: Container(
                      width: 98,
                      height: 98,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: activeRole.color, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: activeRole.color.withValues(alpha: 0.7),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF18181B),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(activeRole.icon, color: Colors.white, size: 28),
                            const SizedBox(height: 2),
                            Text(
                              activeMember.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 8),

          // Team Overview Title
          Text(
            '${activeRole.departmentName.toUpperCase()} CONSOLE',
            style: const TextStyle(
              color: GwdColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activeMember.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 18),

          // Big Performance Score Row (inspired directly by 79% in UI reference)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$overallEfficiency%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team',
                    style: TextStyle(color: GwdColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Performance Score',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Spectrum Frequency Wave (from UI reference)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SpectrumFrequencyBar(
              progress: (overallEfficiency / 100).clamp(0.0, 1.0),
              barCount: 36,
              height: 38,
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Execution velocity',
                  style: TextStyle(color: GwdColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Sprint Reliability: $overallEfficiency%',
                  style: const TextStyle(color: GwdColors.emerald, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Frosted Glass Folder Tab Card (from UI reference)
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF141418),
            borderColor: const Color(0xFF27272A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: activeRole.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeRole.shortBadge,
                        style: TextStyle(color: activeRole.color, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Accountability Metrics',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.tune, color: GwdColors.textSecondary, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Communication', '9.4', GwdColors.neonCyan),
                    _buildStatItem('Ownership', '9.1', GwdColors.primaryRed),
                    _buildStatItem('Velocity', '8.8', GwdColors.amber),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPillStat(Icons.people_outline, '${members.length} Leads & Crew'),
                    _buildPillStat(Icons.verified_outlined, '${activeMember.totalVerifiedPoints} XP Verified'),
                    _buildPillStat(Icons.offline_bolt_outlined, '${activeMember.reliabilityRate}% Reliability'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbiter(MemberProfile member) {
    return AppleBouncy(
      scaleFactor: 0.90,
      onTap: () => onTapMember(member),
      child: Tooltip(
        message: '${member.name} (${member.role.shortBadge})',
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: member.role.color.withValues(alpha: 0.85), width: 2),
            boxShadow: [
              BoxShadow(
                color: member.role.color.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF18181B),
            child: Text(
              member.initials,
              style: TextStyle(
                color: member.role.color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: GwdColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPillStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: GwdColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
