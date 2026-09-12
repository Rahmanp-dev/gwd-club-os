import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/collaboration.dart';
import '../../core/services/club_workspace_service.dart';
import '../theme/apple_motion.dart';
import '../theme/gwd_theme.dart';

/// A Dynamic-Island-style alert that is **absent** unless something genuinely
/// important has happened.
///
/// The previous version was a permanent pill that morphed on every state
/// change, so routine taps kept yanking the eye to the top of the screen. Now
/// the service decides what deserves an interruption (blockers, handoff
/// requests, direct mentions, and anything addressed personally to the viewer)
/// and everything else lands silently in the activity feed.
class AlertIsland extends StatefulWidget {
  const AlertIsland({
    super.key,
    required this.workspace,
    this.onOpenFeed,
    this.onOpenTask,
  });

  final ClubWorkspaceService workspace;
  final VoidCallback? onOpenFeed;
  final void Function(String taskId)? onOpenTask;

  @override
  State<AlertIsland> createState() => _AlertIslandState();
}

class _AlertIslandState extends State<AlertIsland> {
  Timer? _dismissTimer;
  String? _shownAlertId;

  @override
  void initState() {
    super.initState();
    widget.workspace.addListener(_onWorkspaceChanged);
  }

  @override
  void didUpdateWidget(covariant AlertIsland oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace != widget.workspace) {
      oldWidget.workspace.removeListener(_onWorkspaceChanged);
      widget.workspace.addListener(_onWorkspaceChanged);
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    widget.workspace.removeListener(_onWorkspaceChanged);
    super.dispose();
  }

  void _onWorkspaceChanged() {
    final alert = widget.workspace.latestAlert;
    if (alert == null) {
      _shownAlertId = null;
      return;
    }
    if (alert.id == _shownAlertId) return;
    _shownAlertId = alert.id;

    // Critical items linger; merely notable ones get out of the way quickly.
    final lifetime = alert.severity == ActivitySeverity.critical
        ? const Duration(seconds: 7)
        : const Duration(seconds: 4);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(lifetime, () {
      if (mounted && widget.workspace.latestAlert?.id == alert.id) {
        widget.workspace.dismissAlert();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.workspace.latestAlert;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: GwdSpace.md, vertical: GwdSpace.sm),
        child: AnimatedSwitcher(
          duration: AppleDuration.slow,
          switchInCurve: AppleCurves.enter,
          switchOutCurve: AppleCurves.exit,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
                child: child,
              ),
            ),
          ),
          child: alert == null
              ? const SizedBox(key: ValueKey('no-alert'), width: double.infinity)
              : _AlertCard(
                  key: ValueKey(alert.id),
                  alert: alert,
                  onDismiss: () {
                    _dismissTimer?.cancel();
                    widget.workspace.dismissAlert();
                  },
                  onOpen: () {
                    _dismissTimer?.cancel();
                    widget.workspace.dismissAlert();
                    if (alert.taskId != null && widget.onOpenTask != null) {
                      widget.onOpenTask!(alert.taskId!);
                    } else {
                      widget.onOpenFeed?.call();
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    super.key,
    required this.alert,
    required this.onDismiss,
    required this.onOpen,
  });

  final ActivityEvent alert;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = switch (alert.severity) {
      ActivitySeverity.critical => GwdColors.primaryRed,
      ActivitySeverity.notable => GwdColors.info,
      ActivitySeverity.ambient => GwdColors.inkTertiary,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Dismissible(
          key: ValueKey('dismiss-${alert.id}'),
          direction: DismissDirection.up,
          onDismissed: (_) => onDismiss(),
          child: PressableScale(
            onTap: onOpen,
            pressedScale: 0.98,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              decoration: BoxDecoration(
                color: GwdColors.obsidian,
                borderRadius: BorderRadius.circular(GwdRadius.xl),
                border: Border.all(
                  color: accent.withValues(alpha: 0.45),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.32),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(alert.kind.icon, size: 17, color: accent),
                  ),
                  const SizedBox(width: GwdSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                alert.title,
                                style: GwdType.caption.copyWith(
                                  color: accent,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (alert.severity == ActivitySeverity.critical)
                              BreathingDot(color: accent, size: 5.5),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.body,
                          style: GwdType.footnote.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: GwdSpace.sm),
                  PressableScale(
                    onTap: onDismiss,
                    haptic: HapticStrength.none,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.55),
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
