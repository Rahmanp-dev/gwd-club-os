import 'package:flutter/material.dart';
import '../../../app/theme/apple_motion.dart';
import '../../../app/theme/gwd_theme.dart';
import '../../../core/models/club_event.dart';
import '../../../core/models/club_role.dart';
import '../../../core/models/club_task.dart';
import '../../../core/models/department.dart';
import '../../../core/models/member_profile.dart';

class RoleTailoredCockpit extends StatelessWidget {
  const RoleTailoredCockpit({
    super.key,
    required this.activeRole,
    required this.tasks,
    required this.events,
    required this.members,
    required this.onTapTask,
    required this.onVerifyTask,
    required this.onSubmitProof,
    required this.onNudgeDepartment,
    required this.onLaunchAiGenerator,
  });

  final ClubRole activeRole;
  final List<ClubTask> tasks;
  final List<ClubEvent> events;
  final List<MemberProfile> members;
  final void Function(ClubTask task) onTapTask;
  final void Function(String taskId, ClubRole verifierRole, String verifierName)
      onVerifyTask;
  final void Function(String taskId, String proof) onSubmitProof;
  final void Function(DepartmentType department, String reason)
      onNudgeDepartment;
  final VoidCallback onLaunchAiGenerator;

  @override
  Widget build(BuildContext context) {
    Widget cockpit;
    if (activeRole == ClubRole.gwdCeo) {
      cockpit = _buildCeoCockpit(context);
    } else if (activeRole == ClubRole.gwdCmo) {
      cockpit = _buildCmoCockpit(context);
    } else if (activeRole == ClubRole.president ||
        activeRole == ClubRole.vicePresident ||
        activeRole == ClubRole.generalSecretary) {
      cockpit = _buildExecutiveCockpit(context);
    } else if (activeRole == ClubRole.marketingLead) {
      cockpit = _buildMarketingCockpit(context);
    } else if (activeRole == ClubRole.prLead) {
      cockpit = _buildPrCockpit(context);
    } else if (activeRole == ClubRole.eventManagementLead) {
      cockpit = _buildEventOpsCockpit(context);
    } else if (activeRole == ClubRole.productionLead) {
      cockpit = _buildProductionCockpit(context);
    } else if (activeRole == ClubRole.cinematographerLead) {
      cockpit = _buildCinemaCockpit(context);
    } else {
      cockpit = _buildMemberCockpit(context);
    }

    return AppleStaggerItem(
      index: 0,
      offsetY: 20,
      child: cockpit,
    );
  }

