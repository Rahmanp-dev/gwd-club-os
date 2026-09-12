import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mehnat_founder_os/core/models/club_event.dart';
import 'package:mehnat_founder_os/core/models/club_role.dart';
import 'package:mehnat_founder_os/core/models/club_task.dart';
import 'package:mehnat_founder_os/core/models/department.dart';
import 'package:mehnat_founder_os/core/services/ai_event_architect.dart';
import 'package:mehnat_founder_os/core/services/club_workspace_service.dart';
import 'package:mehnat_founder_os/main.dart';

void main() {
  testWidgets('renders GWD Club OS dashboard with widgets and branding', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GwdClubApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Brand Lockup
    expect(find.text('GWD CLUB OS'), findsOneWidget);
    expect(find.text('Campus to Corporate · Club Supervision'), findsOneWidget);

    // Verify Default Segmented Mode: President Command
    expect(find.text('PRESIDENT Command'), findsOneWidget);
    expect(find.text('Global War Room'), findsOneWidget);

    // Switch to Global War Room view
    await tester.tap(find.text('Global War Room'));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Active Flagship Radar widget
    expect(find.text('ACTIVE FLAGSHIP RADAR'), findsOneWidget);

    // Verify War Room Matrix widget
    expect(find.text('LIVE WAR ROOM & HANDSHAKE MESH'), findsOneWidget);

    // Verify Department Coordination Matrix widget
    expect(find.text('DEPARTMENT COORDINATION MATRIX'), findsOneWidget);

    // Scroll to Blocker Radar widget
    await tester.scrollUntilVisible(
      find.text('CROSS-DEPARTMENT BLOCKER RADAR'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CROSS-DEPARTMENT BLOCKER RADAR'), findsOneWidget);

    // Navigate to Events tab via Floating Glass Dock
    await tester.tap(find.text('Events'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Parallel Events & Summits'), findsOneWidget);

    // Navigate to Tasks tab via Floating Glass Dock
    await tester.tap(find.text('Tasks'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Interconnected Tasks'), findsOneWidget);

    // Navigate to Calendar tab via Floating Glass Dock
    await tester.tap(find.text('Calendar'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Upcoming Flagship Milestones', skipOffstage: false), findsOneWidget);

    // Navigate to Hierarchy tab via Floating Glass Dock
    await tester.tap(find.text('Hierarchy'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Campus-to-Corporate Hierarchy'), findsOneWidget);
    expect(find.text('EXECUTIVE BOARD'), findsOneWidget);
  });

  test('AI Event Architect decomposes event into multi-department tasks', () {
    final blueprint = AiEventArchitectService.generateBlueprint(
      title: 'GWD GenAI National Hackathon',
      themeTagline: 'Build production agentic workflows',
      category: EventCategory.hackathon,
      targetDate: DateTime.now().add(const Duration(days: 14)),
      venue: 'University Convention Hall',
      expectedFootfall: 400,
    );

    expect(blueprint.event.title, 'GWD GenAI National Hackathon');
    expect(blueprint.tasks.isNotEmpty, true);

    // Check all departments receive tasks
    final departments = blueprint.tasks.map((t) => t.department).toSet();
    expect(departments.contains(DepartmentType.executive), true);
    expect(departments.contains(DepartmentType.marketing), true);
    expect(departments.contains(DepartmentType.publicRelations), true);
    expect(departments.contains(DepartmentType.production), true);
    expect(departments.contains(DepartmentType.cinematography), true);
    expect(departments.contains(DepartmentType.eventManagement), true);

    // Check all tasks have pre-fed corporate skill XP and DoD
    for (final task in blueprint.tasks) {
      expect(task.corporateValueSkill.isNotEmpty, true);
      expect(task.definitionOfDone.isNotEmpty, true);
      expect(task.points > 0, true);
    }
  });

  test('ClubWorkspaceService handles proof submission and role verification', () {
    final service = ClubWorkspaceService();
    expect(service.tasks.isNotEmpty, true);

    final task = service.tasks.firstWhere((t) => t.status != TaskStatus.verified);
    service.submitProof(task.id, 'https://drive.google.com/test-proof.pdf');

    final updated = service.tasks.firstWhere((t) => t.id == task.id);
    expect(updated.status, TaskStatus.submitted);
    expect(updated.proof, 'https://drive.google.com/test-proof.pdf');

    // Verify as President
    service.verifyTask(task.id, ClubRole.president, 'Aarav Sharma');
    final verifiedTask = service.tasks.firstWhere((t) => t.id == task.id);
    expect(verifiedTask.status, TaskStatus.verified);
    expect(verifiedTask.verifiedByRole, ClubRole.president);
  });

  test('ClubWorkspaceService generates AI event and updates state reactive streams', () {
    final service = ClubWorkspaceService();
    final initialEventsCount = service.events.length;
    final initialTasksCount = service.tasks.length;

    service.generateAiEvent(
      title: 'GWD Winter Hackathon & Demo Day',
      themeTagline: '48 hours of rapid prototyping with industry mentors',
      category: EventCategory.hackathon,
      targetDate: DateTime.now().add(const Duration(days: 15)),
      venue: 'Auditorium 2',
      expectedFootfall: 300,
    );

    expect(service.events.length, initialEventsCount + 1);
    expect(service.tasks.length, initialTasksCount + 12);
    expect(service.events.first.title, 'GWD Winter Hackathon & Demo Day');
  });

  testWidgets('GWD Global CMO suite renders zero-headache controls and sponsor pipeline',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GwdClubApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Tap role switcher dropdown
    await tester.tap(find.text('PRESIDENT').first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('GWD CMO').last);
    await tester.pump(const Duration(milliseconds: 500));

    // Verify CMO Suite is rendered
    expect(find.text('GWD GLOBAL CMO · EXECUTIVE BRAND SUITE'), findsOneWidget);
    expect(find.text('Zero-Headache Brand Guardianship'), findsOneWidget);
    expect(find.text('Brand Seal All'), findsOneWidget);
    expect(find.text('Sponsor Bridge'), findsOneWidget);
    expect(find.text('Viral Boost'), findsOneWidget);
    expect(find.text('Active Corporate Brand Deals'), findsOneWidget);

    // Flush timers
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('renders Web Landing Page concept with APK download CTA and simulator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GwdClubApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Web Landing toggle button
    expect(find.text('Web'), findsOneWidget);
    await tester.tap(find.text('Web'));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Web Landing Page content
    expect(find.text('GWD GET WORK DONE CLUB'), findsOneWidget);
    expect(find.text('Download APK'), findsOneWidget);
    expect(find.text('Launch Web OS'), findsOneWidget);
    expect(find.text('TEST DRIVE ANY LEADERSHIP DESK'), findsOneWidget);

    // Launch back into app
    await tester.tap(find.text('Launch Web OS'));
    await tester.pump(const Duration(milliseconds: 500));

    // Back to dashboard
    expect(find.text('GWD CLUB OS'), findsOneWidget);

    // Flush timers
    await tester.pump(const Duration(seconds: 6));
  });
}

