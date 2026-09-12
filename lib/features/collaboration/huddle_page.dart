import 'package:flutter/material.dart';

import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../app/widgets/page_scaffold.dart';
import '../../core/models/collaboration.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';
import 'handoff_composer.dart';

/// The cross-department surface: every request in flight between departments,
/// and the club's activity stream.
///
/// Handoffs are sorted by who has to move next, not by when they were created —
/// "waiting on you" always sits at the top of your screen and nobody else's.
class HuddlePage extends StatefulWidget {
  const HuddlePage({
    super.key,
    required this.workspace,
    required this.onOpenTask,
  });

  final ClubWorkspaceService workspace;
  final void Function(String taskId) onOpenTask;

  @override
  State<HuddlePage> createState() => _HuddlePageState();
}

class _HuddlePageState extends State<HuddlePage> {
  int _tab = 0;

  void _openComposer() {
    showMorphSheet<void>(
      context: context,
      builder: (_) => HandoffComposer(workspace: widget.workspace),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.workspace,
      builder: (context, _) {
        final ws = widget.workspace;
        final awaitingMe = ws.handoffsAwaitingMe;
        final waitingOnOthers = ws.handoffsIAmWaitingOn;
        final everythingElse = ws.handoffs
            .where((h) =>
                !awaitingMe.any((a) => a.id == h.id) &&
                !waitingOnOthers.any((w) => w.id == h.id))
            .toList();

        return PageScaffold(
          title: 'Huddle',
          subtitle: 'Work crossing between departments',
          action: PageAction(
            icon: Icons.add_rounded,
            label: 'Request',
            onTap: _openComposer,
          ),
          slivers: [
            SliverToBoxAdapter(
              child: FluidReveal(
                child: _SegmentedToggle(
                  index: _tab,
                  labels: const ['Handoffs', 'Activity'],
                  counts: [ws.openHandoffs.length, ws.unreadActivityCount],
                  onChanged: (i) {
                    setState(() => _tab = i);
                    if (i == 1) ws.markActivityRead();
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: GwdSpace.xl)),
            if (_tab == 0)
              ..._buildHandoffSlivers(
                  context, awaitingMe, waitingOnOthers, everythingElse)
            else
              ..._buildActivitySlivers(context),
          ],
        );
      },
    );
  }

  List<Widget> _buildHandoffSlivers(
    BuildContext context,
    List<Handoff> awaitingMe,
    List<Handoff> waitingOnOthers,
    List<Handoff> others,
  ) {
    var reveal = 0;

    Widget group(String title, String subtitle, List<Handoff> items,
        {bool urgent = false}) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: GwdSpace.md),
              child: FluidReveal(
                index: reveal++,
                child: _HandoffCard(
                  handoff: items[i],
                  workspace: widget.workspace,
                  actionable: urgent,
                  onOpenTask: widget.onOpenTask,
                ),
              ),
            ),
          const SizedBox(height: GwdSpace.md),
        ],
      );
    }

    final hasAny =
        awaitingMe.isNotEmpty || waitingOnOthers.isNotEmpty || others.isNotEmpty;

    return [
      if (!hasAny)
        SliverToBoxAdapter(
          child: FluidReveal(
            child: EmptyState(
              icon: Icons.swap_horiz_rounded,
              title: 'Nothing is crossing departments',
              body:
                  'When you need something from another team, raise a handoff so it has an owner and a date instead of living in a chat.',
              actionLabel: 'Request a handoff',
              onAction: _openComposer,
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: group(
          'Waiting on you',
          'Your department owns these requests',
          awaitingMe,
          urgent: true,
        ),
      ),
      SliverToBoxAdapter(
        child: group(
          'You are waiting on',
          'Raised by you, not yet delivered',
          waitingOnOthers,
        ),
      ),
      SliverToBoxAdapter(
        child: group(
          'Across the club',
          'Everything else in flight',
          others,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }

  List<Widget> _buildActivitySlivers(BuildContext context) {
    final events = widget.workspace.activityFor(widget.workspace.currentMember);

    if (events.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: FluidReveal(
            child: EmptyState(
              icon: Icons.history_rounded,
              title: 'Nothing has happened yet',
              body: 'Verifications, blockers and handoffs will show up here.',
            ),
          ),
        ),
      ];
    }

    return [
      SliverList.separated(
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: GwdSpace.sm),
        itemBuilder: (context, i) => FluidReveal(
          index: i,
          offsetY: 12,
          child: _ActivityRow(
            event: events[i],
            onTap: events[i].taskId == null
                ? null
                : () => widget.onOpenTask(events[i].taskId!),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];
  }
}

/// Two-up segmented control with optional counts. Mirrors the iOS control:
/// the selected pill slides rather than cross-fading.
class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.index,
    required this.labels,
    required this.onChanged,
    this.counts = const [],
  });

  final int index;
  final List<String> labels;
  final List<int> counts;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GwdColors.surfaceSunken,
        borderRadius: BorderRadius.circular(GwdRadius.md),
        border: Border.all(color: GwdColors.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedAlign(
                duration: AppleDuration.standard,
                curve: AppleCurves.standard,
                alignment: Alignment(
                  labels.length == 1 ? 0 : (index / (labels.length - 1)) * 2 - 1,
                  0,
                ),
                child: Container(
                  width: itemWidth,
                  height: 34,
                  decoration: BoxDecoration(
                    color: GwdColors.surface,
                    borderRadius: BorderRadius.circular(GwdRadius.sm),
                    boxShadow: GwdShadow.resting(false),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final selected = i == index;
                  final count = i < counts.length ? counts[i] : 0;
                  return Expanded(
                    child: PressableScale(
                      onTap: () => onChanged(i),
                      pressedScale: 0.98,
                      child: SizedBox(
                        height: 34,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: AppleDuration.fast,
                              style: GwdType.caption.copyWith(
                                fontSize: 12,
                                color: selected
                                    ? GwdColors.ink
                                    : GwdColors.inkSecondary,
                              ),
                              child: Text(labels[i]),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: GwdColors.primaryRed,
                                  borderRadius:
                                      BorderRadius.circular(GwdRadius.pill),
                                ),
                                child: Text(
                                  '$count',
                                  style: GwdType.caption.copyWith(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HandoffCard extends StatelessWidget {
  const _HandoffCard({
    required this.handoff,
    required this.workspace,
    required this.actionable,
    required this.onOpenTask,
  });

  final Handoff handoff;
  final ClubWorkspaceService workspace;
  final bool actionable;
  final void Function(String taskId) onOpenTask;

  @override
  Widget build(BuildContext context) {
    final overdue = handoff.isOverdue;
    final statusColor = overdue ? GwdColors.critical : handoff.status.color;

    return SurfaceCard(
      emphasis: actionable && handoff.status == HandoffStatus.requested
          ? SurfaceEmphasis.live
          : SurfaceEmphasis.quiet,
      accent: statusColor,
      onTap: handoff.taskId == null ? null : () => onOpenTask(handoff.taskId!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GwdChip(
                label: handoff.fromDepartment.shortName,
                color: handoff.fromDepartment.color,
                dense: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 13, color: GwdColors.inkTertiary),
              ),
              GwdChip(
                label: handoff.toDepartment.shortName,
                color: handoff.toDepartment.color,
                dense: true,
              ),
              const Spacer(),
              GwdChip(
                label: overdue ? 'OVERDUE' : handoff.status.label.toUpperCase(),
                color: statusColor,
                icon: handoff.status.icon,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: GwdSpace.md),
          Text(
            handoff.title,
            style: GwdType.headline.copyWith(color: GwdColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            handoff.need,
            style: GwdType.footnote.copyWith(color: GwdColors.inkSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: GwdSpace.md),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: GwdColors.inkTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  handoff.requestedByName,
                  style: GwdType.caption.copyWith(
                      color: GwdColors.inkSecondary, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.schedule_rounded,
                  size: 13,
                  color: overdue ? GwdColors.critical : GwdColors.inkTertiary),
              const SizedBox(width: 4),
              Text(
                overdue
                    ? 'was due ${relativeTime(handoff.neededBy)}'
                    : 'needed ${relativeTime(handoff.neededBy)}',
                style: GwdType.caption.copyWith(
                  color: overdue ? GwdColors.critical : GwdColors.inkSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          if (handoff.responseNote != null) ...[
            const SizedBox(height: GwdSpace.md),
            Container(
              padding: const EdgeInsets.all(GwdSpace.md),
              decoration: BoxDecoration(
                color: GwdColors.surfaceSunken,
                borderRadius: BorderRadius.circular(GwdRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply_rounded,
                      size: 13, color: GwdColors.inkTertiary),
                  const SizedBox(width: GwdSpace.sm),
                  Expanded(
                    child: Text(
                      '${handoff.respondedByName ?? 'Team'}: ${handoff.responseNote}',
                      style: GwdType.footnote
                          .copyWith(color: GwdColors.inkSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (actionable && handoff.status == HandoffStatus.requested) ...[
            const SizedBox(height: GwdSpace.lg),
            Row(
              children: [
                Expanded(
                  child: _HandoffAction(
                    label: 'Accept',
                    icon: Icons.check_rounded,
                    filled: true,
                    color: GwdColors.success,
                    onTap: () => workspace.respondToHandoff(
                        handoff.id, HandoffStatus.accepted),
                  ),
                ),
                const SizedBox(width: GwdSpace.sm),
                Expanded(
                  child: _HandoffAction(
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    color: GwdColors.inkSecondary,
                    onTap: () => workspace.respondToHandoff(
                        handoff.id, HandoffStatus.declined),
                  ),
                ),
              ],
            ),
          ] else if (handoff.status == HandoffStatus.accepted &&
              workspace.currentMember?.department == handoff.toDepartment) ...[
            const SizedBox(height: GwdSpace.lg),
            _HandoffAction(
              label: 'Mark delivered',
              icon: Icons.local_shipping_outlined,
              filled: true,
              color: GwdColors.success,
              onTap: () => workspace.respondToHandoff(
                  handoff.id, HandoffStatus.delivered),
            ),
          ],
        ],
      ),
    );
  }
}

class _HandoffAction extends StatelessWidget {
  const _HandoffAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      haptic: HapticStrength.light,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(GwdRadius.md),
          border: Border.all(
              color: filled ? color : GwdColors.hairline, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GwdType.caption.copyWith(
                fontSize: 12,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event, this.onTap});

  final ActivityEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (event.severity) {
      ActivitySeverity.critical => GwdColors.critical,
      ActivitySeverity.notable => GwdColors.info,
      ActivitySeverity.ambient => GwdColors.inkTertiary,
    };

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(GwdSpace.md),
      borderRadius: GwdRadius.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(GwdRadius.sm),
            ),
            child: Icon(event.kind.icon, size: 15, color: accent),
          ),
          const SizedBox(width: GwdSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: GwdType.caption.copyWith(color: GwdColors.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      relativeTime(event.timestamp),
                      style: GwdType.caption.copyWith(
                          color: GwdColors.inkTertiary, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  event.body,
                  style:
                      GwdType.footnote.copyWith(color: GwdColors.inkSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