  // ==========================================
  // 1. GWD CEO CORPORATE SUPERVISION COCKPIT
  // ==========================================
  Widget _buildCeoCockpit(BuildContext context) {
    final pendingApprovals =
        tasks.where((t) => t.status == TaskStatus.submitted).toList();
    final totalVerified =
        tasks.where((t) => t.status == TaskStatus.verified).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B18), Color(0xFF2C2210), Color(0xFF0F0E0C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: const Color(0xFFEAB308).withValues(alpha: 0.35),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEAB308).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEAB308)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield, color: Color(0xFFEAB308), size: 14),
                        SizedBox(width: 5),
                        Text(
                          'GWD GLOBAL HQ · CHAPTER SUPERVISION',
                          style: TextStyle(
                            color: Color(0xFFEAB308),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('AUDIT: OPTIMAL',
                        style: TextStyle(
                            color: GwdColors.emerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Campus-to-Corporate Oversight',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monitoring college chapter leadership velocity, corporate deliverable standards, and corporate placement readiness.',
                style:
                    TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildMetricTile(
                      'Readiness Index', '98.4%', const Color(0xFFEAB308)),
                  const SizedBox(width: 10),
                  _buildMetricTile('Deliverables Done',
                      '$totalVerified / ${tasks.length}', GwdColors.emerald),
                  const SizedBox(width: 10),
                  _buildMetricTile('Pending Audit',
                      '${pendingApprovals.length}', const Color(0xFF38BDF8)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildActionHeader(
            'CEO EXECUTIVE INTERVENTIONS', 'Direct corporate levers'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.verified_user,
                label: 'Endorse Chapter',
                color: const Color(0xFFEAB308),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Official GWD CEO Charter Endorsement issued to college chapter!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Approve Budget',
                color: GwdColors.emerald,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Flagship Hackathon budget of \$3,500 officially approved by GWD Global!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.auto_awesome,
                label: 'AI Architect',
                color: const Color(0xFF818CF8),
                onTap: onLaunchAiGenerator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader(
            'EXECUTIVE SIGN-OFF QUEUE (${pendingApprovals.length})',
            'Review and endorse lead proofs'),
        const SizedBox(height: 10),
        if (pendingApprovals.isEmpty)
          _buildEmptyCard(
              'All chapter deliverables are verified and corporate-compliant!')
        else
          ...pendingApprovals
              .map((task) => _buildSupervisionTaskCard(context, task)),
      ],
    );
  }

  // ==========================================
  // 2. GWD CMO MENTORSHIP & BRAND COCKPIT
  // ==========================================
  Widget _buildCmoCockpit(BuildContext context) {
    final mediaTasks = tasks
        .where((t) =>
            t.department == DepartmentType.marketing ||
            t.department == DepartmentType.cinematography ||
            t.department == DepartmentType.publicRelations)
        .toList();
    final pendingCreativeApprovals =
        mediaTasks.where((t) => t.status == TaskStatus.submitted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Executive Obsidian & Crimson CMO Command Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: GwdColors.obsidian,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: GwdColors.primaryRed.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: GwdColors.primaryRed.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Official Club Logo lockup
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: GwdColors.primaryRed.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Image.asset(
                      'assets/images/club_logo_red.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0x33DC2626),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GwdColors.primaryRed),
                    ),
                    child: const Text(
                      'GWD GLOBAL CMO · EXECUTIVE BRAND SUITE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GwdColors.emerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GwdColors.emerald),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: GwdColors.emerald, size: 12),
                        SizedBox(width: 3),
                        Text(
                          'VIRAL: 121%',
                          style: TextStyle(
                            color: GwdColors.emerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Zero-Headache Brand Guardianship',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Empowering your passion for student mentorship. Guide marketing, cinematography, and sponsor deals with 1-tap approvals and zero administrative burden.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildMetricTile(
                      'Campus Reach', '28.4K', GwdColors.primaryRed),
                  const SizedBox(width: 10),
                  _buildMetricTile(
                      'Confirmed RSVPs', '1,450', GwdColors.emerald),
                  const SizedBox(width: 10),
                  _buildMetricTile(
                      'Brand Quality', '10/10', const Color(0xFFFBBF24)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 1-TAP ZERO-HEADACHE EXECUTIVE CONTROLS
        _buildActionHeader(
          'CMO INSTANT SUPER-CONTROLS',
          'Single-tap executive levers that save hours of follow-ups',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.verified,
                label: 'Brand Seal All',
                color: GwdColors.primaryRed,
                onTap: () {
                  for (final t in pendingCreativeApprovals) {
                    onVerifyTask(t.id, activeRole, activeRole.defaultName);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pendingCreativeApprovals.isNotEmpty
                            ? '✨ Official GWD Brand Seal applied to ${pendingCreativeApprovals.length} creative deliverables!'
                            : '✨ GWD Global Brand Seal is active on all assets!',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: GwdColors.obsidian,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.handshake_rounded,
                label: 'Sponsor Bridge',
                color: const Color(0xFFD97706),
                onTap: () {
                  onNudgeDepartment(
                    DepartmentType.publicRelations,
                    'GWD HQ CMO shared Tier-1 Tech Sponsor intro deck (\$2,500 package). Connect immediately!',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '🤝 Dispatched GWD Corporate Tier-1 Sponsor kit to PR Lead Kabir!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: GwdColors.obsidian,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.campaign_rounded,
                label: 'Viral Boost',
                color: GwdColors.primaryRed,
                onTap: () {
                  onNudgeDepartment(
                    DepartmentType.marketing,
                    'CMO Directive: Drop 15s cinematic teaser reel today. Scale hostel registration drive!',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '🚀 Dispatched Viral Growth Boost to Marketing Lead Sneha!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: GwdColors.obsidian,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // CORPORATE SPONSORSHIP DEAL RADAR
        _buildActionHeader(
          'CORPORATE SPONSORSHIP PIPELINE',
          'Real-time campus-to-corporate brand monetization',
        ),
        const SizedBox(height: 10),
        GlassCard(
          backgroundColor: Colors.white,
          borderColor: GwdColors.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined,
                      color: GwdColors.emerald, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Corporate Brand Deals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: GwdColors.obsidian,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '\$4,200 COMMITTED',
                      style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSponsorRow(
                sponsorName: 'Tech Titans Global',
                tier: 'Title Partner',
                amount: '\$2,500',
                status: 'Confirmed · GWD HQ Signed',
                isApproved: true,
              ),
              const Divider(height: 16, color: GwdColors.line),
              _buildSponsorRow(
                sponsorName: 'CloudScale AI Labs',
                tier: 'Hackathon Track Partner',
                amount: '\$1,200',
                status: 'MoU Under Review by Kabir',
                isApproved: false,
              ),
              const Divider(height: 16, color: GwdColors.line),
              _buildSponsorRow(
                sponsorName: 'Pulse Energy Drinks',
                tier: 'Official Beverage Partner',
                amount: '\$500 in-kind',
                status: 'Stall & Sampling Space Approved',
                isApproved: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ZERO-HEADACHE CREATIVE REVIEW & POLISH DECK
        _buildActionHeader(
          'CREATIVE ASSET SIGN-OFF & POLISH',
          'One-tap feedback chips — no typing required',
        ),
        const SizedBox(height: 10),
        if (mediaTasks.isEmpty)
          _buildEmptyCard('All media and marketing deliverables are verified!')
        else
          ...mediaTasks.map((task) => _buildCmoCreativeTaskCard(context, task)),

        const SizedBox(height: 22),

        // CMO TALENT SCOUTING & ROCKSTAR BADGES
        _buildActionHeader(
          'CAMPUS TALENT RADAR & MENTORSHIP',
          'Recognize rockstar student talent with official GWD letters',
        ),
        const SizedBox(height: 10),
        GlassCard(
          backgroundColor: Colors.white,
          borderColor: GwdColors.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.military_tech_rounded,
                      color: Color(0xFFEAB308), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'CMO Choice · Future Industry Leaders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: GwdColors.obsidian,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTalentItem(
                context: context,
                studentName: 'Sneha Kapoor',
                roleLabel: 'Marketing Lead',
                highlight: 'Generated 28.4K impressions & 1,450 campus RSVPs',
                badgeName: 'CMO Growth Prodigy',
              ),
              const Divider(height: 18, color: GwdColors.line),
              _buildTalentItem(
                context: context,
                studentName: 'Aditya Rao',
                roleLabel: 'Cinematography Lead',
                highlight: 'Shot 4K cinematic trailer with 48h turnaround',
                badgeName: 'Master Visual Storyteller',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorRow({
    required String sponsorName,
    required String tier,
    required String amount,
    required String status,
    required bool isApproved,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isApproved ? GwdColors.emerald : const Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sponsorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: GwdColors.obsidian,
                ),
              ),
              Text(
                '$tier · $status',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: GwdColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: GwdColors.obsidian,
          ),
        ),
      ],
    );
  }

  Widget _buildCmoCreativeTaskCard(BuildContext context, ClubTask task) {
    final isSubmitted = task.status == TaskStatus.submitted;
    final isDone = task.status == TaskStatus.verified;

    return AppleBouncy(
      scaleFactor: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSubmitted
                ? GwdColors.primaryRed.withValues(alpha: 0.6)
                : GwdColors.line,
            width: isSubmitted ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isSubmitted
                        ? GwdColors.rubyLight
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isSubmitted
                        ? 'READY FOR CMO SEAL'
                        : isDone
                            ? 'GWD BRAND ENDORSED'
                            : 'IN PRODUCTION',
                    style: TextStyle(
                      color: isSubmitted
                          ? GwdColors.primaryRed
                          : isDone
                              ? GwdColors.emerald
                              : GwdColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.assigneeName} (${task.assigneeRole.shortBadge})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GwdColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '+${task.points} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: GwdColors.primaryRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: GwdColors.obsidian,
              ),
            ),
            if (task.proof != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GwdColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 14, color: GwdColors.primaryRed),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Deliverable: ${task.proof!}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: GwdColors.obsidian,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // CMO Action Controls
            Row(
              children: [
                // Quick Polish Chips Button (No typing needed)
                AppleBouncy(
                  scaleFactor: 0.94,
                  onTap: () {
                    _showCmoPolishSheet(context, task);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 13, color: GwdColors.textSecondary),
                        SizedBox(width: 5),
                        Text(
                          'Quick Polish Chip',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GwdColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // 1-Tap Brand Seal Endorsement
                AppleBouncy(
                  scaleFactor: 0.94,
                  onTap: () {
                    onVerifyTask(task.id, activeRole, activeRole.defaultName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🌟 Official GWD Brand Seal awarded to "${task.title}"!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: GwdColors.obsidian,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: isDone ? GwdColors.emerald : GwdColors.primaryRed,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isDone
                                  ? GwdColors.emerald
                                  : GwdColors.primaryRed)
                              .withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone ? Icons.check : Icons.verified,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isDone ? 'Brand Sealed' : 'Stamp GWD Seal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCmoPolishSheet(BuildContext context, ClubTask task) {
    final chips = [
      '🔥 Hook needs 3-second punch',
      '📐 Align official GWD red logo in upper header',
      '🎯 Add RSVP sticker and registration link in bio',
      '✨ Boost color grade saturation & audio levels',
      '🤝 Add Tier-1 sponsor strip at closing screen',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GwdColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: GwdColors.primaryRed, size: 20),
                SizedBox(width: 8),
                Text(
                  'Zero-Typing Creative Polish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GwdColors.obsidian,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Select a preset note to send to ${task.assigneeName}:',
              style: const TextStyle(
                fontSize: 12,
                color: GwdColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ...chips.map(
              (chip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppleBouncy(
                  scaleFactor: 0.97,
                  onTap: () {
                    onNudgeDepartment(task.department, chip);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sent polish note: "$chip"'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: GwdColors.obsidian,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: GwdColors.obsidian,
                      ),
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

  Widget _buildTalentItem({
    required BuildContext context,
    required String studentName,
    required String roleLabel,
    required String highlight,
    required String badgeName,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: GwdColors.rubyLight,
          child: Text(
            studentName.substring(0, 1),
            style: const TextStyle(
              color: GwdColors.primaryRed,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: GwdColors.obsidian,
                ),
              ),
              Text(
                highlight,
                style: const TextStyle(
                  fontSize: 11,
                  color: GwdColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppleBouncy(
          scaleFactor: 0.92,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '🏆 Bestowed "$badgeName" & GWD Recommendation to $studentName!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: GwdColors.obsidian,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Color(0xFFD97706), size: 12),
                SizedBox(width: 4),
                Text(
                  'Endorse',
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // ==========================================
  // 3. PRESIDENT & VP EXECUTIVE COCKPIT
  // ==========================================
  Widget _buildExecutiveCockpit(BuildContext context) {
    final actionable = tasks
        .where((t) =>
            t.status == TaskStatus.submitted || t.status == TaskStatus.blocked)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: '${activeRole.shortBadge} EXECUTIVE SUITE',
          badgeColor: activeRole.color,
          title: 'Cross-Department Symphony',
          subtitle:
              'Orchestrating 6 department leads, college admin compliance, and flagship event milestones.',
          metrics: [
            _MetricItem('Overall Velocity', '84%', activeRole.color),
            _MetricItem(
                'Blocked Items',
                '${tasks.where((t) => t.status == TaskStatus.blocked).length}',
                GwdColors.coral),
            _MetricItem(
                'Actionable', '${actionable.length}', GwdColors.emerald),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader(
            'EXECUTIVE INTERVENTIONS', 'Clear blockers & verify outcomes'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.auto_awesome,
                label: 'AI Blueprint',
                color: activeRole.color,
                onTap: onLaunchAiGenerator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.warning_amber_rounded,
                label: 'Unblock Lead',
                color: GwdColors.coral,
                onTap: () {
                  final blocked = tasks
                      .where((t) => t.status == TaskStatus.blocked)
                      .firstOrNull;
                  if (blocked != null) {
                    onTapTask(blocked);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'No active blockers! All leads running smoothly.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader(
            'PRIORITY DELIVERABLES QUEUE', 'Pending your review'),
        const SizedBox(height: 10),
        if (actionable.isEmpty)
          _buildEmptyCard(
              'No blockers or pending verifications right now! You are in full flow.')
        else
          ...actionable.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 4. MARKETING LEAD COCKPIT
  // ==========================================
  Widget _buildMarketingCockpit(BuildContext context) {
    final mktgTasks =
        tasks.where((t) => t.department == DepartmentType.marketing).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'CAMPUS GROWTH & BUZZ DESK',
          badgeColor: const Color(0xFFEC4899),
          title: 'Campus Viral Command',
          subtitle:
              'Targeting 1,200 registrations across engineering, science & management blocks.',
          metrics: [
            const _MetricItem('Ticket Funnel', '850/1200', Color(0xFFEC4899)),
            const _MetricItem(
                'Posters Deployed', '48 Hostels', Color(0xFF38BDF8)),
            const _MetricItem('Reel Views', '14.2K', GwdColors.emerald),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader('MARKETING ACTIONS', 'Drive student turnout'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.send_rounded,
                label: 'WhatsApp Blast',
                color: const Color(0xFF22C55E),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Broadcasting event registration link to 12 college batch groups!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.video_library_outlined,
                label: 'Sync with Cinema',
                color: const Color(0xFFEC4899),
                onTap: () {
                  onNudgeDepartment(DepartmentType.cinematography,
                      'Need the 15-second story cut for Instagram!');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader('MY MARKETING DELIVERABLES', 'Deliver and claim XP'),
        const SizedBox(height: 10),
        ...mktgTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 5. PR & CORPORATE RELATIONS COCKPIT
  // ==========================================
  Widget _buildPrCockpit(BuildContext context) {
    final prTasks = tasks
        .where((t) => t.department == DepartmentType.publicRelations)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'PR & CORPORATE DIPLOMACY',
          badgeColor: const Color(0xFF0D9488),
          title: 'Industry & VIP Protocol',
          subtitle:
              'Securing corporate sponsorships, keynote executives, faculty clearance, and media kits.',
          metrics: [
            const _MetricItem(
                'Sponsorship Closed', '\$4,500', Color(0xFF0D9488)),
            const _MetricItem('VIP Keynotes', '3 Confirmed', Color(0xFFEAB308)),
            const _MetricItem('MoU Signed', '2 Industry', GwdColors.emerald),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader(
            'PR PROTOCOL LEVERS', 'Sponsors and dignitary hospitality'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.verified,
                label: 'Submit MoU Proof',
                color: const Color(0xFF0D9488),
                onTap: () {
                  final task = prTasks
                      .where((t) => t.status == TaskStatus.inProgress)
                      .firstOrNull;
                  if (task != null) {
                    onSubmitProof(task.id,
                        'https://gwd.global/pr/signed-mou-sponsor.pdf');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Uploaded MoU proof for "${task.title}"!')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.apartment,
                label: 'Faculty Clearance',
                color: GwdColors.primaryRed,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Dean permission letter dispatched and stamped!')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader('PR & OUTREACH SPRINT', 'Key deliverables'),
        const SizedBox(height: 10),
        ...prTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 6. EVENT LOGISTICS & OPS COCKPIT
  // ==========================================
  Widget _buildEventOpsCockpit(BuildContext context) {
    final eventTasks = tasks
        .where((t) => t.department == DepartmentType.eventManagement)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'MASTER ON-GROUND OPS',
          badgeColor: const Color(0xFFF59E0B),
          title: 'Auditorium Floor & Logistics',
          subtitle:
              'Venue safety, run-of-show timing, badge scanning gates, and crowd transit.',
          metrics: [
            const _MetricItem('Stage Rigging', '92% Ready', Color(0xFFF59E0B)),
            const _MetricItem('ID Lanyards', '500 Ready', GwdColors.emerald),
            const _MetricItem('Run-of-Show', 'On Schedule', Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader(
            'FLOOR OPS ACTIONS', 'Maintain zero-downtime execution'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.qr_code_scanner,
                label: 'Entry Gate Check',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'All 4 QR registration scanners calibrated and tested!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.access_time_filled,
                label: 'Run-of-Show Cue',
                color: const Color(0xFF10B981),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Master schedule broadcasted to all department radios!')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader('EVENT OPS DELIVERABLES', 'Ground milestones'),
        const SizedBox(height: 10),
        ...eventTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 7. PRODUCTION & AV TECH COCKPIT
  // ==========================================
  Widget _buildProductionCockpit(BuildContext context) {
    final prodTasks =
        tasks.where((t) => t.department == DepartmentType.production).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'PRODUCTION & STAGE TECH',
          badgeColor: const Color(0xFFEA580C),
          title: 'Audiovisuals, Lighting & LED Tech',
          subtitle:
              'Controlling 4K LED backdrop, sound mix board, keynote slide transitions, and live stream rigs.',
          metrics: [
            const _MetricItem('LED Wall', '4K Calibrated', Color(0xFFEA580C)),
            const _MetricItem('Wireless Mics', '8 Tuned', GwdColors.emerald),
            const _MetricItem('Generator', 'Backup On', Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader('TECH ACTIONS', 'AV checks & asset staging'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.tv,
                label: 'LED Test Pattern',
                color: const Color(0xFFEA580C),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            '4K LED Wall color and latency benchmark passed!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.mic_none,
                label: 'Soundcheck Sign',
                color: const Color(0xFFF97316),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Stage audio mix verified with zero feedback delay.')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader('PRODUCTION SPRINT TASKS', 'Technical deliverables'),
        const SizedBox(height: 10),
        ...prodTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 8. CINEMATOGRAPHY & MEDIA COCKPIT
  // ==========================================
  Widget _buildCinemaCockpit(BuildContext context) {
    final cinemaTasks = tasks
        .where((t) => t.department == DepartmentType.cinematography)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'CINEMATOGRAPHY & MEDIA DECK',
          badgeColor: const Color(0xFFE11D48),
          title: 'High-Velocity Cinematic Coverage',
          subtitle:
              'Directing camera crews, capturing 4K drone shots, and cutting the official aftermovie reel.',
          metrics: [
            const _MetricItem('Footage Ingested', '128 GB', Color(0xFFE11D48)),
            const _MetricItem('Teaser Reel', 'Export Ready', GwdColors.emerald),
            const _MetricItem(
                'Cameras Deployed', '4 Cams + Drone', Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader('CINEMA ACTIONS', 'Reel production & shot lists'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.cloud_upload_outlined,
                label: 'Upload Master Cut',
                color: const Color(0xFFE11D48),
                onTap: () {
                  final task = cinemaTasks
                      .where((t) => t.status == TaskStatus.submitted)
                      .firstOrNull;
                  if (task != null) {
                    onTapTask(task);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Master 60s teaser uploaded to Frame.io vault!')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionPill(
                icon: Icons.flight_takeoff,
                label: 'Drone Flight Plan',
                color: const Color(0xFFF43F5E),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Campus aerial flight coordinates verified with safety team.')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader(
            'CINEMATOGRAPHY REEL DELIVERABLES', 'Media tasks & shot lists'),
        const SizedBox(height: 10),
        ...cinemaTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // 9. CLUB MEMBER / CREW COCKPIT
  // ==========================================
  Widget _buildMemberCockpit(BuildContext context) {
    final myTasks = tasks.where((t) => t.assigneeRole == activeRole).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          badgeText: 'MY SPRINT & SKILL GROWTH',
          badgeColor: activeRole.color,
          title:
              'Welcome to Your Craft, ${activeRole.defaultName.split(" ").first}',
          subtitle:
              'Execute deliverables, build verifiable proof of work, and unlock corporate credentials.',
          metrics: [
            _MetricItem(
                'My Tasks', '${myTasks.length} Active', activeRole.color),
            const _MetricItem('Reliability', '96.5%', GwdColors.emerald),
            const _MetricItem('XP Earned', '48 XP', Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionHeader('QUICK ACTION', 'Submit your work to level up'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionPill(
                icon: Icons.upload_file_rounded,
                label: 'Submit Proof of Work',
                color: activeRole.color,
                onTap: () {
                  final task = myTasks
                      .where((t) =>
                          t.status == TaskStatus.inProgress ||
                          t.status == TaskStatus.requested)
                      .firstOrNull;
                  if (task != null) {
                    onTapTask(task);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Select any task below to submit your proof!')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionHeader(
            'MY ACTIVE DELIVERABLES', 'Tap to complete and claim verification'),
        const SizedBox(height: 10),
        if (myTasks.isEmpty)
          _buildEmptyCard(
              'No pending tasks for your profile right now! Great job.')
        else
          ...myTasks.map((t) => _buildSimpleTaskCard(context, t)),
      ],
    );
  }

  // ==========================================
  // SHARED APPLE-STYLE UI HELPERS
  // ==========================================

  Widget _buildHeroBanner({
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required List<_MetricItem> metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GwdColors.obsidian,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: metrics.map((m) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildMetricTile(m.label, m.value, m.color),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: GwdColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: const TextStyle(
              fontSize: 11,
              color: GwdColors.textMuted,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppleBouncy(
      scaleFactor: 0.94,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTaskCard(BuildContext context, ClubTask task) {
    final isDone = task.status == TaskStatus.verified;

    return AppleBouncy(
      scaleFactor: 0.97,
      onTap: () => onTapTask(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GwdColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apple Interactive Squircle Checkbox
              AppleBouncy(
                scaleFactor: 0.85,
                onTap: () {
                  if (task.status == TaskStatus.verified) {
                    onTapTask(task);
                  } else if (task.status == TaskStatus.submitted) {
                    onTapTask(task);
                  } else {
                    onSubmitProof(
                        task.id, 'Deliverable completed and proof attached');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Deliverable "${task.title}" submitted for lead sign-off!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDone
                        ? GwdColors.emerald
                        : (task.status == TaskStatus.submitted
                            ? const Color(0xFFF59E0B)
                            : Colors.transparent),
                    border: Border.all(
                      color: isDone
                          ? GwdColors.emerald
                          : (task.status == TaskStatus.submitted
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFCBD5E1)),
                      width: 2,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: GwdColors.emerald.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : (task.status == TaskStatus.submitted
                          ? const Icon(Icons.hourglass_top,
                              size: 13, color: Colors.white)
                          : null),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: task.department.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.department.shortName.toUpperCase(),
                            style: TextStyle(
                                color: task.department.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: task.status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.status.label.toUpperCase(),
                            style: TextStyle(
                                color: task.status.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${task.points} XP',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: GwdColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? GwdColors.textSecondary
                            : GwdColors.textPrimary,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 12, color: GwdColors.textMuted),
                        const SizedBox(width: 4),
                        Text(task.dueLabel,
                            style: const TextStyle(
                                fontSize: 11, color: GwdColors.textSecondary)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 11, color: GwdColors.textMuted),
                      ],
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

  Widget _buildSupervisionTaskCard(BuildContext context, ClubTask task) {
    return AppleBouncy(
      scaleFactor: 0.97,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('SUBMITTED FOR AUDIT',
                      style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                Text(
                  task.department.displayName,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GwdColors.textSecondary),
                ),
                const Spacer(),
                Text('${task.points} XP',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: GwdColors.textPrimary)),
            if (task.proof != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link,
                        size: 14, color: GwdColors.primaryIndigo),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Proof: ${task.proof!}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: GwdColors.primaryIndigo,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => onTapTask(task),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Inspect SoW',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    onVerifyTask(task.id, activeRole, activeRole.defaultName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Endorsed & Verified "${task.title}" with GWD Corporate Signature!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.verified, size: 14),
                  label: const Text('Corporate Sign-off',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GwdColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: GwdColors.emerald, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: GwdColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
}
