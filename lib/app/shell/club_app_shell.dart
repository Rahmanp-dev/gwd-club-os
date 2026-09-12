import 'package:flutter/material.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';
import '../../features/auth/auth_page.dart';
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
import '../widgets/apple_dynamic_island.dart';
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
      ),
    );
  }

  void _showPersonaPortal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthPage(
        members: widget.workspaceService.members,
        onLoginAsRole: (role) {
          widget.workspaceService.switchRole(role);
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
                child: AppleDynamicIsland(
                  workspaceService: service,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildFloatingGlassDock(
            currentIndex: _currentIndex,
            pendingVerifications: pendingVerificationCount,
            blockedCount: blockedCount,
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
    required int eventCount,
    required void Function(int) onSelect,
  }) {
    final items = [
      const _DockItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Command'),
      _DockItem(Icons.event_outlined, Icons.event_rounded, 'Events', badgeCount: eventCount, badgeColor: GwdColors.primaryRed),
      _DockItem(Icons.task_alt_outlined, Icons.task_alt_rounded, 'Tasks', badgeCount: pendingVerifications, badgeColor: GwdColors.primaryRed),
      _DockItem(Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Calendar', badgeCount: blockedCount, badgeColor: GwdColors.primaryRed),
      const _DockItem(Icons.account_tree_outlined, Icons.account_tree_rounded, 'Hierarchy'),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        height: 68,
        decoration: BoxDecoration(
          color: GwdColors.obsidian,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
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
        child: Row(
          children: [
            // Main Navigation Pill Items (Apple Style)
            ...List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: AppleBouncy(
                  scaleFactor: 0.92,
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 8 : 4,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? GwdColors.primaryRed : const Color(0xFF71717A),
                              size: isSelected ? 20 : 19,
                            ),
                            if (item.badgeCount != null && item.badgeCount! > 0)
                              Positioned(
                                top: -3,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: item.badgeColor ?? GwdColors.primaryRed,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (item.badgeColor ?? GwdColors.primaryRed).withValues(alpha: 0.6),
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
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? GwdColors.primaryRed : const Color(0xFF71717A),
                            fontSize: 9.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Vibrant AI Action Launcher Button (Matching reference image 2's standout emblem button)
            AppleBouncy(
              scaleFactor: 0.90,
              onTap: _showAiGenerator,
              child: Tooltip(
                message: 'AI Event Architect (Coming Soon / In Dev)',
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: 4, right: 2),
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
                    boxShadow: [
                      BoxShadow(
                        color: GwdColors.primaryRed.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
