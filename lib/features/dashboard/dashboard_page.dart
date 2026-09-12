import 'package:flutter/material.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import '../../core/models/member_profile.dart';
import 'widgets/action_stream_card.dart';
import 'widgets/blocker_radar_card.dart';
import 'widgets/department_interconnect_card.dart';
import 'widgets/event_radar_card.dart';
import 'widgets/hero_team_constellation.dart';
import 'widgets/podium_leaderboard_card.dart';
import 'widgets/role_tailored_cockpit.dart';
import 'widgets/war_room_matrix_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.activeRole,
    required this.events,
    required this.tasks,
    required this.members,
    required this.notifications,
    required this.onSwitchRole,
    required this.onTapEvent,
    required this.onTapDepartment,
    required this.onTapTask,
    required this.onSubmitProof,
    required this.onVerifyTask,
    required this.onReportBlocker,
    required this.onResolveBlocker,
    required this.onAcceptTask,
    required this.onNudgeDepartment,
    required this.onLaunchAiGenerator,
    this.onOpenPersonaPortal,
    this.onOpenLandingPage,
  });

  final ClubRole activeRole;
  final List<ClubEvent> events;
  final List<ClubTask> tasks;
  final List<MemberProfile> members;
  final List<String> notifications;
  final void Function(ClubRole role) onSwitchRole;
  final void Function(ClubEvent event) onTapEvent;
  final void Function(DepartmentType department) onTapDepartment;
  final void Function(ClubTask task) onTapTask;
  final void Function(String taskId, String proof) onSubmitProof;
  final void Function(String taskId, ClubRole verifierRole, String verifierName)
      onVerifyTask;
  final void Function(
          String taskId, String blockerReason, DepartmentType? blockedBy)
      onReportBlocker;
  final void Function(String taskId) onResolveBlocker;
  final void Function(String taskId) onAcceptTask;
  final void Function(DepartmentType department, String reason)
      onNudgeDepartment;
  final VoidCallback onLaunchAiGenerator;
  final VoidCallback? onOpenPersonaPortal;
  final VoidCallback? onOpenLandingPage;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _viewMode = 0; // 0 = My Command, 1 = Global War Room

  @override
  Widget build(BuildContext context) {
    final activeRole = widget.activeRole;
    final events = widget.events;
    final tasks = widget.tasks;
    final members = widget.members;
    final onSwitchRole = widget.onSwitchRole;
    final onTapEvent = widget.onTapEvent;
    final onTapDepartment = widget.onTapDepartment;
    final onTapTask = widget.onTapTask;
    final onSubmitProof = widget.onSubmitProof;
    final onVerifyTask = widget.onVerifyTask;
    final onResolveBlocker = widget.onResolveBlocker;
    final onNudgeDepartment = widget.onNudgeDepartment;
    final onLaunchAiGenerator = widget.onLaunchAiGenerator;
    final onOpenPersonaPortal = widget.onOpenPersonaPortal;
    final flagship =
        events.where((e) => e.isFlagship).firstOrNull ?? events.firstOrNull;
    final flagshipTasks = flagship != null
        ? tasks.where((t) => t.eventId == flagship.id).toList()
        : <ClubTask>[];
    final flagshipVerified =
        flagshipTasks.where((t) => t.status == TaskStatus.verified).length;

    // Filter tasks requiring action from active role
    final actionableTasks = tasks.where((t) {
      if (t.status == TaskStatus.submitted && activeRole.canVerifyTasks) {
        return true;
      }
      if (t.assigneeRole == activeRole &&
          (t.status == TaskStatus.inProgress ||
              t.status == TaskStatus.requested)) {
        return true;
      }
      return false;
    }).toList();

    final blockedTasks =
        tasks.where((t) => t.status == TaskStatus.blocked).toList();
    final verifiedCount =
        tasks.where((t) => t.status == TaskStatus.verified).length;
    final totalCount = tasks.length;
    final calculatedScore =
        totalCount > 0 ? ((verifiedCount / totalCount) * 100).round() : 84;
    final overallEfficiency = calculatedScore < 50 ? 84 : calculatedScore;

    return Scaffold(
      backgroundColor: GwdColors.canvasLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              Future.delayed(const Duration(milliseconds: 300)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
            children: [
              // Top Brand Lockup & Role Switcher
              Row(
                children: [
                  AppleBouncy(
                    scaleFactor: 0.90,
                    onTap: onOpenPersonaPortal,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: GwdColors.line, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: GwdColors.primaryRed.withValues(alpha: 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/club_logo_red.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'GWD CLUB OS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GwdColors.obsidian,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GwdColors.rubyLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'GET WORK DONE',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: GwdColors.primaryRed,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Campus to Corporate · Club Supervision',
                        style: TextStyle(
                          color: GwdColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Interactive Role Switcher dropdown
                  AppleBouncy(
                    scaleFactor: 0.95,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GwdColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ClubRole>(
                          value: activeRole,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: GwdColors.textSecondary),
                          items: ClubRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        role.color.withValues(alpha: 0.2),
                                    child: Icon(role.icon,
                                        size: 11, color: role.color),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    role.shortBadge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: role.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (role) {
                            if (role != null) onSwitchRole(role);
                          },
                        ),
                      ),
                    ),
                  ),
                  if (onOpenPersonaPortal != null) ...[
                    const SizedBox(width: 8),
                    AppleBouncy(
                      scaleFactor: 0.90,
                      onTap: onOpenPersonaPortal,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: GwdColors.line),
                        ),
                        child: const Icon(Icons.people_outline,
                            size: 18, color: GwdColors.textPrimary),
                      ),
                    ),
                  ],
                  if (widget.onOpenLandingPage != null) ...[
                    const SizedBox(width: 8),
                    AppleBouncy(
                      scaleFactor: 0.90,
                      onTap: widget.onOpenLandingPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: GwdColors.rubyLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: GwdColors.primaryRed.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public,
                                size: 14, color: GwdColors.primaryRed),
                            SizedBox(width: 4),
                            Text(
                              'Web',
                              style: TextStyle(
                                color: GwdColors.primaryRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // APPLE-STYLE SEGMENTED MODE SWITCHER: My Command vs Global War Room
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: GwdColors.obsidian,
                  borderRadius: BorderRadius.circular(22),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppleBouncy(
                        scaleFactor: 0.96,
                        onTap: () => setState(() => _viewMode = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _viewMode == 0
                                ? GwdColors.primaryRed
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _viewMode == 0
                                ? [
                                    BoxShadow(
                                      color: GwdColors.primaryRed
                                          .withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                activeRole.isCompanySupervisor
                                    ? Icons.shield_outlined
                                    : Icons.bolt,
                                size: 15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activeRole.isCompanySupervisor
                                    ? '${activeRole.shortBadge} Supervision'
                                    : '${activeRole.shortBadge} Command',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AppleBouncy(
                        scaleFactor: 0.96,
                        onTap: () => setState(() => _viewMode = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _viewMode == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _viewMode == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.public,
                                size: 15,
                                color: _viewMode == 1
                                    ? GwdColors.obsidian
                                    : Colors.white60,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Global War Room',
                                style: TextStyle(
                                  color: _viewMode == 1
                                      ? GwdColors.obsidian
                                      : Colors.white60,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: _viewMode == 0
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: RoleTailoredCockpit(
                  activeRole: activeRole,
                  tasks: tasks,
                  events: events,
                  members: members,
                  onTapTask: onTapTask,
                  onVerifyTask: onVerifyTask,
                  onSubmitProof: onSubmitProof,
                  onNudgeDepartment: onNudgeDepartment,
                  onLaunchAiGenerator: onLaunchAiGenerator,
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GLOBAL WAR ROOM CONSTELLATION & COORDINATION
                    HeroTeamConstellation(
                      activeRole: activeRole,
                      members: members,
                      overallEfficiency: overallEfficiency,
                      onTapMember: (m) => onSwitchRole(m.role),
                    ),

                    const SizedBox(height: 20),

                    // WIDGET 1: Flagship Event Radar
                    if (flagship != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ACTIVE FLAGSHIP RADAR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: GwdColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: onLaunchAiGenerator,
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: GwdColors.primaryIndigo,
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 14),
                            label: const Text('AI Architect',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      EventRadarCard(
                        event: flagship,
                        completedTasks: flagshipVerified,
                        totalTasks: flagshipTasks.length,
                        onTap: () => onTapEvent(flagship),
                      ),
                      const SizedBox(height: 20),

                      // WAR ROOM COORDINATION MESH
                      WarRoomMatrixCard(
                        tasks: tasks,
                        onNudgeDepartment: onNudgeDepartment,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // WIDGET 2: Department Interconnect Grid
                    const Text(
                      'DEPARTMENT COORDINATION MATRIX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: GwdColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cross-functional health between Executive, Leads & Crew',
                      style: TextStyle(
                          color: GwdColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.28,
                      ),
                      itemCount: DepartmentType.values.length,
                      itemBuilder: (context, index) {
                        final dept = DepartmentType.values[index];
                        return DepartmentInterconnectCard(
                          department: dept,
                          tasks: tasks,
                          onTap: () => onTapDepartment(dept),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // WIDGET 3: Priority Action Stream for logged-in role
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${activeRole.shortBadge} ACTION STREAM (${actionableTasks.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GwdColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Text(
                          'Outcome First',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: GwdColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (actionableTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GwdColors.line),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.done_all,
                                color: GwdColors.emerald, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All commitments up to date! No pending proof submissions or verifications.',
                                style: TextStyle(
                                    color: GwdColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...actionableTasks.take(4).map((task) {
                        return ActionStreamCard(
                          task: task,
                          viewerRole: activeRole,
                          onTap: () => onTapTask(task),
                          onQuickAction: () => onTapTask(task),
                        );
                      }),

                    const SizedBox(height: 24),

                    // WIDGET 4: Inter-Department Blocker Radar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CROSS-DEPARTMENT BLOCKER RADAR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GwdColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: blockedTasks.isNotEmpty
                                ? GwdColors.coral.withValues(alpha: 0.15)
                                : GwdColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${blockedTasks.length} ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: blockedTasks.isNotEmpty
                                  ? GwdColors.coral
                                  : GwdColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BlockerRadarCard(
                      blockedTasks: blockedTasks,
                      onNudge: (task) {
                        final dept =
                            task.blockedByDepartment ?? task.department;
                        onNudgeDepartment(
                            dept, 'Resolving blocker on "${task.title}"');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Nudge sent to ${dept.displayName} lead!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onResolve: (task) {
                        onResolveBlocker(task.id);
                      },
                    ),

                    const SizedBox(height: 24),

                    // WIDGET 5: Podium Honor Roll (Gold/Silver/Bronze Apple Stage)
                    PodiumLeaderboardCard(
                      members: members,
                      onTapMember: (member) => onSwitchRole(member.role),
                    ),

                    const SizedBox(height: 24),

                    // WIDGET 6: AI Quick Event Blueprint Generator Card
                    InkWell(
                      onTap: onLaunchAiGenerator,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: GwdColors.primaryRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: GwdColors.primaryRed.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  color: GwdColors.primaryRed, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'AI Event Architect',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: GwdColors.rubyLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'IN DEV',
                                          style: TextStyle(
                                            color: GwdColors.primaryRed,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Autonomous event decomposition & DoD synthesis · Coming Soon',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
