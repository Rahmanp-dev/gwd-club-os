import 'dart:math';
import '../models/club_event.dart';
import '../models/club_role.dart';
import '../models/club_task.dart';
import '../models/department.dart';

class AiEventBlueprint {
  const AiEventBlueprint({
    required this.event,
    required this.tasks,
    required this.executiveSummary,
  });

  final ClubEvent event;
  final List<ClubTask> tasks;
  final String executiveSummary;
}

class AiEventArchitectService {
  static final Random _rand = Random();

  /// Generates a complete synchronized event with department tasks, pre-fed values, and timelines.
  static AiEventBlueprint generateBlueprint({
    required String title,
    required String themeTagline,
    required EventCategory category,
    required DateTime targetDate,
    required String venue,
    int expectedFootfall = 250,
    String budgetLabel = '₹45,000 / \$600',
    String? customInstructions,
  }) {
    final eventId = 'ev-${DateTime.now().millisecondsSinceEpoch}-${_rand.nextInt(999)}';

    final event = ClubEvent(
      id: eventId,
      title: title,
      themeTagline: themeTagline,
      category: category,
      targetDate: targetDate,
      venue: venue,
      expectedFootfall: expectedFootfall,
      status: EventStatus.planning,
      budgetLabel: budgetLabel,
      isFlagship: category == EventCategory.flagship,
      runOfShow: [
        const EventRunOfShowItem(
          time: '09:00 AM',
          title: 'Doors Open, Registration Desk & Welcome Kits',
          department: 'Event Logistics & Ops',
          ownerName: 'Pooja Nair (Event Lead)',
          notes: 'QR check-in scanners live, badge allocation',
        ),
        const EventRunOfShowItem(
          time: '10:00 AM',
          title: 'Inauguration & GWD Global Corporate Keynote',
          department: 'Executive Board',
          ownerName: 'Aarav Sharma (President)',
          notes: 'Welcome address, introducing campus-to-corporate mission',
        ),
        const EventRunOfShowItem(
          time: '11:15 AM',
          title: 'Industry Speaker Panel & Interactive Q&A',
          department: 'PR & Corporate Relations',
          ownerName: 'Kabir Mehta (PR Lead)',
          notes: 'Corporate partners and industry guest panelists on stage',
        ),
        const EventRunOfShowItem(
          time: '01:30 PM',
          title: 'Breakout Sessions / Hands-on Track Run',
          department: 'Production & AV Tech',
          ownerName: 'Dev Patel (Production Lead)',
          notes: 'Tech workstations, dual projector feeds, AV audio sync',
        ),
        const EventRunOfShowItem(
          time: '04:00 PM',
          title: 'Awards, Closing Remarks & Aftermovie Teaser',
          department: 'Cinematography & Media',
          ownerName: 'Aditya Rao (Cinema Lead)',
          notes: 'Same-day edit reel played on main LED screen',
        ),
      ],
    );

    final List<ClubTask> tasks = [
      // --- EXECUTIVE BOARD ---
      ClubTask(
        id: 'task-$eventId-exec-1',
        eventId: eventId,
        title: 'Secure Dean & College Administration official permission and venue booking sanction',
        department: DepartmentType.executive,
        assigneeRole: ClubRole.generalSecretary,
        assigneeName: 'Sravya',
        creatorRole: ClubRole.president,
        points: 8,
        dueLabel: 'T-18 Days',
        dueDate: targetDate.subtract(const Duration(days: 18)),
        definitionOfDone: 'Signed permission letter from College Principal & Registrar uploaded to workspace drive.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Corporate Governance & Institutional Clearance',
      ),
      ClubTask(
        id: 'task-$eventId-exec-2',
        eventId: eventId,
        title: 'Executive alignment with GWD Global supervision council and budget allocation',
        department: DepartmentType.executive,
        assigneeRole: ClubRole.president,
        assigneeName: 'Aldrin Paul',
        creatorRole: ClubRole.president,
        points: 13,
        dueLabel: 'T-15 Days',
        dueDate: targetDate.subtract(const Duration(days: 15)),
        definitionOfDone: 'Budget spreadsheet approved and signed by GWD Global program director.',
        status: TaskStatus.inProgress,
        corporateValueSkill: 'Strategic Finance & Stakeholder Alignment',
      ),

      // --- PR & CORPORATE RELATIONS ---
      ClubTask(
        id: 'task-$eventId-pr-1',
        eventId: eventId,
        title: 'Finalize and confirm 2 Industry CXO/VP speakers and corporate panel topic',
        department: DepartmentType.publicRelations,
        assigneeRole: ClubRole.prLead,
        assigneeName: 'Tuba Azeem',
        creatorRole: ClubRole.vicePresident,
        points: 13,
        dueLabel: 'T-14 Days',
        dueDate: targetDate.subtract(const Duration(days: 14)),
        definitionOfDone: 'Speaker confirmation emails, headshots, and talk abstracts filed in the PR portal.',
        status: TaskStatus.inProgress,
        corporateValueSkill: 'Corporate Outreach & Keynote Negotiation',
      ),
      ClubTask(
        id: 'task-$eventId-pr-2',
        eventId: eventId,
        title: 'Coordinate VIP speaker itinerary, hospitality gifts, and corporate liaison member briefing',
        department: DepartmentType.publicRelations,
        assigneeRole: ClubRole.clubMember,
        assigneeName: 'Rhea Sen',
        creatorRole: ClubRole.prLead,
        points: 5,
        dueLabel: 'T-5 Days',
        dueDate: targetDate.subtract(const Duration(days: 5)),
        definitionOfDone: 'Vehicle pickup schedule, GWD memento gifts, and lounge access pass verified.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Executive Protocol & VIP Hospitality',
      ),

      // --- MARKETING & GROWTH ---
      ClubTask(
        id: 'task-$eventId-mkt-1',
        eventId: eventId,
        title: 'Launch viral multi-phase campus teaser campaign and registration funnel',
        department: DepartmentType.marketing,
        assigneeRole: ClubRole.marketingLead,
        assigneeName: 'Anvitha',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'T-12 Days',
        dueDate: targetDate.subtract(const Duration(days: 12)),
        definitionOfDone: 'Poster carousel published, registration portal live with tracking pixel, 100 early registrations booked.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Growth Hacking & Campaign Conversion',
      ),
      ClubTask(
        id: 'task-$eventId-mkt-2',
        eventId: eventId,
        title: 'Conduct classroom-to-classroom campaign blitz and college WhatsApp community engagement',
        department: DepartmentType.marketing,
        assigneeRole: ClubRole.clubMember,
        assigneeName: 'Rhea Sen',
        creatorRole: ClubRole.marketingLead,
        points: 5,
        dueLabel: 'T-6 Days',
        dueDate: targetDate.subtract(const Duration(days: 6)),
        definitionOfDone: 'Visited 12 engineering & business classrooms, flyer handed over, 150+ registrations confirmed.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Field Marketing & Audience Acquisition',
      ),

      // --- CREATIVE & BRAND DESIGN ---
      ClubTask(
        id: 'task-$eventId-cre-1',
        eventId: eventId,
        title: 'Design 4K keynote slide templates, stage motion loop, and VIP badge graphics',
        department: DepartmentType.creative,
        assigneeRole: ClubRole.creativeLead,
        assigneeName: 'Nishta',
        creatorRole: ClubRole.gwdCmo,
        points: 12,
        dueLabel: 'T-8 Days',
        dueDate: targetDate.subtract(const Duration(days: 8)),
        definitionOfDone: 'Figma package delivered with high-res export assets aligned with GWD Global branding.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Brand Design Systems & Stage Visuals',
      ),

      // --- PRODUCTION & TECH ---
      ClubTask(
        id: 'task-$eventId-prod-1',
        eventId: eventId,
        title: 'AV dry-run, wireless mic frequency sweep, and multi-display switcher setup in auditorium',
        department: DepartmentType.production,
        assigneeRole: ClubRole.productionLead,
        assigneeName: 'Mohd Abdul Rahman Pasha (CEO - Temp)',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'T-2 Days',
        dueDate: targetDate.subtract(const Duration(days: 2)),
        definitionOfDone: 'All 4 handheld mics tested for feedback, HDMI switchers verified, backup audio cables placed.',
        status: TaskStatus.requested,
        corporateValueSkill: 'Live Event Technical Engineering',
      ),

      // --- EVENT MANAGEMENT & LOGISTICS ---
      ClubTask(
        id: 'task-$eventId-ev-1',
        eventId: eventId,
        title: 'Draft master minute-by-minute Run of Show and stage transition cue sheet',
        department: DepartmentType.eventManagement,
        assigneeRole: ClubRole.eventManagementLead,
        assigneeName: 'Bhavya',
        creatorRole: ClubRole.vicePresident,
        points: 8,
        dueLabel: 'T-4 Days',
        dueDate: targetDate.subtract(const Duration(days: 4)),
        definitionOfDone: 'Run of Show document shared and signed off by President, VP, and all Department Leads.',
        status: TaskStatus.committed,
        corporateValueSkill: 'Operations Run-of-Show & Flow Architecture',
      ),
      ClubTask(
        id: 'task-$eventId-ev-2',
        eventId: eventId,
        title: 'Set up registration counters, badge printers, and volunteer crowd flow barriers',
        department: DepartmentType.eventManagement,
        assigneeRole: ClubRole.clubMember,
        assigneeName: 'Rhea Sen',
        creatorRole: ClubRole.eventManagementLead,
        points: 5,
        dueLabel: 'Day of Event (07:30 AM)',
        dueDate: targetDate,
        definitionOfDone: 'Counters manned with QR scanner tablets, delegate passes arranged alphabetically.',
        status: TaskStatus.requested,
        corporateValueSkill: 'Crowd Dynamics & Ground Logistics',
      ),

      // --- CINEMATOGRAPHY & MEDIA ---
      ClubTask(
        id: 'task-$eventId-cine-1',
        eventId: eventId,
        title: 'Produce high-energy cinematic promo video teaser featuring speakers and past highlights',
        department: DepartmentType.cinematography,
        assigneeRole: ClubRole.cinematographerLead,
        assigneeName: 'Burhan',
        creatorRole: ClubRole.vicePresident,
        points: 13,
        dueLabel: 'T-9 Days',
        dueDate: targetDate.subtract(const Duration(days: 9)),
        definitionOfDone: '60-second 4K reel edited with sound design, color graded, and approved for Instagram/LinkedIn.',
        status: TaskStatus.inProgress,
        corporateValueSkill: 'Commercial Video Production & Storyboarding',
      ),
      ClubTask(
        id: 'task-$eventId-cine-2',
        eventId: eventId,
        title: 'Deliver 90-second same-day recap aftermovie and raw photo gallery drive link',
        department: DepartmentType.cinematography,
        assigneeRole: ClubRole.cinematographerLead,
        assigneeName: 'Burhan',
        creatorRole: ClubRole.president,
        points: 13,
        dueLabel: 'T+1 Day (Within 24 Hours)',
        dueDate: targetDate.add(const Duration(days: 1)),
        definitionOfDone: 'Edited aftermovie exported in 16:9 & 9:16 + Google Drive album with 150 edited high-res photos.',
        status: TaskStatus.requested,
        corporateValueSkill: 'Rapid Turnaround Media Delivery',
      ),
    ];

    final summary =
        'AI Architect successfully generated "${event.title}" with 12 interconnected tasks across 5 departments. All milestones are calibrated backwards from ${event.formattedDate} with pre-fed Corporate Skill XP values.';

    return AiEventBlueprint(
      event: event,
      tasks: tasks,
      executiveSummary: summary,
    );
  }

