import 'package:flutter/material.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import '../../core/models/department.dart';
import '../../core/models/member_profile.dart';

class TeamHierarchyPage extends StatelessWidget {
  const TeamHierarchyPage({
    super.key,
    required this.members,
    required this.activeRole,
    required this.onSwitchRole,
  });

  final List<MemberProfile> members;
  final ClubRole activeRole;
  final void Function(ClubRole role) onSwitchRole;

  @override
  Widget build(BuildContext context) {
    final execMembers =
        members.where((m) => m.department == DepartmentType.executive).toList();
    final nonExecDepartments = DepartmentType.values
        .where((d) => d != DepartmentType.executive)
        .toList();

    return Scaffold(
      backgroundColor: GwdColors.canvasLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: GwdColors.obsidian,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: GwdColors.primaryRed.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: GwdColors.primaryRed.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: GwdColors.rubyLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: GwdColors.primaryRed.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'GWD GLOBAL SUPERVISION',
                          style: TextStyle(
                              color: GwdColors.primaryRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified,
                          color: GwdColors.primaryRed, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Campus-to-Corporate Hierarchy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multi-tier coordination: Executive Board -> Department Leads -> Crew Members. Tap any role to simulate their viewpoint.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'EXECUTIVE BOARD',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GwdColors.textSecondary,
                  letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),
            ...execMembers.map((member) => _buildMemberCard(context, member)),
            const SizedBox(height: 24),
            const Text(
              'DEPARTMENT LEADS & CREW',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GwdColors.textSecondary,
                  letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),
            ...nonExecDepartments.map((dept) {
              final deptMembers =
                  members.where((m) => m.department == dept).toList();
              final lead = deptMembers.where((m) => m.role.isLead).firstOrNull;
              final crew = deptMembers.where((m) => !m.role.isLead).toList();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GwdColors.line),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: dept.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(dept.icon, color: dept.color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dept.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: GwdColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      if (lead != null) ...[
                        const SizedBox(height: 12),
                        _buildMemberCard(context, lead, isCompact: true),
                      ],
                      if (crew.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            'Department Crew (${crew.length})',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GwdColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...crew.map((cm) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, bottom: 8),
                              child: _buildMemberCard(context, cm,
                                  isCompact: true),
                            )),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberProfile member,
      {bool isCompact = false}) {
    final isActive = member.role == activeRole;

    return AppleBouncy(
      scaleFactor: 0.96,
      onTap: () => onSwitchRole(member.role),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: isActive
              ? GwdColors.rubyLight
              : (isCompact ? const Color(0xFFF8FAFC) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? GwdColors.primaryRed : GwdColors.line,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isCompact ? 16 : 20,
                  backgroundColor: member.role.color.withValues(alpha: 0.18),
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: member.role.color,
                      fontWeight: FontWeight.w800,
                      fontSize: isCompact ? 11 : 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: isCompact ? 13 : 15,
                                color: GwdColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: member.role.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.role.shortBadge,
                              style: TextStyle(
                                color: member.role.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.yearAndMajor,
                        style: const TextStyle(
                            color: GwdColors.textSecondary, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
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
                          color: GwdColors.primaryRed),
                    ),
                    Text(
                      '${member.reliabilityRate.toStringAsFixed(1)}% Rel.',
                      style: const TextStyle(
                          fontSize: 10,
                          color: GwdColors.emerald,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            if (member.corporateSkillsEarned.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: member.corporateSkillsEarned.entries.map((entry) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      '${entry.key} +${entry.value}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: GwdColors.textPrimary),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  member.role.title,
                  style: TextStyle(
                       fontSize: 11,
                      color: member.role.color,
                      fontWeight: FontWeight.w700),
                ),
                if (!isActive)
                  TextButton.icon(
                    onPressed: () => onSwitchRole(member.role),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.switch_account_outlined, size: 14),
                    label: const Text('Simulate View',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GwdColors.primaryRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CURRENT VIEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800),
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
