import '../models/club_event.dart';
import '../models/club_role.dart';
import '../models/club_task.dart';
import '../models/collaboration.dart';
import '../models/department.dart';
import '../models/member_profile.dart';

/// The club's starting state. Kept out of the service so the service stays
/// about behaviour, and so a reset is a single call to [SeedWorkspace.build].
///
/// Dates are all relative to "now" so the app never opens showing a flagship
/// event that happened last year.
class SeedWorkspace {
  const SeedWorkspace._();

  static WorkspaceSnapshot build() {
    final now = DateTime.now();
    final events = _events(now);
    final flagship = events.first;
    final members = _members();
    final tasks = _tasks(now, flagship.id);
    final handoffs = _handoffs(now, members, tasks);
    final messages = _messages(now, members);
    final activity = _activity(now, members, tasks, handoffs);

    return WorkspaceSnapshot(
      events: events,
      tasks: tasks,
      members: members,
      handoffs: handoffs,
      messages: messages,
      activity: activity,
    );
  }

  // --- Events -------------------------------------------------------------

  static List<ClubEvent> _events(DateTime now) => [
        ClubEvent(
          id: 'ev-flagship-gwd',
          title: 'GWD TechConnect: Campus to Corporate Summit',
          themeTagline:
              'Bridging academic theory and industry practice in one day.',
          category: EventCategory.flagship,
          targetDate: now.add(const Duration(days: 16)),
          venue: 'University Convention Centre & Innovation Lab',
          expectedFootfall: 550,
          status: EventStatus.inProgress,
          budgetLabel: '₹85,000',
          isFlagship: true,
          runOfShow: const [
            EventRunOfShowItem(
              time: '09:00',
              title: 'Delegate registration & welcome kits',
              department: 'Event Logistics & Ops',
              ownerName: 'Bhavya',
              notes: 'Pre-printed badges, QR scanner gates open',
            ),
            EventRunOfShowItem(
              time: '10:00',
              title: 'Opening keynote',
              department: 'Executive Board',
              ownerName: 'Aldrin Paul',
              notes: 'Keynote deck on main LED wall',
            ),
            EventRunOfShowItem(
              time: '11:30',
              title: 'Industry panel: what employers actually expect',
              department: 'PR & Corporate Relations',
              ownerName: 'Tuba Azeem',
              notes: 'Four panellists confirmed',
            ),
            EventRunOfShowItem(
              time: '13:00',
              title: 'Stage LED & brand visual lock',
              department: 'Creative & Brand Design',
              ownerName: 'Nishta',
              notes: 'Backdrop motion graphics verified and locked',
            ),
            EventRunOfShowItem(
              time: '14:00',
              title: 'Breakout tracks & live demos',
              department: 'Production & AV Tech',
              ownerName: 'Rahman Pasha',
              notes: 'Three parallel rooms, mic handover every 20 min',
            ),
            EventRunOfShowItem(
              time: '16:30',
              title: 'Awards & same-day aftermovie premiere',
              department: 'Cinematography & Media',
              ownerName: 'Burhan',
              notes: '90-second cut played on the main screen',
            ),
          ],
        ),
        ClubEvent(
          id: 'ev-workshop-genai',
          title: 'GenAI & Cloud Architecture Workshop',
          themeTagline: 'Hands-on build session with production tooling.',
          category: EventCategory.workshop,
          targetDate: now.add(const Duration(days: 6)),
          venue: 'Engineering Lab 4',
          expectedFootfall: 140,
          status: EventStatus.inProgress,
          budgetLabel: '₹22,000',
        ),
      ];

  // --- People -------------------------------------------------------------

