import 'package:flutter/material.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import '../../core/models/member_profile.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.members,
    required this.onLoginAsRole,
  });

  final List<MemberProfile> members;
  final void Function(ClubRole role) onLoginAsRole;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController(text: 'president@gwd.global');
  final _passwordController = TextEditingController(text: 'GwdGlobal2026!');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStandardLogin() {
    final email = _emailController.text.trim().toLowerCase();
    // Match role by email
    final role = switch (email) {
      'ceo@gwd.global' => ClubRole.gwdCeo,
      'cmo@gwd.global' => ClubRole.gwdCmo,
      'president@gwd.global' => ClubRole.president,
      'vp@gwd.global' => ClubRole.vicePresident,
      'gensec@gwd.global' => ClubRole.generalSecretary,
      'marketing@gwd.global' => ClubRole.marketingLead,
      'pr@gwd.global' => ClubRole.prLead,
      'events@gwd.global' => ClubRole.eventManagementLead,
      'creative@gwd.global' => ClubRole.creativeLead,
      'production@gwd.global' => ClubRole.productionLead,
      'cinema@gwd.global' => ClubRole.cinematographerLead,
      _ => ClubRole.clubMember,
    };
    widget.onLoginAsRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GwdColors.canvasLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Brand Lockup Header with Official Club Logo
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GwdColors.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: GwdColors.primaryRed.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/images/club_logo_red.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GWD CLUB OS',
                        style: TextStyle(
                          color: GwdColors.obsidian,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'CAMPUS TO CORPORATE · GWD GLOBAL',
                        style: TextStyle(
                          color: GwdColors.primaryRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Accountability Command Center',
                style: TextStyle(
                  color: GwdColors.obsidian,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Outcome verification, scope of work contracts, and inter-department synchronization.',
                style: TextStyle(color: GwdColors.textSecondary, fontSize: 13, height: 1.35),
              ),

              const SizedBox(height: 22),

              // FAST 1-TAP TEST LOGINS CAROUSEL / GRID
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: GwdColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: GwdColors.primaryRed, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          '1-TAP TEST PERSONAS (PRE-FED)',
                          style: TextStyle(
                            color: GwdColors.primaryRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: GwdColors.rubyLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '12 PROFILES LIVE',
                            style: TextStyle(color: GwdColors.primaryRed, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap any leader or crew member below to jump directly into their tailored console:',
                      style: TextStyle(color: GwdColors.textSecondary, fontSize: 11.5),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.members.map((member) {
                        return InkWell(
                          onTap: () => widget.onLoginAsRole(member.role),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: member.role.color.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: member.role.color.withValues(alpha: 0.15),
                                  child: Text(
                                    member.initials,
                                    style: TextStyle(
                                      color: member.role.color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(color: GwdColors.obsidian, fontSize: 12, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      member.role.shortBadge,
                                      style: TextStyle(color: member.role.color, fontSize: 9, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Manual Email/Password Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: GwdColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Direct Role Credentials',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GwdColors.obsidian),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Universal test password: GwdGlobal2026!',
                      style: TextStyle(fontSize: 12, color: GwdColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: GwdColors.obsidian, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Club Email Address',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20, color: GwdColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.line)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.primaryRed, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: GwdColors.obsidian, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: GwdColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20, color: GwdColors.textSecondary),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.line)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GwdColors.primaryRed, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _handleStandardLogin,
                        style: FilledButton.styleFrom(
                          backgroundColor: GwdColors.primaryRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Sign In to Command Console',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Host Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GwdColors.line),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi, color: GwdColors.emerald, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live LAN Server Available',
                            style: TextStyle(color: GwdColors.obsidian, fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Connect from phone: http://192.168.0.109:3000',
                            style: TextStyle(color: GwdColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
