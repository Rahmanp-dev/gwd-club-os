import 'package:flutter/material.dart';

import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import '../../core/models/department.dart';
import '../../core/models/member_profile.dart';

/// The front door. Instead of a fake email/password form, the club signs in by
/// identity: you pick your name once and the device remembers you. Everything
/// downstream — the home screen, the inbox, the permissions — is computed from
/// this choice, which is what makes each person's app genuinely their own.
class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    required this.members,
    required this.onSignIn,
    this.currentMemberId,
    this.isSwitching = false,
  });

  final List<MemberProfile> members;
  final void Function(String memberId) onSignIn;
  final String? currentMemberId;

  /// When true the page is presented as a sheet for changing desks rather than
  /// as the initial gate, so it shows a close affordance and a softer heading.
  final bool isSwitching;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MemberProfile> _filter(bool Function(MemberProfile) predicate) {
    final q = _query.trim().toLowerCase();
    return widget.members.where((m) {
      if (!predicate(m)) return false;
      if (q.isEmpty) return true;
      return m.name.toLowerCase().contains(q) ||
          m.role.title.toLowerCase().contains(q) ||
          m.department.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = GwdSpace.gutter(width);

    final groups = <_MemberGroup>[
      _MemberGroup(
        'GWD Global',
        'Company supervisors overseeing the chapter',
        _filter((m) => m.role.isCompanySupervisor),
      ),
      _MemberGroup(
        'Executive board',
        'Club leadership and governance',
        _filter((m) =>
            m.role.isExecutive && !m.role.isCompanySupervisor),
      ),
      _MemberGroup(
        'Department leads',
        'Own a department and sign off its work',
        _filter((m) => m.role.isLead),
      ),
      _MemberGroup(
        'Crew',
        'Execute deliverables and bank skill XP',
        _filter((m) => m.role == ClubRole.clubMember),
      ),
    ].where((g) => g.members.isNotEmpty).toList();

    var revealIndex = 0;

    return Scaffold(
      backgroundColor: GwdColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      gutter, widget.isSwitching ? 8 : 28, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: FluidReveal(
                      index: revealIndex++,
                      child: _buildHeader(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: FluidReveal(
                      index: revealIndex++,
                      child: _buildSearchField(context),
                    ),
                  ),
                ),
                for (final group in groups) ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 26, gutter, 0),
                    sliver: SliverToBoxAdapter(
                      child: FluidReveal(
                        index: revealIndex++,
                        child: SectionHeader(
                          title: group.title,
                          subtitle: group.subtitle,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverList.separated(
                      itemCount: group.members.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: GwdSpace.sm),
                      itemBuilder: (context, i) => FluidReveal(
                        index: revealIndex++,
                        child: _MemberTile(
                          member: group.members[i],
                          isCurrent:
                              group.members[i].id == widget.currentMemberId,
                          onTap: () => widget.onSignIn(group.members[i].id),
                        ),
                      ),
                    ),
                  ),
                ],
                if (groups.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 40, gutter, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'No one matches "${_searchController.text}".',
                        style: GwdType.callout
                            .copyWith(color: GwdColors.inkSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 44)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: GwdColors.surface,
                borderRadius: BorderRadius.circular(GwdRadius.md),
                border: Border.all(color: GwdColors.hairline),
                boxShadow: GwdShadow.resting(false),
              ),
              child: Image.asset(
                'assets/images/club_logo_red.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.hexagon_outlined,
                  color: GwdColors.primaryRed,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: GwdSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('GWD CLUB OS',
                      style: GwdType.headline.copyWith(
                        color: GwdColors.ink,
                        letterSpacing: 0.4,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    'Campus to corporate',
                    style: GwdType.footnote
                        .copyWith(color: GwdColors.inkTertiary),
                  ),
                ],
              ),
            ),
            if (widget.isSwitching)
              PressableScale(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GwdColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(GwdRadius.sm),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: GwdColors.inkSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: GwdSpace.xxl),
        Text(
          widget.isSwitching ? 'Change desk' : 'Who’s on deck?',
          style: GwdType.largeTitle.copyWith(color: GwdColors.ink),
        ),
        const SizedBox(height: GwdSpace.sm),
        Text(
          widget.isSwitching
              ? 'Open another desk to see the club from their side. Your own work stays exactly where it is.'
              : 'Pick your name. Your deliverables, your sign-offs and your department feed load from here.',
          style: GwdType.body.copyWith(color: GwdColors.inkSecondary),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GwdColors.surface,
        borderRadius: BorderRadius.circular(GwdRadius.md),
        border: Border.all(color: GwdColors.hairline),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: GwdType.callout.copyWith(color: GwdColors.ink),
        cursorColor: GwdColors.primaryRed,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search name, role or department',
          hintStyle:
              GwdType.callout.copyWith(color: GwdColors.inkTertiary),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: GwdColors.inkTertiary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: GwdColors.inkTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }
}

class _MemberGroup {
  const _MemberGroup(this.title, this.subtitle, this.members);
  final String title;
  final String subtitle;
  final List<MemberProfile> members;
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onTap,
    required this.isCurrent,
  });

  final MemberProfile member;
  final VoidCallback onTap;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final accent = member.department.color;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(GwdSpace.md),
      borderRadius: GwdRadius.lg,
      emphasis: isCurrent ? SurfaceEmphasis.live : SurfaceEmphasis.quiet,
      accent: GwdColors.primaryRed,
      child: Row(
        children: [
          MemberAvatar(member: member, size: 42),
          const SizedBox(width: GwdSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.name,
                  style: GwdType.headline.copyWith(color: GwdColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  member.role.title,
                  style:
                      GwdType.footnote.copyWith(color: GwdColors.inkSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: GwdSpace.sm),
          if (isCurrent)
            const GwdChip(
              label: 'SIGNED IN',
              color: GwdColors.primaryRed,
              dense: true,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${member.totalVerifiedPoints}',
                  style: GwdType.headline
                      .merge(GwdType.numeric)
                      .copyWith(color: accent),
                ),
                Text('XP',
                    style: GwdType.caption
                        .copyWith(color: GwdColors.inkTertiary, fontSize: 9)),
              ],
            ),
        ],
      ),
    );
  }
}

/// Circular initials badge tinted by the member's department. Used anywhere a
/// person appears, so identity reads consistently across the app.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 38,
    this.showRoleRing = true,
  });

  final MemberProfile member;
  final double size;
  final bool showRoleRing;

  @override
  Widget build(BuildContext context) {
    final accent = member.department.color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: showRoleRing
            ? Border.all(color: accent.withValues(alpha: 0.32), width: 1.4)
            : null,
      ),
      child: Text(
        member.initials,
        style: GwdType.caption.copyWith(
          color: accent,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