  static List<MemberProfile> _members() => const [
        // GWD Global — company supervisors overseeing the college chapter.
        MemberProfile(
          id: 'mem-ceo',
          name: 'Mohd Abdul Rahman Pasha',
          role: ClubRole.gwdCeo,
          department: DepartmentType.executive,
          yearAndMajor: 'GWD Global · Chief Executive Officer',
          totalVerifiedPoints: 125,
          reliabilityRate: 99.8,
          badges: ['Chapter Supervisor', 'Corporate Mentor'],
          corporateSkillsEarned: {
            'Enterprise Governance': 50,
            'Campus-to-Corporate Strategy': 45,
            'Strategic Budget Allocation': 42,
          },
        ),
        MemberProfile(
          id: 'mem-cmo',
          name: 'Mohammed Abdul Mudabbir',
          role: ClubRole.gwdCmo,
          department: DepartmentType.executive,
          yearAndMajor: 'GWD Global · Chief Marketing Officer',
          totalVerifiedPoints: 118,
          reliabilityRate: 99.6,
          badges: ['Brand Custodian', 'Chapter Supervisor'],
          corporateSkillsEarned: {
            'Global Brand Architecture': 48,
            'Corporate Sponsorship Closures': 44,
            'Creative Quality Audit': 40,
          },
        ),

        // Executive board.
        MemberProfile(
          id: 'mem-president',
          name: 'Aldrin Paul',
          role: ClubRole.president,
          department: DepartmentType.executive,
          yearAndMajor: '4th Year · President',
          totalVerifiedPoints: 78,
          reliabilityRate: 98.6,
          badges: ['Executive Leader', 'Keynote Speaker'],
          corporateSkillsEarned: {
            'Executive Governance': 28,
            'Strategic Budgeting': 22,
            'Corporate Sponsorship Pitching': 28,
          },
        ),
        MemberProfile(
          id: 'mem-vp',
          name: 'Mohd Ismail',
          role: ClubRole.vicePresident,
          department: DepartmentType.executive,
          yearAndMajor: '4th Year · Vice President',
          totalVerifiedPoints: 68,
          reliabilityRate: 98.2,
          badges: ['Operations Maestro', 'Cross-Functional Catalyst'],
          corporateSkillsEarned: {
            'Cross-functional Alignment': 36,
            'Timeline Velocity': 28,
          },
        ),
        MemberProfile(
          id: 'mem-gensec',
          name: 'Sravya',
          role: ClubRole.generalSecretary,
          department: DepartmentType.executive,
          yearAndMajor: '3rd Year · General Secretary',
          totalVerifiedPoints: 56,
          reliabilityRate: 97.0,
          badges: ['Governance Master', 'Dean Protocol'],
          corporateSkillsEarned: {
            'Institutional Clearance': 32,
            'Statutory Documentation': 24,
          },
        ),

        // Department leads.
        MemberProfile(
          id: 'mem-marketing',
          name: 'Anvitha',
          role: ClubRole.marketingLead,
          department: DepartmentType.marketing,
          yearAndMajor: '3rd Year · Marketing & Growth Lead',
          totalVerifiedPoints: 62,
          reliabilityRate: 96.8,
          badges: ['Growth Hacker', 'Campus Viralist'],
          corporateSkillsEarned: {
            'Campaign ROI & Growth': 38,
            'Audience Acquisition': 24,
          },
        ),
        MemberProfile(
          id: 'mem-pr',
          name: 'Tuba Azeem',
          role: ClubRole.prLead,
          department: DepartmentType.publicRelations,
          yearAndMajor: '4th Year · PR & Corporate Relations Lead',
          totalVerifiedPoints: 70,
          reliabilityRate: 98.5,
          badges: ['Sponsorship Closer', 'MoU Specialist'],
          corporateSkillsEarned: {
            'Corporate Sponsorship Pitching': 42,
            'Keynote Negotiation': 28,
          },
        ),
        MemberProfile(
          id: 'mem-events',
          name: 'Bhavya',
          role: ClubRole.eventManagementLead,
          department: DepartmentType.eventManagement,
          yearAndMajor: '3rd Year · Event Management & Logistics Lead',
          totalVerifiedPoints: 58,
          reliabilityRate: 96.2,
          badges: ['Logistics Commander', 'Run-of-Show Architect'],
          corporateSkillsEarned: {
            'Run-of-Show Protocol': 32,
            'Crowd Engineering': 26,
          },
        ),
        MemberProfile(
          id: 'mem-creative',
          name: 'Nishta',
          role: ClubRole.creativeLead,
          department: DepartmentType.creative,
          yearAndMajor: '3rd Year · Creative & Brand Lead',
          totalVerifiedPoints: 64,
          reliabilityRate: 97.5,
          badges: ['Design Visionary', 'Brand Maestro'],
          corporateSkillsEarned: {
            'Brand Design Systems': 36,
            'Visual Storytelling & UI': 28,
          },
        ),
        MemberProfile(
          id: 'mem-production',
          name: 'Rahman Pasha',
          role: ClubRole.productionLead,
          department: DepartmentType.production,
          yearAndMajor: 'Production & AV Tech Lead (interim)',
          totalVerifiedPoints: 60,
          reliabilityRate: 98.0,
          badges: ['AV Virtuoso', 'Stage Tech Director'],
          corporateSkillsEarned: {
            'Stage AV Engineering': 35,
            'Live Technical Setup': 25,
          },
        ),
        MemberProfile(
          id: 'mem-cinema',
          name: 'Burhan',
          role: ClubRole.cinematographerLead,
          department: DepartmentType.cinematography,
          yearAndMajor: '3rd Year · Cinematographer & Media Lead',
          totalVerifiedPoints: 66,
          reliabilityRate: 98.0,
          badges: ['Cinematic Visionary', 'Rapid Turnaround Pro'],
          corporateSkillsEarned: {
            'Commercial Video Production': 40,
            'Aftermovie Storyboarding': 26,
          },
        ),

        // Crew. Every department needs people, not just a lead.
        MemberProfile(
          id: 'mem-rhea',
          name: 'Rhea Sen',
          role: ClubRole.clubMember,
          department: DepartmentType.publicRelations,
          yearAndMajor: '2nd Year · PR Associate',
          totalVerifiedPoints: 38,
          reliabilityRate: 95.5,
          badges: ['Rising PR Associate'],
          corporateSkillsEarned: {
            'VIP Hospitality & Logistics': 24,
            'Corporate Outreach': 14,
          },
        ),
        MemberProfile(
          id: 'mem-karan',
          name: 'Karan Mehta',
          role: ClubRole.clubMember,
          department: DepartmentType.marketing,
          yearAndMajor: '2nd Year · Growth Associate',
          totalVerifiedPoints: 26,
          reliabilityRate: 93.8,
          badges: ['Campus Recruiter'],
          corporateSkillsEarned: {'Funnel Conversion': 16, 'Copywriting': 10},
        ),
        MemberProfile(
          id: 'mem-ayesha',
          name: 'Ayesha Khan',
          role: ClubRole.clubMember,
          department: DepartmentType.creative,
          yearAndMajor: '2nd Year · Design Associate',
          totalVerifiedPoints: 31,
          reliabilityRate: 94.6,
          badges: ['Poster Machine'],
          corporateSkillsEarned: {'Layout & Typography': 19, 'Motion Basics': 12},
        ),
        MemberProfile(
          id: 'mem-dev',
          name: 'Dev Raj',
          role: ClubRole.clubMember,
          department: DepartmentType.eventManagement,
          yearAndMajor: '1st Year · Ops Crew',
          totalVerifiedPoints: 18,
          reliabilityRate: 92.0,
          badges: ['Ground Crew'],
          corporateSkillsEarned: {'Venue Coordination': 12},
        ),
        MemberProfile(
          id: 'mem-farhan',
          name: 'Farhan Ali',
          role: ClubRole.clubMember,
          department: DepartmentType.cinematography,
          yearAndMajor: '2nd Year · Camera Assistant',
          totalVerifiedPoints: 22,
          reliabilityRate: 94.0,
          badges: ['Second Shooter'],
          corporateSkillsEarned: {'Camera Operation': 14, 'Photo Culling': 8},
        ),
      ];

