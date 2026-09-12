import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/apple_motion.dart';
import '../theme/gwd_theme.dart';

/// One header for every screen.
///
/// The old screens each built their own top row, which is how the phone layout
/// ended up cramming a logo, a badge, a subtitle, a dropdown and two icon
/// buttons into 375px. Here the title owns the row, there is at most **one**
/// action, and the title collapses from large to compact as you scroll — the
/// iOS navigation-bar behaviour, which buys back vertical space without hiding
/// where you are.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.subtitle,
    this.action,
    this.leading,
    this.onRefresh,
  });

  final String title;
  final String? subtitle;
  final List<Widget> slivers;
  final PageAction? action;
  final Widget? leading;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = GwdSpace.gutter(width);
    final maxContentWidth = width >= 1000 ? 920.0 : double.infinity;

    final scrollView = CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CollapsingTitleDelegate(
            title: title,
            subtitle: subtitle,
            action: action,
            leading: leading,
            gutter: gutter,
            topPadding: MediaQuery.paddingOf(context).top,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, GwdSpace.lg, gutter, 0),
          sliver: SliverMainAxisGroup(slivers: slivers),
        ),
      ],
    );

    final body = maxContentWidth == double.infinity
        ? scrollView
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: scrollView,
            ),
          );

    return Scaffold(
      backgroundColor: GwdColors.canvas,
      body: onRefresh == null
          ? body
          : RefreshIndicator(
              onRefresh: onRefresh!,
              color: GwdColors.primaryRed,
              backgroundColor: GwdColors.surface,
              displacement: 72,
              child: body,
            ),
    );
  }
}

class PageAction {
  const PageAction({
    required this.icon,
    required this.onTap,
    this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final int badgeCount;
}

class _CollapsingTitleDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingTitleDelegate({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.leading,
    required this.gutter,
    required this.topPadding,
  });

  final String title;
  final String? subtitle;
  final PageAction? action;
  final Widget? leading;
  final double gutter;
  final double topPadding;

  static const _collapsedHeight = 52.0;
  static const _expandedHeight = 96.0;

  @override
  double get minExtent => _collapsedHeight + topPadding;

  @override
  double get maxExtent => _expandedHeight + topPadding;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);

    // Title shrinks 27 -> 17pt, subtitle fades out over the first half.
    final titleSize = ui.lerpDouble(27, 17, Curves.easeOut.transform(t))!;
    final subtitleOpacity = (1 - (t * 1.8)).clamp(0.0, 1.0);
    final hairlineOpacity = Curves.easeIn.transform(t);

    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: GwdColors.canvas.withValues(alpha: 0.72 + (0.2 * t)),
              border: Border(
                bottom: BorderSide(
                  color: GwdColors.hairline.withValues(alpha: hairlineOpacity),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, topPadding + 6, gutter, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: GwdSpace.md),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subtitle != null && subtitleOpacity > 0)
                          Opacity(
                            opacity: subtitleOpacity,
                            child: SizedBox(
                              height: 15 * subtitleOpacity,
                              child: Text(
                                subtitle!,
                                style: GwdType.footnote
                                    .copyWith(color: GwdColors.inkSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: GwdColors.ink,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(width: GwdSpace.md),
                    _HeaderAction(action: action!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingTitleDelegate old) =>
      old.title != title ||
      old.subtitle != subtitle ||
      old.gutter != gutter ||
      old.topPadding != topPadding ||
      old.action?.badgeCount != action?.badgeCount ||
      old.action?.icon != action?.icon;
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.action});

  final PageAction action;

  @override
  Widget build(BuildContext context) {
    final hasLabel = action.label != null;

    return PressableScale(
      onTap: action.onTap,
      haptic: HapticStrength.light,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 36,
            padding: EdgeInsets.symmetric(horizontal: hasLabel ? 13 : 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: GwdColors.surface,
              borderRadius: BorderRadius.circular(GwdRadius.md),
              border: Border.all(color: GwdColors.hairline),
              boxShadow: GwdShadow.resting(false),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, size: 17, color: GwdColors.ink),
                if (hasLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    action.label!,
                    style: GwdType.caption.copyWith(
                      fontSize: 12,
                      color: GwdColors.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action.badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                constraints: const BoxConstraints(minWidth: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GwdColors.primaryRed,
                  borderRadius: BorderRadius.circular(GwdRadius.pill),
                  border: Border.all(color: GwdColors.canvas, width: 1.5),
                ),
                child: Text(
                  action.badgeCount > 99 ? '99+' : '${action.badgeCount}',
                  style: GwdType.caption
                      .copyWith(fontSize: 9, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown when a list has nothing in it. An empty screen should still explain
/// what would put something there.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: GwdSpace.xl, vertical: GwdSpace.xxl),
      decoration: BoxDecoration(
        color: GwdColors.surface,
        borderRadius: BorderRadius.circular(GwdRadius.xl),
        border: Border.all(color: GwdColors.hairline),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: GwdColors.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21, color: GwdColors.inkTertiary),
          ),
          const SizedBox(height: GwdSpace.lg),
          Text(
            title,
            style: GwdType.title3.copyWith(color: GwdColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GwdSpace.sm),
          Text(
            body,
            style: GwdType.callout.copyWith(color: GwdColors.inkSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: GwdSpace.xl),
            PressableScale(
              onTap: onAction,
              haptic: HapticStrength.light,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: GwdSpace.xl, vertical: 12),
                decoration: BoxDecoration(
                  color: GwdColors.ink,
                  borderRadius: BorderRadius.circular(GwdRadius.md),
                ),
                child: Text(
                  actionLabel!,
                  style: GwdType.caption
                      .copyWith(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
