import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/club_task.dart';
import '../../core/services/club_workspace_service.dart';
import '../theme/apple_motion.dart';
import '../theme/gwd_theme.dart';

/// Apple Dynamic Island Floating Toast & Operations Pill
/// Floats seamlessly at the top of the interface, reacting to real-time dispatches,
/// verifications, blocker escalations, and AI event syntheses.
class AppleDynamicIsland extends StatefulWidget {
  const AppleDynamicIsland({
    super.key,
    required this.workspaceService,
    this.onTapActivityFeed,
  });

  final ClubWorkspaceService workspaceService;
  final VoidCallback? onTapActivityFeed;

  @override
  State<AppleDynamicIsland> createState() => _AppleDynamicIslandState();
}

class _AppleDynamicIslandState extends State<AppleDynamicIsland>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _scaleAnimation;
  Timer? _autoDismissTimer;
  String? _lastAlertId;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeOutBack),
    );

    widget.workspaceService.addListener(_handleServiceUpdate);
    _checkNewAlert();
  }

  @override
  void didUpdateWidget(covariant AppleDynamicIsland oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspaceService != widget.workspaceService) {
      oldWidget.workspaceService.removeListener(_handleServiceUpdate);
      widget.workspaceService.addListener(_handleServiceUpdate);
      _checkNewAlert();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    widget.workspaceService.removeListener(_handleServiceUpdate);
    _morphController.dispose();
    super.dispose();
  }

  void _handleServiceUpdate() {
    _checkNewAlert();
  }

  void _checkNewAlert() {
    final alert = widget.workspaceService.latestAlert;
    if (alert != null && alert.id != _lastAlertId) {
      _lastAlertId = alert.id;
      _autoDismissTimer?.cancel();
      _morphController.forward(from: 0.0);

      // Auto-collapse after 4.8 seconds
      _autoDismissTimer = Timer(const Duration(milliseconds: 4800), () {
        if (mounted) {
          widget.workspaceService.dismissAlert();
          _morphController.reverse();
        }
      });
    }
  }

  void _dismissCurrentAlert() {
    _autoDismissTimer?.cancel();
    widget.workspaceService.dismissAlert();
    _morphController.reverse();
  }

  void _showLiveActivityFeed() {
    if (widget.onTapActivityFeed != null) {
      widget.onTapActivityFeed!();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DynamicIslandActivitySheet(
        workspaceService: widget.workspaceService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.workspaceService.latestAlert;
    final isExpanded = alert != null;
    final totalTasks = widget.workspaceService.tasks.length;
    final verifiedTasks = widget.workspaceService.tasks
        .where((t) => t.status == TaskStatus.verified)
        .length;
    final blockedCount = widget.workspaceService.blockedTasks.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Align(
          alignment: Alignment.topCenter,
          child: AppleBouncy(
            scaleFactor: 0.96,
            onTap: isExpanded ? _dismissCurrentAlert : _showLiveActivityFeed,
            child: AnimatedBuilder(
              animation: _morphController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    constraints: BoxConstraints(
                      maxWidth: isExpanded ? 440 : 210,
                      minHeight: isExpanded ? 56 : 34,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 14 : 9,
                      vertical: isExpanded ? 8 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: GwdColors.obsidian,
                      borderRadius: BorderRadius.circular(isExpanded ? 24 : 20),
                      border: Border.all(
                        color: isExpanded
                            ? GwdColors.primaryRed.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.18),
                        width: isExpanded ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: isExpanded ? 20 : 12,
                          offset: const Offset(0, 6),
                        ),
                        if (isExpanded)
                          BoxShadow(
                            color: GwdColors.primaryRed.withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              child: isExpanded
                  ? _buildAlertContent(alert)
                  : _buildIdleContent(
                      totalTasks: totalTasks,
                      verifiedTasks: verifiedTasks,
                      blockedCount: blockedCount,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertContent(ClubLiveNotification alert) {
    final isBlocker = alert.type == 'blocker';

    return Row(
      children: [
        // Red Club Logo / Pulse Ring Lockup
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isBlocker ? GwdColors.primaryRed : const Color(0xFFDC2626),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GwdColors.primaryRed.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/images/club_logo_red.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.notifications_active_rounded,
              size: 20,
              color: GwdColors.primaryRed,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Alert Title and Message
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isBlocker
                            ? GwdColors.primaryRed
                            : const Color(0x33DC2626),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alert.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isBlocker ? Colors.white : GwdColors.primaryRed,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Flexible(
                    child: Text(
                      'Dismiss',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                alert.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdleContent({
    required int totalTasks,
    required int verifiedTasks,
    required int blockedCount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiny Club Logo Squircle
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            'assets/images/club_logo_red.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.bolt_rounded,
              size: 12,
              color: GwdColors.primaryRed,
            ),
          ),
        ),
        const SizedBox(width: 7),
        // Live Radar Dot with Pulse
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: blockedCount > 0
                ? GwdColors.accentCoral
                : GwdColors.primaryRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (blockedCount > 0
                        ? GwdColors.accentCoral
                        : GwdColors.primaryRed)
                    .withValues(alpha: 0.8),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        // Live Stat Tag
        Flexible(
          child: Text(
            blockedCount > 0
                ? '$blockedCount Blockers'
                : '$verifiedTasks/$totalTasks Live',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: blockedCount > 0 ? GwdColors.accentCoral : Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 3),
        const Icon(
          Icons.chevron_right_rounded,
          size: 13,
          color: Colors.white38,
        ),
      ],
    );
  }
}

/// Dynamic Island Expanded Activity Feed Sheet
class _DynamicIslandActivitySheet extends StatelessWidget {
  const _DynamicIslandActivitySheet({
    required this.workspaceService,
  });

  final ClubWorkspaceService workspaceService;

  @override
  Widget build(BuildContext context) {
    final notifications = workspaceService.notifications;
    final blockedTasks = workspaceService.blockedTasks;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: GwdColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Sheet Header with Club Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GwdColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/club_logo_red.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Operations Radar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: GwdColors.obsidian,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Real-time club broadcast & accountability pulse',
                    style: TextStyle(
                      fontSize: 11,
                      color: GwdColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: GwdColors.rubyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors_rounded,
                        size: 13, color: GwdColors.primaryRed),
                    SizedBox(width: 4),
                    Text(
                      'LIVE FEED',
                      style: TextStyle(
                        color: GwdColors.primaryRed,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Blockers highlight if any
          if (blockedTasks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: GwdColors.primaryRed, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${blockedTasks.length} Active Blocker Flagged',
                          style: const TextStyle(
                            color: GwdColors.primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          blockedTasks.first.blocker ?? 'Needs lead clearance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7F1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppleBouncy(
                    onTap: () {
                      workspaceService.resolveBlocker(blockedTasks.first.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: GwdColors.primaryRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Unblock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recent Activity Stream List
          const Text(
            'Recent Operations Feed',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: GwdColors.obsidian,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: notifications.take(8).length,
              separatorBuilder: (_, __) => const Divider(
                height: 16,
                color: GwdColors.line,
              ),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: GwdColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: GwdColors.obsidian,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppleBouncy(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: GwdColors.obsidian,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Close Operations Radar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