  // --- Deliverables -------------------------------------------------------

  static List<ClubTask> _tasks(DateTime now, String eventId) => [
        ClubTask(
          id: 'task-dean-permission',
          eventId: eventId,
          title: 'Confirm Dean permission and security escort sanction',
          department: DepartmentType.executive,
          assigneeRole: ClubRole.generalSecretary,
          assigneeName: 'Sravya',
          creatorRole: ClubRole.president,
          points: 8,
          dueLabel: 'Completed yesterday',
          dueDate: now.subtract(const Duration(days: 1)),
          definitionOfDone: 'Signed letter from the Dean uploaded to Drive.',
          status: TaskStatus.verified,
          corporateValueSkill: 'Executive Governance & Clearance',
          proof: 'Signed letter uploaded to the club Drive.',
          verifiedByRole: ClubRole.president,
          verifiedByName: 'Aldrin Paul',
        ),
        ClubTask(
          id: 'task-sponsors',
          eventId: eventId,
          title: 'Close title sponsor and two associate partners',
          department: DepartmentType.publicRelations,
          assigneeRole: ClubRole.prLead,
          assigneeName: 'Tuba Azeem',
          creatorRole: ClubRole.president,
          points: 13,
          dueLabel: 'Completed 2 days ago',
          dueDate: now.subtract(const Duration(days: 2)),
          definitionOfDone: 'MoUs signed covering the ₹50,000 sponsorship pool.',
          status: TaskStatus.verified,
          corporateValueSkill: 'Corporate Sponsorship Pitching',
          proof: 'Signed MoUs with both partners filed.',
          verifiedByRole: ClubRole.president,
          verifiedByName: 'Aldrin Paul',
        ),
        ClubTask(
          id: 'task-teaser',
          eventId: eventId,
          title: 'Edit and export the 60-second cinematic teaser',
          department: DepartmentType.cinematography,
          assigneeRole: ClubRole.cinematographerLead,
          assigneeName: 'Burhan',
          creatorRole: ClubRole.vicePresident,
          points: 13,
          dueLabel: 'Today · 17:00',
          dueDate: now,
          definitionOfDone: 'Delivered in 9:16 and 16:9 with captions.',
          status: TaskStatus.submitted,
          corporateValueSkill: 'High-Impact Video Production',
          scopeOfWork:
              'Cut from the campus b-roll shoot, licensed track, brand end-card.',
          downstreamImpact:
              'Marketing cannot start the registration push without it.',
          proof: 'Draft render shared for review; MP4 ready.',
        ),
        ClubTask(
          id: 'task-keynote-deck',
          eventId: eventId,
          title: 'Design the keynote deck, stage graphics and badge system',
          department: DepartmentType.creative,
          assigneeRole: ClubRole.creativeLead,
          assigneeName: 'Nishta',
          creatorRole: ClubRole.gwdCmo,
          points: 12,
          dueLabel: 'Today · 16:00',
          dueDate: now,
          definitionOfDone:
              'Figma package with keynote templates, stage motion graphics and badge art.',
          status: TaskStatus.submitted,
          corporateValueSkill: 'Brand Design Systems & UX',
          scopeOfWork: 'Full visual set for stage, print and screen.',
          proof: 'Figma workspace shared with all keynote templates.',
        ),
        ClubTask(
          id: 'task-camera-cues',
          eventId: eventId,
          title: 'Lock multi-camera stage cues and speaker lighting angles',
          department: DepartmentType.cinematography,
          assigneeRole: ClubRole.cinematographerLead,
          assigneeName: 'Burhan',
          creatorRole: ClubRole.vicePresident,
          points: 8,
          dueLabel: 'Tomorrow',
          dueDate: now.add(const Duration(days: 1)),
          definitionOfDone:
              'Camera placement map signed off against the stage flow.',
          status: TaskStatus.blocked,
          blocker: 'Waiting on the final stage layout and podium position.',
          blockedByDepartment: DepartmentType.eventManagement,
          corporateValueSkill: 'Broadcast Technical Direction',
          severity: TaskSeverity.highImpact,
          upstreamDependency: 'Event Ops stage layout',
        ),
        ClubTask(
          id: 'task-registration-drive',
          eventId: eventId,
          title: 'Run the campus registration drive to 350 confirmed seats',
          department: DepartmentType.marketing,
          assigneeRole: ClubRole.marketingLead,
          assigneeName: 'Anvitha',
          creatorRole: ClubRole.vicePresident,
          points: 8,
          dueLabel: 'Friday',
          dueDate: now.add(const Duration(days: 3)),
          definitionOfDone: '350+ verified student registrations recorded.',
          status: TaskStatus.inProgress,
          corporateValueSkill: 'Growth Funnel & Acquisition',
          downstreamImpact: 'Event Ops sizes catering and seating off this number.',
        ),
        ClubTask(
          id: 'task-reels',
          eventId: eventId,
          title: 'Publish three countdown reels on club social',
          department: DepartmentType.marketing,
          assigneeRole: ClubRole.clubMember,
          assigneeName: 'Karan Mehta',
          creatorRole: ClubRole.marketingLead,
          points: 5,
          dueLabel: 'In 2 days',
          dueDate: now.add(const Duration(days: 2)),
          definitionOfDone: 'Three reels live with the registration link in bio.',
          status: TaskStatus.inProgress,
          corporateValueSkill: 'Short-form Content & Reach',
        ),
        ClubTask(
          id: 'task-vip-hospitality',
          eventId: eventId,
          title: 'Coordinate speaker travel, green room and hospitality kits',
          department: DepartmentType.publicRelations,
          assigneeRole: ClubRole.clubMember,
          assigneeName: 'Rhea Sen',
          creatorRole: ClubRole.prLead,
          points: 5,
          dueLabel: 'In 4 days',
          dueDate: now.add(const Duration(days: 4)),
          definitionOfDone:
              'Travel times, hotel bookings and vehicle passes confirmed.',
          status: TaskStatus.inProgress,
          corporateValueSkill: 'VIP Hospitality & Logistics',
        ),
        ClubTask(
          id: 'task-lanyards',
          eventId: eventId,
          title: 'Procure 500 lanyards, delegate IDs and QR scanners',
          department: DepartmentType.eventManagement,
          assigneeRole: ClubRole.eventManagementLead,
          assigneeName: 'Bhavya',
          creatorRole: ClubRole.vicePresident,
          points: 8,
          dueLabel: 'In 5 days',
          dueDate: now.add(const Duration(days: 5)),
          definitionOfDone: 'Delivery received and counted at the club room.',
          status: TaskStatus.committed,
          corporateValueSkill: 'Vendor Procurement & Negotiation',
        ),
        ClubTask(
          id: 'task-stage-layout',
          eventId: eventId,
          title: 'Publish the final stage layout and podium position',
          department: DepartmentType.eventManagement,
          assigneeRole: ClubRole.eventManagementLead,
          assigneeName: 'Bhavya',
          creatorRole: ClubRole.vicePresident,
          points: 8,
          dueLabel: 'Tomorrow',
          dueDate: now.add(const Duration(days: 1)),
          definitionOfDone:
              'Dimensioned layout shared with Production and Cinematography.',
          status: TaskStatus.inProgress,
          corporateValueSkill: 'Run-of-Show Protocol',
          severity: TaskSeverity.missionCritical,
          downstreamImpact:
              'Camera cues and the AV rig are both waiting on this.',
        ),
        ClubTask(
          id: 'task-av-rig',
          eventId: eventId,
          title: 'Spec the AV rig: mics, monitors and LED feed chain',
          department: DepartmentType.production,
          assigneeRole: ClubRole.productionLead,
          assigneeName: 'Rahman Pasha',
          creatorRole: ClubRole.president,
          points: 8,
          dueLabel: 'In 3 days',
          dueDate: now.add(const Duration(days: 3)),
          definitionOfDone: 'Signed equipment list with the vendor quote attached.',
          status: TaskStatus.inProgress,
          corporateValueSkill: 'Stage AV Engineering',
          upstreamDependency: 'Event Ops stage layout',
        ),
        ClubTask(
          id: 'task-photo-crew',
          eventId: eventId,
          title: 'Brief the photo crew and build the shot list',
          department: DepartmentType.cinematography,
          assigneeRole: ClubRole.clubMember,
          assigneeName: 'Farhan Ali',
          creatorRole: ClubRole.cinematographerLead,
          points: 3,
          dueLabel: 'In 6 days',
          dueDate: now.add(const Duration(days: 6)),
          definitionOfDone: 'Shot list covering every run-of-show segment.',
          status: TaskStatus.requested,
          corporateValueSkill: 'Visual Documentation',
        ),
        ClubTask(
          id: 'task-badge-print',
          eventId: eventId,
          title: 'Send delegate badges to print',
          department: DepartmentType.creative,
          assigneeRole: ClubRole.clubMember,
          assigneeName: 'Ayesha Khan',
          creatorRole: ClubRole.creativeLead,
          points: 3,
          dueLabel: 'In 7 days',
          dueDate: now.add(const Duration(days: 7)),
          definitionOfDone: 'Print-ready PDFs delivered with bleed marks.',
          status: TaskStatus.requested,
          corporateValueSkill: 'Print Production',
          upstreamDependency: 'Final registration count from Marketing',
        ),
        ClubTask(
          id: 'task-venue-walkthrough',
          eventId: eventId,
          title: 'Run the venue walkthrough with the crew',
          department: DepartmentType.eventManagement,
          assigneeRole: ClubRole.clubMember,
          assigneeName: 'Dev Raj',
          creatorRole: ClubRole.eventManagementLead,
          points: 3,
          dueLabel: 'In 8 days',
          dueDate: now.add(const Duration(days: 8)),
          definitionOfDone: 'Walkthrough notes and station map circulated.',
          status: TaskStatus.requested,
          corporateValueSkill: 'Venue Coordination',
        ),
      ];

