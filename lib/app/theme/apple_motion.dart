import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gwd_theme.dart';

/// Apple-style tactile spring bounce button/card wrapper.
/// When pressed, scales down with dampening; when released, springs back with elastic overshoot.
class AppleBouncy extends StatefulWidget {
  const AppleBouncy({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 140),
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;
  final HitTestBehavior hitTestBehavior;

  @override
  State<AppleBouncy> createState() => _AppleBouncyState();
}

class _AppleBouncyState extends State<AppleBouncy> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 260),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.hitTestBehavior,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Gentle ambient floating animation (bobs up and down subtly like visionOS elements)
class AppleFloat extends StatefulWidget {
  const AppleFloat({
    super.key,
    required this.child,
    this.offsetY = 4.0,
    this.duration = const Duration(milliseconds: 2400),
  });

  final Widget child;
  final double offsetY;
  final Duration duration;

  @override
  State<AppleFloat> createState() => _AppleFloatState();
}

class _AppleFloatState extends State<AppleFloat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: -widget.offsetY, end: widget.offsetY).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Continuous pulsing glow ring for VIP leaders and active blocker radar
class ApplePulseRing extends StatefulWidget {
  const ApplePulseRing({
    super.key,
    required this.child,
    required this.glowColor,
    this.maxBlur = 24.0,
    this.maxSpread = 4.0,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final Color glowColor;
  final double maxBlur;
  final double maxSpread;
  final Duration duration;

  @override
  State<ApplePulseRing> createState() => _ApplePulseRingState();
}

class _ApplePulseRingState extends State<ApplePulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _pulse.value * 0.5),
              blurRadius: widget.maxBlur * _pulse.value,
              spreadRadius: widget.maxSpread * _pulse.value,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Staggered cascading entrance widget for cards and list items
class AppleStaggerItem extends StatefulWidget {
  const AppleStaggerItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 45,
    this.offsetY = 18.0,
  });

  final Widget child;
  final int index;
  final int baseDelayMs;
  final double offsetY;

  @override
  State<AppleStaggerItem> createState() => _AppleStaggerItemState();
}

class _AppleStaggerItemState extends State<AppleStaggerItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    final delay = Duration(milliseconds: (widget.index * widget.baseDelayMs).clamp(0, 500));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: Transform.translate(
          offset: _slideAnimation.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Live undulating frequency equalizer matching the UI reference images
class AppleDynamicEqualizer extends StatefulWidget {
  const AppleDynamicEqualizer({
    super.key,
    required this.progress,
    this.barCount = 32,
    this.height = 36.0,
    this.isLiveAnimated = true,
  });

  final double progress;
  final int barCount;
  final double height;
  final bool isLiveAnimated;

  @override
  State<AppleDynamicEqualizer> createState() => _AppleDynamicEqualizerState();
}

class _AppleDynamicEqualizerState extends State<AppleDynamicEqualizer> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = (widget.progress * widget.barCount).round();

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final t = _waveController.value * 2 * math.pi;

        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (index) {
              final isActive = index < activeCount;
              final ratio = index / widget.barCount;

              // Mountain envelope base height
              final envelope = (1.0 - (ratio - 0.5).abs() * 1.6).clamp(0.35, 1.0);
              
              // Live organic wave oscillation
              final wave = widget.isLiveAnimated
                  ? 0.15 * math.sin(t + (index * 0.35)) + 0.1 * math.cos(t * 1.4 + (index * 0.2))
                  : 0.0;
              
              final barHeight = ((widget.height * envelope) + (widget.height * wave))
                  .clamp(widget.height * 0.25, widget.height);

              // Color spectrum gradient
              Color barColor;
              if (ratio < 0.35) {
                barColor = const Color(0xFFDC2626); // GWD Crimson Red
              } else if (ratio < 0.65) {
                barColor = const Color(0xFFF59E0B); // Amber
              } else if (ratio < 0.85) {
                barColor = const Color(0xFF10B981); // Emerald
              } else {
                barColor = const Color(0xFFEF4444); // Bright Red
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 3.5,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isActive ? barColor : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Apple-style physical layered folder card deck matching the UI reference
class AppleFolderDeck extends StatefulWidget {
  const AppleFolderDeck({
    super.key,
    required this.folderTitle,
    required this.subtitle,
    required this.stats,
    required this.children,
  });

  final String folderTitle;
  final String subtitle;
  final Map<String, String> stats;
  final List<Widget> children;

  @override
  State<AppleFolderDeck> createState() => _AppleFolderDeckState();
}

class _AppleFolderDeckState extends State<AppleFolderDeck> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Physical folder tab header
        Align(
          alignment: Alignment.centerLeft,
          child: AppleBouncy(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2442),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                    size: 14,
                    color: GwdColors.neonCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.folderTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Folder Body Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xEE1A1E38),
                Color(0xEE121528),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: GwdColors.primaryIndigo.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Quick Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE SPRINT',
                      style: TextStyle(
                        color: GwdColors.neonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Horizontal stat pill capsules
              if (widget.stats.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: widget.stats.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Expandable content
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 240),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
