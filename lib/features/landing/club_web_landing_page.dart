import 'package:flutter/material.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cool Apple-grade Web Landing Page Concept
/// Tailored for iPhone (Safari) and Desktop web visitors:
/// - Provides direct download for Android APK (`/gwd-club-os.apk`)
/// - One-tap launch into live Cloud Web OS Cockpit
/// - Showcase of the 11 interconnected lead roles and CMO suite
class ClubWebLandingPage extends StatelessWidget {
  const ClubWebLandingPage({
    super.key,
    required this.onLaunchApp,
    required this.onSelectRole,
  });

  final VoidCallback onLaunchApp;
  final void Function(ClubRole role) onSelectRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Navigation Bar
              _buildTopNav(context),
              const SizedBox(height: 36),

              // Hero Section with Floating GWD Club Logo
              _buildHeroSection(context),
              const SizedBox(height: 40),

              // Dual Action CTA: Download APK & Launch Cloud OS
              _buildDualCtaSection(context),
              const SizedBox(height: 48),

              // Live Club Metrics Ticker
              _buildMetricsTicker(context),
              const SizedBox(height: 48),

              // 11-Role Interactive Simulator Carousel
              _buildRoleSimulator(context),
              const SizedBox(height: 48),

              // Apple Feature Showcase Cards
              _buildFeatureShowcase(context),
              const SizedBox(height: 48),