  // --- Cross-department handoffs -----------------------------------------

  static List<Handoff> _handoffs(
    DateTime now,
    List<MemberProfile> members,
    List<ClubTask> tasks,
  ) =>
      [
        Handoff(
          id: 'ho-stage-layout',
          title: 'Final stage layout & podium position',
          need:
              'Dimensioned layout so camera positions and the AV rig can be locked.',
          fromDepartment: DepartmentType.cinematography,
          toDepartment: DepartmentType.eventManagement,
          requestedById: 'mem-cinema',
          requestedByName: 'Burhan',
          createdAt: now.subtract(const Duration(days: 2)),
          neededBy: now.add(const Duration(days: 1)),
          taskId: 'task-camera-cues',
        ),
        Handoff(
          id: 'ho-registration-count',
          title: 'Confirmed registration count',
          need:
              'Final headcount to size badge print run, catering and seating.',
          fromDepartment: DepartmentType.creative,
          toDepartment: DepartmentType.marketing,
          requestedById: 'mem-creative',
          requestedByName: 'Nishta',
          createdAt: now.subtract(const Duration(days: 1)),
          neededBy: now.add(const Duration(days: 4)),
          status: HandoffStatus.accepted,
          respondedById: 'mem-marketing',
          respondedByName: 'Anvitha',
          respondedAt: now.subtract(const Duration(hours: 6)),
          responseNote: 'Will share the verified tally on Friday evening.',
          taskId: 'task-badge-print',
        ),
        Handoff(
          id: 'ho-teaser-assets',
          title: 'Brand end-card & logo pack for the teaser',
          need: 'Animated end-card plus sponsor lockups at 4K.',
          fromDepartment: DepartmentType.cinematography,
          toDepartment: DepartmentType.creative,
          requestedById: 'mem-cinema',
          requestedByName: 'Burhan',
          createdAt: now.subtract(const Duration(days: 4)),
          neededBy: now.subtract(const Duration(days: 1)),
          status: HandoffStatus.delivered,
          respondedById: 'mem-creative',
          respondedByName: 'Nishta',
          respondedAt: now.subtract(const Duration(days: 2)),
          responseNote: 'Delivered with both light and dark variants.',
          taskId: 'task-teaser',
        ),
      ];

