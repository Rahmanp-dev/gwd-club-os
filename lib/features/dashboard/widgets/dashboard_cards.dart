import 'package:flutter/material.dart';

import '../../../app/theme/apple_motion.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_event.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';
import '../../../core/models/member_profile.dart';
import '../../auth/sign_in_page.dart';

/// ---------------------------------------------------------------------------
/// The personal hero.
///
/// Every member opens the app to the same question — *what needs me?* — and a
/// different answer. The number is the size of their own queue, the ring is
/// their own delivery rate, and the line underneath breaks it down in the
/// vocabulary of their role.
/// ---------------------------------------------------------------------------
class TodayCard extends StatelessWidget {
  const TodayCard({
    super.key,
    required this.member,
    required this.inbox,
    required this.myVerified,
    required this.myTotal,
    required this.flagship,
    this.onTapInbox,
  });

  final MemberProfile member;
  final List<ClubTask> inbox;
  final int myVerified;
  final int myTotal;
  final ClubEvent? flagship;
  final VoidCallback? onTapInbox;

  @override
  Widget build(BuildContext context) {
    final toDeliver = inbox
        .where((t) =>
            t.status != TaskStatus.submitted && t.status != TaskStatus.blocked)
        .length;
    final toSignOff =
        inbox.where((t) => t.status == TaskStatus.submitted).length;
    final blocked = inbox.where((t) => t.status == TaskStatus.blocked).length;
    final isClear = inbox.isEmpty;
    final progress = myTotal == 0 ? 0.0 : myVerified / myTotal;

    final parts = <String>[
      if (toDeliver > 0) '$toDeliver to deliver',
      if (toSignOff > 0) '$toSignOff to sign off',
      if (blocked > 0) '$blocked blocked',
    ];

    return SurfaceCard(
      onTap: onTapInbox,
      padding: const EdgeInsets.all(GwdSpace.xl),
      emphasis: blocked > 0 ? SurfaceEmphasis.live : SurfaceEmphasis.raised,
      accent: GwdColors.critical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.department.shortName.toUpperCase(),
                      style: GwdType.eyebrow
                          .copyWith(color: member.department.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GwdSpace.md),
                    if (isClear)
                      Text(
                        'You’re clear',
                        style: GwdType.largeTitle
                            .copyWith(color: GwdColors.ink, fontSize: 30),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedCounter(
                            value: inbox.length,
                            style: GwdType.largeTitle.copyWith(
                              color: GwdColors.ink,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              inbox.length == 1 ? 'thing needs you' : 'things need you',
                              style: GwdType.headline
                                  .copyWith(color: GwdColors.inkSecondary),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: GwdSpace.sm),
                    Text(
                      isClear
                          ? 'Nothing is waiting on you right now. Good place to pull something forward.'
                          : parts.join(' · '),
                      style: GwdType.callout
                          .copyWith(color: GwdColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GwdSpace.lg),
              ProgressArc(
                progress: progress,
                color: progress >= 0.75
                    ? GwdColors.success
                    : (progress >= 0.4
                        ? GwdColors.warning
                        : GwdColors.primaryRed),
                size: 62,
                strokeWidth: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedCounter(
                      value: (progress * 100).round(),
                      suffix: '%',
                      style: GwdType.caption.copyWith(
                          fontSize: 14, color: GwdColors.ink),
                    ),
                    Text('done',
                        style: GwdType.caption.copyWith(
                            fontSize: 8.5, color: GwdColors.inkTertiary)),
                  ],
                ),
              ),
            ],
          ),
          if (flagship != null) ...[
            const SizedBox(height: GwdSpace.xl),
            const Divider(height: 1),
            const SizedBox(height: GwdSpace.md),
            Row(
              children: [
                Icon(flagship!.category.icon,
                    size: 14, color: GwdColors.inkTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    flagship!.title,
                    style: GwdType.footnote
                        .copyWith(color: GwdColors.inkSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: GwdSpace.sm),
                GwdChip(
                  label: flagship!.countdownLabel.toUpperCase(),
                  color: flagship!.daysRemaining <= 3
                      ? GwdColors.critical
                      : GwdColors.inkSecondary,
                  dense: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact strip showing handoffs in both directions. Tapping opens Huddle.
class HandoffStrip extends StatelessWidget {
  const HandoffStrip({
    super.key,
    required this.awaitingMe,
    required this.waitingOnOthers,
    required this.onTap,
  });

  final int awaitingMe;
  final int waitingOnOthers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(GwdSpace.lg),
      emphasis:
          awaitingMe > 0 ? SurfaceEmphasis.live : SurfaceEmphasis.quiet,
      accent: GwdColors.warning,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (awaitingMe > 0 ? GwdColors.warning : GwdColors.inkTertiary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GwdRadius.sm),
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              size: 17,
              color: awaitingMe > 0 ? GwdColors.warning : GwdColors.inkTertiary,
            ),
          ),
          const SizedBox(width: GwdSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  awaitingMe > 0
                      ? '$awaitingMe handoff${awaitingMe == 1 ? '' : 's'} waiting on your team'
                      : 'No handoffs waiting on your team',
                  style: GwdType.headline.copyWith(color: GwdColors.ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  waitingOnOthers > 0
                      ? 'You are waiting on $waitingOnOthers from other departments'
                      : 'Nothing outstanding from other departments',
                  style: GwdType.footnote
                      .copyWith(color: GwdColors.inkSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: GwdColors.inkTertiary),
        ],
      ),
    );
  }
}

/// The member's own growth record: banked XP, reliability, and the corporate
/// skills they can actually put on a CV.
class GrowthCard extends StatelessWidget {
  const GrowthCard({super.key, required this.member, required this.rank});

  final MemberProfile member;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final skills = member.corporateSkillsEarned.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSkills = skills.take(3).toList();
    final maxValue =
        topSkills.isEmpty ? 1 : topSkills.first.value.clamp(1, 9999);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('YOUR RECORD',
                        style: GwdType.eyebrow
                            .copyWith(color: GwdColors.inkTertiary)),
                    const SizedBox(height: GwdSpace.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCounter(
                          value: member.totalVerifiedPoints,
                          style: GwdType.title1
                              .copyWith(color: GwdColors.ink),
                        ),
                        const SizedBox(width: 5),
                        Text('XP verified',
                            style: GwdType.footnote
                                .copyWith(color: GwdColors.inkSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GwdChip(
                    label: 'RANK #$rank',
                    color: rank <= 3 ? GwdColors.primaryRed : GwdColors.inkSecondary,
                    dense: true,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${member.reliabilityRate.toStringAsFixed(1)}% reliable',
                    style: GwdType.caption
                        .copyWith(color: GwdColors.inkTertiary, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          if (topSkills.isNotEmpty) ...[
            const SizedBox(height: GwdSpace.xl),
            Text('CORPORATE SKILLS BANKED',
                style:
                    GwdType.eyebrow.copyWith(color: GwdColors.inkTertiary)),
            const SizedBox(height: GwdSpace.md),
            for (final skill in topSkills)
              Padding(
                padding: const EdgeInsets.only(bottom: GwdSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            skill.key,
                            style: GwdType.footnote
                                .copyWith(color: GwdColors.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: GwdSpace.sm),
                        Text('${skill.value}',
                            style: GwdType.caption.copyWith(
                                color: member.department.color, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FluidMeter(
                      progress: skill.value / maxValue,
                      color: member.department.color,
                      height: 5,
                    ),
                  ],
                ),
              ),
          ],
          if (member.badges.isNotEmpty) ...[
            const SizedBox(height: GwdSpace.xs),
            Wrap(
              spacing: GwdSpace.sm,
              runSpacing: GwdSpace.sm,
              children: member.badges
                  .map((b) => GwdChip(
                        label: b,
                        color: GwdColors.inkSecondary,
                        icon: Icons.workspace_premium_outlined,
                        dense: true,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// How the member's own department is doing, and who is on it.
class DepartmentPulseCard extends StatelessWidget {
  const DepartmentPulseCard({
    super.key,
    required this.department,
    required this.teammates,
    required this.progress,
    required this.openCount,
    required this.blockedCount,
    this.onTap,
  });

  final DepartmentType department;
  final List<MemberProfile> teammates;
  final double progress;
  final int openCount;
  final int blockedCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: department.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(GwdRadius.sm),
                ),
                child: Icon(department.icon,
                    size: 16, color: department.color),
              ),
              const SizedBox(width: GwdSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      department.displayName,
                      style: GwdType.headline.copyWith(color: GwdColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$openCount open · ${(progress * 100).round()}% signed off',
                      style: GwdType.footnote
                          .copyWith(color: GwdColors.inkSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (blockedCount > 0)
                GwdChip(
                  label: '$blockedCount BLOCKED',
                  color: GwdColors.critical,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: GwdSpace.lg),
          FluidMeter(progress: progress, color: department.color),
          if (teammates.isNotEmpty) ...[
            const SizedBox(height: GwdSpace.lg),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: teammates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) => Tooltip(
                  message:
                      '${teammates[i].name} · ${teammates[i].role.shortBadge}',
                  child: MemberAvatar(member: teammates[i], size: 34),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Flagship event summary with a live waveform of overall progress.
class FlagshipCard extends StatelessWidget {
  const FlagshipCard({
    super.key,
    required this.event,
    required this.verified,
    required this.total,
    required this.onTap,
  });

  final ClubEvent event;
  final int verified;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : verified / total;
    final urgent = event.daysRemaining <= 3;

    return SurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                GwdSpace.xl, GwdSpace.xl, GwdSpace.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GwdChip(
                      label: event.category.label.toUpperCase(),
                      color: GwdColors.primaryRed,
                      dense: true,
                    ),
                    const Spacer(),
                    if (event.status == EventStatus.live) ...[
                      const BreathingDot(color: GwdColors.success, size: 6),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      event.countdownLabel,
                      style: GwdType.caption.copyWith(
                        color:
                            urgent ? GwdColors.critical : GwdColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GwdSpace.md),
                Text(
                  event.title,
                  style: GwdType.title3.copyWith(color: GwdColors.ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event.themeTagline,
                  style: GwdType.footnote
                      .copyWith(color: GwdColors.inkSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GwdSpace.lg),
                Row(
                  children: [
                    _MiniStat(
                        label: 'Delivered', value: '$verified/$total'),
                    const SizedBox(width: GwdSpace.xl),
                    _MiniStat(
                        label: 'Expected',
                        value: '${event.expectedFootfall}'),
                    const SizedBox(width: GwdSpace.xl),
                    Flexible(
                      child: _MiniStat(
                          label: 'Venue', value: event.venue, tight: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GwdSpace.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwdSpace.xl),
            child: AppleDynamicEqualizer(
              progress: progress,
              barCount: 28,
              height: 30,
              color: urgent ? GwdColors.critical : GwdColors.primaryRed,
            ),
          ),
          const SizedBox(height: GwdSpace.lg),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, this.tight = false});

  final String label;
  final String value;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(),
            style: GwdType.caption
                .copyWith(color: GwdColors.inkTertiary, fontSize: 9)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GwdType.callout.copyWith(
            color: GwdColors.ink,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: tight ? TextOverflow.ellipsis : TextOverflow.clip,
        ),
      ],
    );
  }
}
