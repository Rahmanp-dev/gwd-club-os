import 'package:flutter/material.dart';
import 'apple_motion.dart';

class GwdColors {
  const GwdColors._();

  // White Canvas & Crisp Surfaces (Requested Palette)
  static const canvasLight = Color(0xFFF8FAFC);
  static const canvasWhite = Color(0xFFFFFFFF);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const cardWhite = Color(0xFFFFFFFF);

  // Executive Jet Black & Obsidian
  static const obsidian = Color(0xFF09090B);
  static const jetBlack = Color(0xFF000000);
  static const charcoal = Color(0xFF18181B);
  static const surfaceDark = Color(0xFF121215);
  static const cardDark = Color(0xFF18181B);
  static const canvasDark = Color(0xFF09090B);

  // Vibrant Crimson & Ruby Red Accents (Matching Official Club Logo)
  static const primaryRed = Color(0xFFDC2626); // Pure Crimson
  static const rubyDark = Color(0xFF991B1B);    // Deep Luxury Ruby
  static const rubyLight = Color(0xFFFEE2E2);   // Rose Mist
  static const accentCoral = Color(0xFFEF4444);  // Coral Red
  static const redGlow = Color(0x33DC2626);
  static const borderRed = Color(0x40DC2626);

  // Semantic Accents (Harmonized with Red/Black luxury system)
  static const primaryIndigo = Color(0xFFDC2626); // Harmonized with Red for brand cohesion
  static const electricViolet = Color(0xFF991B1B);
  static const purple = Color(0xFFDC2626);
  static const neonPink = Color(0xFFEF4444);
  static const neonCyan = Color(0xFF09090B);
  static const emerald = Color(0xFF16A34A);
  static const amber = Color(0xFFD97706);
  static const coral = Color(0xFFDC2626);

  // Typography & Borders
  static const textPrimary = Color(0xFF09090B);
  static const textSecondary = Color(0xFF52525B);
  static const textMuted = Color(0xFFA1A1AA);
  static const line = Color(0xFFE4E4E7);
  static const lineSubtle = Color(0xFFF4F4F5);
  static const glassSurface = Color(0xE6FFFFFF);
  static const glassBorder = Color(0xFFE4E4E7);
  static const glassBorderActive = Color(0xFFDC2626);
}

class GwdTheme {
  const GwdTheme._();

  /// Primary Luxury White + Red + Jet Black Theme
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: GwdColors.canvasLight,
      colorScheme: const ColorScheme.light(
        primary: GwdColors.primaryRed,
        secondary: GwdColors.obsidian,
        surface: GwdColors.surfaceWhite,
        onSurface: GwdColors.textPrimary,
        error: GwdColors.primaryRed,
      ),
      cardColor: GwdColors.cardWhite,
      dividerColor: GwdColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: GwdColors.obsidian,
      ),
    );
  }

  /// Executive Dark Mode
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GwdColors.canvasDark,
      colorScheme: const ColorScheme.dark(
        primary: GwdColors.primaryRed,
        secondary: Colors.white,
        surface: GwdColors.surfaceDark,
        onSurface: Colors.white,
        error: GwdColors.primaryRed,
      ),
      cardColor: GwdColors.cardDark,
      dividerColor: const Color(0xFF27272A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Reusable Apple-grade Glassmorphic Card Container with tactile spring feedback
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 22.0,
    this.borderColor,
    this.backgroundColor,
    this.shadowColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? shadowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF18181B) : Colors.white);
    final border = borderColor ?? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7));

    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? (isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.04)),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: GwdColors.primaryRed.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return AppleBouncy(
        onTap: onTap,
        scaleFactor: 0.97,
        child: content,
      );
    }
    return content;
  }
}

/// Equalizer Spectrum Frequency Bar Component with live Apple-style fluid wave animation
class SpectrumFrequencyBar extends StatelessWidget {
  const SpectrumFrequencyBar({
    super.key,
    required this.progress,
    this.barCount = 34,
    this.height = 36,
  });

  final double progress; // 0.0 to 1.0
  final int barCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppleDynamicEqualizer(
      progress: progress,
      barCount: barCount,
      height: height,
      isLiveAnimated: true,
    );
  }
}

