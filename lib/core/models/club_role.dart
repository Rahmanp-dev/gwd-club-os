import 'package:flutter/material.dart';

enum ClubRole {
  gwdCeo,
  gwdCmo,
  president,
  vicePresident,
  generalSecretary,
  marketingLead,
  prLead,
  eventManagementLead,
  creativeLead,
  productionLead,
  cinematographerLead,
  clubMember,
}

extension ClubRoleDetails on ClubRole {
  String get keyName => name;

  String get title => switch (this) {
        ClubRole.gwdCeo => 'GWD Global CEO · Club Supervisor',
        ClubRole.gwdCmo => 'GWD Global CMO · Club Supervisor',
        ClubRole.president => 'President',
        ClubRole.vicePresident => 'Vice President',
        ClubRole.generalSecretary => 'General Secretary',
        ClubRole.marketingLead => 'Marketing Lead',
        ClubRole.prLead => 'PR & Corporate Outreach Lead',
        ClubRole.eventManagementLead => 'Event Management Lead',
        ClubRole.creativeLead => 'Creative Lead',
        ClubRole.productionLead => 'Production & AV Tech Lead',
        ClubRole.cinematographerLead => 'Cinematographer & Media Lead',
        ClubRole.clubMember => 'Department Member / Crew',
      };

  String get shortBadge => switch (this) {
        ClubRole.gwdCeo => 'GWD CEO',
        ClubRole.gwdCmo => 'GWD CMO',
        ClubRole.president => 'PRESIDENT',
        ClubRole.vicePresident => 'VP',
        ClubRole.generalSecretary => 'GEN SEC',
        ClubRole.marketingLead => 'MKTG LEAD',
        ClubRole.prLead => 'PR LEAD',
        ClubRole.eventManagementLead => 'EVENT LEAD',
        ClubRole.creativeLead => 'CREATIVE',
        ClubRole.productionLead => 'PRODUCTION',
        ClubRole.cinematographerLead => 'CINEMA LEAD',
        ClubRole.clubMember => 'MEMBER',
      };

  String get defaultName => switch (this) {
        ClubRole.gwdCeo => 'Mohd Abdul Rahman Pasha',
        ClubRole.gwdCmo => 'Mohammed Abdul Mudabbir',
        ClubRole.president => 'Aldrin Paul',
        ClubRole.vicePresident => 'Mohd Ismail',
        ClubRole.generalSecretary => 'Sravya',
        ClubRole.marketingLead => 'Anvitha',
        ClubRole.prLead => 'Tuba Azeem',
        ClubRole.eventManagementLead => 'Bhavya',
        ClubRole.creativeLead => 'Nishta',
        ClubRole.productionLead => 'Rahman Pasha',
        ClubRole.cinematographerLead => 'Burhan',
        ClubRole.clubMember => 'Club Member',
      };

  String get responsibility => switch (this) {
        ClubRole.gwdCeo =>
          'Strategic governance, corporate chapter charter, campus-to-corporate bridge audit and flagship sign-offs.',
        ClubRole.gwdCmo =>
          'Global brand guardianship, zero-headache creative quality checks, corporate sponsor deck pipeline and lead guidance.',
        ClubRole.president =>
          'Overall club leadership, corporate liaison with GWD Global, high-level sanctions and keynote vision.',
        ClubRole.vicePresident =>
          'Internal operating rhythm, cross-department orchestration, timeline velocity and blocker elimination.',
        ClubRole.generalSecretary =>
          'Administration, meeting minutes, college Dean administration clearance and governance compliance.',
        ClubRole.marketingLead =>
          'Campaign blitz, campus registrations, social media reels, hype generation and sponsor visibility.',
        ClubRole.prLead =>
          'Corporate sponsor relations, industry guest speaker invitations, VIP hospitality and executive MoUs.',
        ClubRole.eventManagementLead =>
          'On-ground logistics, venue permissions, crowd management, master run-of-show and stage transitions.',
        ClubRole.creativeLead =>
          'Visual design identity, keynote & stage LED graphics, promotional posters, branding consistency and UX.',
        ClubRole.productionLead =>
          'Stage AV design, sound checks, lighting, multi-mic rigs, presentation displays and technical setups.',
        ClubRole.cinematographerLead =>
          '4K teasers, event photography, highlight reels, drone shots, camera crew direction and same-day aftermovie.',
        ClubRole.clubMember =>
          'Hands-on execution, deliverable creation, on-ground support and industry skill building.',
      };