  /// Preset Flagship Concepts ready to generate with 1 tap!
  static List<Map<String, dynamic>> get flagshipPresets => [
        {
          'title': 'GWD TechConnect 2026: Campus to Corporate Summit',
          'themeTagline': 'Bridging the Gap Between Academic Theory and Tier-1 Tech Industry Standards',
          'category': EventCategory.flagship,
          'venue': 'Main University Auditorium & Innovation Hub',
          'expectedFootfall': 600,
          'budgetLabel': '₹75,000 / \$900',
          'daysOffset': 21,
        },
        {
          'title': 'Corporate Cloud & GenAI Engineering Bootcamp',
          'themeTagline': 'Production LLMs, Microservices & Docker in High-Scale Architectures',
          'category': EventCategory.workshop,
          'venue': 'Advanced Computing Lab 3',
          'expectedFootfall': 180,
          'budgetLabel': '₹25,000 / \$300',
          'daysOffset': 14,
        },
        {
          'title': 'GWD 24-Hour National Hackathon: Code Sprint',
          'themeTagline': 'Sprint from Concept to Working MVP with Real Venture Capital Mentors',
          'category': EventCategory.hackathon,
          'venue': 'Student Center Arena & Virtual Stream',
          'expectedFootfall': 350,
          'budgetLabel': '₹1,20,000 / \$1,450',
          'daysOffset': 28,
        },
        {
          'title': 'Corporate Leadership & CXO Fireside Series',
          'themeTagline': 'What Silicon Valley & Top Corporate Hubs Look For in Campus Hires',
          'category': EventCategory.industryTalk,
          'venue': 'Executive Seminar Hall A',
          'expectedFootfall': 220,
          'budgetLabel': '₹20,000 / \$250',
          'daysOffset': 10,
        },
      ];
}