              // iPhone (Safari) & Android Setup Guide Card
              _buildPlatformGuide(context),
              const SizedBox(height: 40),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GwdColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
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
              'GWD GET WORK DONE CLUB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: GwdColors.obsidian,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Global Student Chapter Operating System',
              style: TextStyle(
                fontSize: 10,
                color: GwdColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        AppleBouncy(
          scaleFactor: 0.94,
          onTap: onLaunchApp,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GwdColors.obsidian,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Launch App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        // Levitation Logo Emblem
        AppleFloat(
          offsetY: 6,
          duration: const Duration(milliseconds: 2600),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: GwdColors.primaryRed.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: GwdColors.primaryRed.withValues(alpha: 0.18),
                  blurRadius: 32,
                  spreadRadius: 4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/club_logo_red.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Live Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: GwdColors.rubyLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: GwdColors.primaryRed.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.military_tech_rounded,
                  size: 14, color: GwdColors.primaryRed),
              SizedBox(width: 6),
              Text(
                'POWERED BY GWD GLOBAL · CAMPUS TO CORPORATE',
                style: TextStyle(
                  color: GwdColors.primaryRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Hero Headline
        const Text(
          'Where Campus Passion\nMeets Corporate Execution.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: GwdColors.obsidian,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: const Text(
            'The executive operating rhythm for college clubs. Synchronizing 11 leadership desks — from President to Cinematography Lead — with proof-of-work accountability, sponsor deal tracking, and AI event blueprints.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: GwdColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDualCtaSection(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Primary Action: Launch Cloud Web OS (For iPhone Safari & Desktop)
              Expanded(
                child: AppleBouncy(
                  scaleFactor: 0.95,
                  onTap: onLaunchApp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: GwdColors.primaryRed,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: GwdColors.primaryRed.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_done_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Launch Web OS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 2. Secondary Action: Download Android APK
              Expanded(
                child: AppleBouncy(
                  scaleFactor: 0.95,
                  onTap: () {
                    // Triggers direct browser download of the APK
                    _triggerApkDownload(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: GwdColors.obsidian,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.android_rounded,
                            color: Color(0xFF4ADE80), size: 20),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Download APK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'v0.1.0 · 48 MB',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'iPhone users: Tap "Launch Web OS" and select "Add to Home Screen" in Safari for full-screen native experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: GwdColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerApkDownload(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.downloading_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Starting Android APK download (gwd-club-os.apk)...',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: GwdColors.obsidian,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );

    final uri = Uri.parse('/gwd-club-os.apk');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback for web environments without popups
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  Widget _buildMetricsTicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GwdColors.line),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TickerStat(value: '11', label: 'Lead Roles Interconnected'),
          _TickerStat(value: '28.4K', label: 'Campus Impressions'),
          _TickerStat(value: '\$4.2K', label: 'Corporate Sponsors'),
          _TickerStat(value: '100%', label: 'Proof Verified'),
        ],
      ),
    );
  }

  Widget _buildRoleSimulator(BuildContext context) {
    final roles = [
      (ClubRole.gwdCmo, 'GWD Global CMO', 'Zero-Headache Mentorship'),
      (ClubRole.gwdCeo, 'GWD Global CEO', 'Sanctions & Direction'),
      (ClubRole.president, 'President', 'Approvals & Keynotes'),
      (ClubRole.generalSecretary, 'General Secretary', 'Master Run-of-Show'),
      (ClubRole.creativeLead, 'Creative Lead', 'Brand Visuals & Aesthetics'),
      (ClubRole.marketingLead, 'Marketing Lead', 'Campaigns & Reels'),
      (ClubRole.prLead, 'PR Lead', 'Sponsor Decks & MoUs'),
      (ClubRole.cinematographerLead, 'Cinema Lead', '4K Teasers & Media'),
      (ClubRole.eventManagementLead, 'Event Ops Lead', 'Logistics & Run-of-Show'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'TEST DRIVE ANY LEADERSHIP DESK',
          style: TextStyle(
            color: GwdColors.primaryRed,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '1-Tap Direct Role Switcher',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: GwdColors.obsidian,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: roles.map((r) {
            return AppleBouncy(
              scaleFactor: 0.94,
              onTap: () {
                onSelectRole(r.$1);
                onLaunchApp();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GwdColors.line, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: GwdColors.rubyLight,
                      child: Icon(r.$1.icon,
                          size: 13, color: GwdColors.primaryRed),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GwdColors.obsidian,
                          ),
                        ),
                        Text(
                          r.$3,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: GwdColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios,
                        size: 10, color: GwdColors.textMuted),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureShowcase(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'WHY CLUBS LOVE GWD OS',
                style: TextStyle(
                  color: GwdColors.primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Engineered for Velocity & Accountability',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: GwdColors.obsidian,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _FeatureCard(
          icon: Icons.shield_rounded,
          iconColor: GwdColors.primaryRed,
          title: 'GWD CMO Mentorship Suite',
          description:
              'Zero-headache corporate guidance. The CMO can approve brand creative with 1-tap seals, dispense instant feedback chips, and connect Tier-1 sponsors in seconds.',
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.auto_awesome,
          iconColor: GwdColors.primaryRed,
          title: 'AI Event Architect (In Dev / Coming Soon)',
          description:
              'Autonomous campus festival synthesizer under active development. Generates parallel schedules, budget allocations, and cross-department assignments across all 6 teams.',
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.sensors_rounded,
          iconColor: GwdColors.emerald,
          title: 'Apple Dynamic Island Operations Radar',
          description:
              'Real-time floating dispatch pill tracks live deliverables, blocker escalations, and XP awards with smooth Apple spring physics.',
        ),
        SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.verified_user_rounded,
          iconColor: Color(0xFFD97706),
          title: 'Corporate Skill XP & Recommendations',
          description:
              'Every verified task awards corporate-mapped skills (Brand Delivery, Budgeting, AV Tech) leading to official GWD Global recommendation letters for internships.',
        ),
      ],
    );
  }

  Widget _buildPlatformGuide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: GwdColors.obsidian,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Instant Access On Any Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _GuideStep(
            number: '1',
            title: 'Android Devices',
            description:
                'Tap "Download APK" to directly install the release APK. No Google Play Store account required for campus testing.',
          ),
          SizedBox(height: 10),
          _GuideStep(
            number: '2',
            title: 'iPhone & iPad (Safari)',
            description:
                'Tap "Launch Web OS". In Safari, tap the Share icon and choose "Add to Home Screen" to install it as a standalone PWA app with an app icon.',
          ),
          SizedBox(height: 10),
          _GuideStep(
            number: '3',
            title: 'Desktop Chrome / Edge / Mac',
            description:
                'Runs seamlessly in any modern browser with full keyboard shortcuts and wide-screen War Room dashboard support.',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Image.asset(
          'assets/images/club_logo_red.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'GWD GLOBAL · GET WORK DONE CLUB INITIATIVE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: GwdColors.obsidian,
            letterSpacing: 1,
          ),
        ),
        const Text(
          'Bridging Campus Talent to Corporate Leadership · 2026',
          style: TextStyle(
            fontSize: 10,
            color: GwdColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TickerStat extends StatelessWidget {
  const _TickerStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: GwdColors.obsidian,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: GwdColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: Colors.white,
      borderColor: GwdColors.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: GwdColors.obsidian,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GwdColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: GwdColors.primaryRed,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