  String get departmentName => switch (this) {
        ClubRole.gwdCeo || ClubRole.gwdCmo => 'GWD Global HQ Supervision',
        ClubRole.president ||
        ClubRole.vicePresident ||
        ClubRole.generalSecretary =>
          'Executive Board',
        ClubRole.marketingLead => 'Marketing & Growth',
        ClubRole.prLead => 'PR & Corporate Relations',
        ClubRole.eventManagementLead => 'Event Logistics & Ops',
        ClubRole.creativeLead => 'Creative & Design',
        ClubRole.productionLead => 'Production & AV Tech',
        ClubRole.cinematographerLead => 'Cinematography & Media',
        ClubRole.clubMember => 'Assigned Department',
      };

  bool get isCompanySupervisor =>
      this == ClubRole.gwdCeo || this == ClubRole.gwdCmo;

  bool get isExecutive =>
      isCompanySupervisor ||
      this == ClubRole.president ||
      this == ClubRole.vicePresident ||
      this == ClubRole.generalSecretary;

  bool get isLead =>
      this == ClubRole.marketingLead ||
      this == ClubRole.prLead ||
      this == ClubRole.eventManagementLead ||
      this == ClubRole.creativeLead ||
      this == ClubRole.productionLead ||
      this == ClubRole.cinematographerLead;

  bool get canCreateEvents => isExecutive || isLead;

  bool get canVerifyTasks => isExecutive || isLead;

  Color get color => switch (this) {
        ClubRole.gwdCeo => const Color(0xFF09090B), // Executive Jet Black
        ClubRole.gwdCmo => const Color(0xFFDC2626), // GWD Crimson Red
        ClubRole.president => const Color(0xFFDC2626), // GWD Crimson Red
        ClubRole.vicePresident => const Color(0xFF991B1B), // Deep Ruby
        ClubRole.generalSecretary => const Color(0xFF18181B), // Obsidian
        ClubRole.marketingLead => const Color(0xFFEF4444), // Coral Red
        ClubRole.prLead => const Color(0xFFDC2626), // Crimson Red
        ClubRole.eventManagementLead => const Color(0xFF09090B), // Jet Black
        ClubRole.creativeLead => const Color(0xFFDC2626), // GWD Crimson Red
        ClubRole.productionLead => const Color(0xFF18181B), // Charcoal Black
        ClubRole.cinematographerLead => const Color(0xFF991B1B), // Deep Ruby
        ClubRole.clubMember => const Color(0xFF52525B), // Slate Grey
      };

  IconData get icon => switch (this) {
        ClubRole.gwdCeo => Icons.workspace_premium_rounded,
        ClubRole.gwdCmo => Icons.diamond_outlined,
        ClubRole.president => Icons.military_tech_outlined,
        ClubRole.vicePresident => Icons.hub_outlined,
        ClubRole.generalSecretary => Icons.gavel_outlined,
        ClubRole.marketingLead => Icons.campaign_outlined,
        ClubRole.prLead => Icons.handshake_outlined,
        ClubRole.eventManagementLead => Icons.event_available_outlined,
        ClubRole.creativeLead => Icons.palette_outlined,
        ClubRole.productionLead => Icons.tune_outlined,
        ClubRole.cinematographerLead => Icons.videocam_outlined,
        ClubRole.clubMember => Icons.badge_outlined,
      };
}