  // --- Threads ------------------------------------------------------------

  static List<CollabMessage> _messages(
          DateTime now, List<MemberProfile> members) =>
      [
        CollabMessage(
          id: 'msg-1',
          taskId: 'task-camera-cues',
          authorId: 'mem-cinema',
          authorName: 'Burhan',
          authorRole: ClubRole.cinematographerLead,
          body:
              '@Bhavya I can rig three positions, but I need the podium offset before I can commit the wide angle.',
          createdAt: now.subtract(const Duration(hours: 20)),
          mentions: ['mem-events'],
        ),
        CollabMessage(
          id: 'msg-2',
          taskId: 'task-camera-cues',
          authorId: 'mem-events',
          authorName: 'Bhavya',
          authorRole: ClubRole.eventManagementLead,
          body:
              'Venue confirms the podium sits 2.4m from stage left. Publishing the full layout tomorrow morning.',
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
        CollabMessage(
          id: 'msg-3',
          taskId: 'task-teaser',
          authorId: 'mem-cmo',
          authorName: 'Mohammed Abdul Mudabbir',
          authorRole: ClubRole.gwdCmo,
          body:
              'Colour grade is on brand. Hold the logo two frames longer on the end-card and this is approved.',
          createdAt: now.subtract(const Duration(hours: 2)),
          isDecision: true,
        ),
        CollabMessage(
          id: 'msg-4',
          taskId: 'task-registration-drive',
          authorId: 'mem-marketing',
          authorName: 'Anvitha',
          authorRole: ClubRole.marketingLead,
          body:
              '212 confirmed so far. The second-year push lands tomorrow, which should close the gap.',
          createdAt: now.subtract(const Duration(hours: 9)),
        ),
      ];

  // --- Opening feed -------------------------------------------------------

  static List<ActivityEvent> _activity(
    DateTime now,
    List<MemberProfile> members,
    List<ClubTask> tasks,
    List<Handoff> handoffs,
  ) =>
      [
        ActivityEvent(
          id: 'act-1',
          kind: ActivityKind.blockerRaised,
          title: 'Blocker raised',
          body:
              'Event Ops is blocking "Lock multi-camera stage cues": waiting on the final stage layout.',
          timestamp: now.subtract(const Duration(hours: 20)),
          actorId: 'mem-cinema',
          actorName: 'Burhan',
          targetMemberIds: ['mem-events', 'mem-dev'],
          taskId: 'task-camera-cues',
          department: DepartmentType.eventManagement,
          read: true,
        ),
        ActivityEvent(
          id: 'act-2',
          kind: ActivityKind.proofSubmitted,
          title: 'Proof submitted',
          body: '"Edit and export the 60-second cinematic teaser" is ready for sign-off.',
          timestamp: now.subtract(const Duration(hours: 3)),
          actorId: 'mem-cinema',
          actorName: 'Burhan',
          targetMemberIds: ['mem-president', 'mem-vp', 'mem-cmo'],
          taskId: 'task-teaser',
          department: DepartmentType.cinematography,
          read: true,
        ),
        ActivityEvent(
          id: 'act-3',
          kind: ActivityKind.handoffAccepted,
          title: 'Handoff accepted',
          body: 'Anvitha accepted "Confirmed registration count" for Creative.',
          timestamp: now.subtract(const Duration(hours: 6)),
          actorId: 'mem-marketing',
          actorName: 'Anvitha',
          targetMemberIds: ['mem-creative'],
          handoffId: 'ho-registration-count',
          department: DepartmentType.creative,
          read: true,
        ),
        ActivityEvent(
          id: 'act-4',
          kind: ActivityKind.taskVerified,
          title: 'Outcome verified',
          body:
              '"Close title sponsor and two associate partners" signed off · +13 XP to Tuba Azeem.',
          timestamp: now.subtract(const Duration(days: 2)),
          actorId: 'mem-president',
          actorName: 'Aldrin Paul',
          targetMemberIds: ['mem-pr'],
          taskId: 'task-sponsors',
          department: DepartmentType.publicRelations,
          read: true,
        ),
      ];
}

class WorkspaceSnapshot {
  const WorkspaceSnapshot({
    required this.events,
    required this.tasks,
    required this.members,
    required this.handoffs,
    required this.messages,
    required this.activity,
  });

  final List<ClubEvent> events;
  final List<ClubTask> tasks;
  final List<MemberProfile> members;
  final List<Handoff> handoffs;
  final List<CollabMessage> messages;
  final List<ActivityEvent> activity;
}
