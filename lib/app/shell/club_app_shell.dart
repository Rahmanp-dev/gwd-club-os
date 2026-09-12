import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/events/ai_event_generator_sheet.dart';
import '../../features/events/event_detail_sheet.dart';
import '../../features/events/events_page.dart';
import '../../features/tasks/task_detail_sheet.dart';
import '../../features/tasks/tasks_board_page.dart';
import '../../features/team/team_hierarchy_page.dart';
import '../theme/apple_motion.dart';
import '../theme/gwd_theme.dart';
import '../widgets/alert_island.dart';
import '../../features/auth/sign_in_page.dart';
import '../../features/collaboration/huddle_page.dart';
import '../../features/landing/club_web_landing_page.dart';

class ClubAppShell extends StatefulWidget {
  const ClubAppShell({
    super.key,
    required this.workspaceService,
  });

  final ClubWorkspaceService workspaceService;

  @override
  State<ClubAppShell> createState() => _ClubAppShellState();
}

class _ClubAppShellState extends State<ClubAppShell> {
  int _currentIndex = 0;
  DepartmentType? _tasksInitialDepartment;
  bool _showWebLanding = false;

  void _showAiGenerator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiEventGeneratorSheet(
        onGenerate: ({
          required String title,
          required String themeTagline,
          required EventCategory category,
          required DateTime targetDate,
          required String venue,
          required int expectedFootfall,
          required String budgetLabel,
          String? customInstructions,
        }) {
          widget.workspaceService.generateAiEvent(
            title: title,
            themeTagline: themeTagline,
            category: category,
            targetDate: targetDate,
            venue: venue,
            expectedFootfall: expectedFootfall,
            budgetLabel: budgetLabel,
            customInstructions: customInstructions,
          );
        },
      ),
    );
  }

  void _showEventDetail(ClubEvent event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailSheet(
        event: event,
        tasks: widget.workspaceService.tasks,
        onViewDepartmentTasks: (dept) {
          setState(() {
            _tasksInitialDepartment = dept;
            _currentIndex = 2; // Switch to Tasks tab
          });
        },
      ),
    );
  }

  void _showTaskDetail(ClubTask task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        viewerRole: widget.workspaceService.activeRole,
        onSubmitProof: (taskId, proof) {
          widget.workspaceService.submitProof(taskId, proof);
        },
        onVerifyTask: (taskId, verifierRole, verifierName) {
          widget.workspaceService.verifyTask(taskId, verifierRole, verifierName);
        },
        onReportBlocker: (taskId, blocker, blockedBy) {
          widget.workspaceService.reportBlocker(taskId, blocker, blockedBy);
        },
        onResolveBlocker: (taskId) {
          widget.workspaceService.resolveBlocker(taskId);
        },
        onAcceptTask: (taskId) {
          widget.workspaceService.updateTaskStatus(taskId, TaskStatus.committed);
        },
        workspace: widget.workspaceService,
      ),
    );
  }

  void _showPersonaPortal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SignInPage(
        members: widget.workspaceService.members,
        currentMemberId: widget.workspaceService.currentMember?.id,
        isSwitching: true,
        onSignIn: (memberId) {
          widget.workspaceService.signInAs(memberId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebLanding) {
      return ClubWebLandingPage(
        onLaunchApp: () => setState(() => _showWebLanding = false),
        onSelectRole: (role) {
          widget.workspaceService.switchRole(role);
          setState(() => _showWebLanding = false);
        },
      );
    }

    return ListenableBuilder(
      listenable: widget.workspaceService,
      builder: (context, _) {
        final service = widget.workspaceService;
        final pendingVerificationCount = service.pendingVerificationsForActiveRole.length;
        final blockedCount = service.blockedTasks.length;

        final screens = [
          DashboardPage(
            activeRole: service.activeRole,
            events: service.events,
            tasks: service.tasks,
            members: service.members,
            notifications: service.notifications,
            onSwitchRole: service.switchRole,
            onTapEvent: _showEventDetail,
            onTapDepartment: (dept) {
              setState(() {
                _tasksInitialDepartment = dept;
                _currentIndex = 2; // Jump to Tasks
              });
            },
            onTapTask: _showTaskDetail,
            onSubmitProof: service.submitProof,
            onVerifyTask: service.verifyTask,
            onReportBlocker: service.reportBlocker,
            onResolveBlocker: service.resolveBlocker,
            onAcceptTask: (id) => service.updateTaskStatus(id, TaskStatus.committed),
            onNudgeDepartment: service.nudgeDepartment,
            onLaunchAiGenerator: _showAiGenerator,
            onOpenPersonaPortal: _showPersonaPortal,
            onOpenLandingPage: () => setState(() => _showWebLanding = true),
          ),
          EventsPage(
            events: service.events,
            tasks: service.tasks,
            onGenerateAiEvent: ({
              required String title,
              required String themeTagline,
              required EventCategory category,
              required DateTime targetDate,
              required String venue,
              required int expectedFootfall,
              required String budgetLabel,
              String? customInstructions,
            }) {
              service.generateAiEvent(
                title: title,
                themeTagline: themeTagline,
                category: category,
                targetDate: targetDate,
                venue: venue,
                expectedFootfall: expectedFootfall,
                budgetLabel: budgetLabel,
                customInstructions: customInstructions,
              );
            },
            onViewDepartmentTasks: (dept) {
              setState(() {
                _tasksInitialDepartment = dept;
                _currentIndex = 2;
              });
            },
          ),
          TasksBoardPage(
            tasks: service.tasks,
            events: service.events,
            viewerRole: service.activeRole,
            initialDepartment: _tasksInitialDepartment,
            onSubmitProof: service.submitProof,
            onVerifyTask: service.verifyTask,
            onReportBlocker: service.reportBlocker,
            onResolveBlocker: service.resolveBlocker,
            onAcceptTask: (id) => service.updateTaskStatus(id, TaskStatus.committed),
            onCreateTask: service.addTask,
          ),
          HuddlePage(
            workspace: service,
            onOpenTask: (taskId) {
              final task = service.tasks.where((t) => t.id == taskId).firstOrNull;
              if (task != null) {
                _showTaskDetail(task);
              }
            },
          ),
          CalendarPage(
            events: service.events,
            tasks: service.tasks,
            onTapTask: _showTaskDetail,
          ),
          TeamHierarchyPage(
            members: service.members,
            activeRole: service.activeRole,
            onSwitchRole: service.switchRole,
          ),
        ];

        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AlertIsland(
                  workspace: service,
                  onOpenFeed: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                  onOpenTask: (taskId) {
                    final task = service.tasks.where((t) => t.id == taskId).firstOrNull;
                    if (task != null) {
                      _showTaskDetail(task);
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildFloatingGlassDock(
            currentIndex: _currentIndex,
            pendingVerifications: pendingVerificationCount,
            blockedCount: blockedCount,
            awaitingHandoffs: service.handoffsAwaitingMe.length,
            eventCount: service.events.length,
            onSelect: (index) {
              setState(() {
                _currentIndex = index;
                if (index != 2) _tasksInitialDepartment = null;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingGlassDock({
    required int currentIndex,
    required int pendingVerifications,
    required int blockedCount,
    required int awaitingHandoffs,
    required int eventCount,
    required void Function(int) onSelect,
  }) {
    final items = [
      const _DockItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Command'),
      _DockItem(Icons.event_outlined, Icons.event_rounded, 'Events', badgeCount: eventCount, badgeColor: GwdColors.primaryRed),
      _DockItem(Icons.task_alt_outlined, Icons.task_alt_rounded, 'Tasks', badgeCount: pendingVerifications, badgeColor: GwdColors.primaryRed),
      _DockItem(Icons.forum_outlined, Icons.forum_rounded, 'Huddle', badgeCount: awaitingHandoffs, badgeColor: GwdColors.primaryRed),
      _DockItem(Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Calendar', badgeCount: blockedCount, badgeColor: GwdColors.primaryRed),
      const _DockItem(Icons.account_tree_outlined, Icons.account_tree_rounded, 'Hierarchy'),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: GwdColors.primaryRed.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(33),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GwdColors.obsidian.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(33),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  // Main Navigation Items with Fluid Apple-grade animations
                  ...List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = currentIndex == index;

                    return Expanded(
                      child: AppleBouncy(
                        scaleFactor: 0.92,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelect(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      isSelected ? item.activeIcon : item.icon,
                                      color: isSelected
                                          ? GwdColors.primaryRed
                                          : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    if (item.badgeCount != null &&
                                        item.badgeCount! > 0)
                                      Positioned(
                                        top: -3,
                                        right: -6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: item.badgeColor ??
                                                GwdColors.primaryRed,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (item.badgeColor ??
                                                        GwdColors.primaryRed)
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${item.badgeCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  fontSize: 9.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutBack,
                                width: isSelected ? 14 : 0,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: GwdColors.primaryRed,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: GwdColors.primaryRed
                                                .withValues(alpha: 0.8),
                                            blurRadius: 5,
                                            spreadRadius: 0.5,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Standout AI Event Architect action launcher
                  AppleBouncy(
                    scaleFactor: 0.90,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAiGenerator();
                    },
                    child: Tooltip(
                      message: 'AI Event Architect (Coming Soon / In Dev)',
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(left: 3, right: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              GwdColors.primaryRed,
                              GwdColors.rubyDark,
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  GwdColors.primaryRed.withValues(alpha: 0.55),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  const _DockItem(
    this.icon,
    this.activeIcon,
    this.label, {
    this.badgeCount,
    this.badgeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;
  final Color? badgeColor;
}
