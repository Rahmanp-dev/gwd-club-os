import 'package:flutter/material.dart';
import 'club_role.dart';

enum DepartmentType {
  executive,
  marketing,
  publicRelations,
  eventManagement,
  creative,
  production,
  cinematography,
}

extension DepartmentTypeDetails on DepartmentType {
  String get displayName => switch (this) {
        DepartmentType.executive => 'Executive Board',
        DepartmentType.marketing => 'Marketing & Growth',
        DepartmentType.publicRelations => 'PR & Corporate Relations',
        DepartmentType.eventManagement => 'Event Logistics & Ops',
        DepartmentType.creative => 'Creative & Brand Design',
        DepartmentType.production => 'Production & AV Tech',
        DepartmentType.cinematography => 'Cinematography & Media',
      };

  String get shortName => switch (this) {
        DepartmentType.executive => 'Executive',
        DepartmentType.marketing => 'Marketing',
        DepartmentType.publicRelations => 'PR & Corporate',
        DepartmentType.eventManagement => 'Event Ops',
        DepartmentType.creative => 'Creative',
        DepartmentType.production => 'Production',
        DepartmentType.cinematography => 'Cinema & Media',
      };

  ClubRole get leadRole => switch (this) {
        DepartmentType.executive => ClubRole.president,
        DepartmentType.marketing => ClubRole.marketingLead,
        DepartmentType.publicRelations => ClubRole.prLead,
        DepartmentType.eventManagement => ClubRole.eventManagementLead,
        DepartmentType.creative => ClubRole.creativeLead,
        DepartmentType.production => ClubRole.productionLead,
        DepartmentType.cinematography => ClubRole.cinematographerLead,
      };

  Color get color => switch (this) {
        DepartmentType.executive => const Color(0xFF09090B), // Executive Jet Black
        DepartmentType.marketing => const Color(0xFFEF4444), // Coral Red
        DepartmentType.publicRelations => const Color(0xFFDC2626), // GWD Crimson Red
        DepartmentType.eventManagement => const Color(0xFF18181B), // Charcoal Black
        DepartmentType.creative => const Color(0xFFDC2626), // GWD Crimson Red
        DepartmentType.production => const Color(0xFF27272A), // Dark Jet
        DepartmentType.cinematography => const Color(0xFF991B1B), // Deep Ruby
      };

  IconData get icon => switch (this) {
        DepartmentType.executive => Icons.shield_outlined,
        DepartmentType.marketing => Icons.trending_up_outlined,
        DepartmentType.publicRelations => Icons.handshake_outlined,
        DepartmentType.eventManagement => Icons.location_city_outlined,
        DepartmentType.creative => Icons.palette_outlined,
        DepartmentType.production => Icons.settings_input_component_outlined,
        DepartmentType.cinematography => Icons.movie_filter_outlined,
      };

  List<String> get corporateSkills => switch (this) {
        DepartmentType.executive => [
            'Executive Governance',
            'Cross-functional Alignment',
            'Strategic Budgeting',
          ],
        DepartmentType.marketing => [
            'Campaign ROI & Growth',
            'Campus Brand Narrative',
            'Funnel Conversion',
          ],
        DepartmentType.publicRelations => [
            'Corporate Sponsorship Pitching',
            'Industry Speaker Protocol',
            'High-stakes Networking',
          ],
        DepartmentType.eventManagement => [
            'Run-of-Show Protocol',
            'Crisis Mitigation',
            'Crowd Engineering',
          ],
        DepartmentType.creative => [
            'Brand Design Systems',
            'Keynote & Stage Graphics',
            'Visual Storytelling & UI',
          ],
        DepartmentType.production => [
            'Stage AV Engineering',
            'Broadcast Tech Ops',
            'Brand Collateral Delivery',
          ],
        DepartmentType.cinematography => [
            'Aftermovie Storyboarding',
            'High-velocity Video Turnaround',
            'Visual Brand Aesthetics',
          ],
      };
}
