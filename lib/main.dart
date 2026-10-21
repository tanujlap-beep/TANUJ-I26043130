import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'student_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.instance.init();
  } catch (_) {}
  runApp(const HubApp());
}

// -----------------------------------------------------------------------------
// DESIGN SYSTEM & COLOR PALETTE
// Harmonious Modern Palette: Deep Slate + Emerald Teal + Indigo + Gold + Rose
// -----------------------------------------------------------------------------
class C {
  static const primary = Color(0xFF0D9488); // Vibrant Teal / Emerald
  static const primaryDark = Color(0xFF0F172A); // Midnight Slate
  static const primaryLight = Color(0xFF14B8A6);
  static const indigo = Color(0xFF6366F1); // Royal Indigo Accent
  static const indigoDark = Color(0xFF4338CA);
  static const amber = Color(0xFFF59E0B); // Warm Gold / Amber Accent
  static const rose = Color(0xFFF43F5E); // Coral Rose Accent
  static const violet = Color(0xFF8B5CF6); // Soft Violet Accent
  static const emerald = Color(0xFF10B981); // Mint Emerald
  static const cyan = Color(0xFF06B6D4); // Deep Cyan

  static const bg = Color(0xFFF8FAFC); // Cool Slate Background
  static const cardBg = Colors.white; // Card Surface
  static const text = Color(0xFF0F172A); // Main Text
  static const muted = Color(0xFF64748B); // Muted Text
  static const line = Color(0xFFE2E8F0); // Subtle Borders

  static const tealTint = Color(0xFFF0FDFA);
  static const indigoTint = Color(0xFFEEF2FF);
  static const amberTint = Color(0xFFFFFBEB);
  static const roseTint = Color(0xFFFFF1F2);
  static const slateTint = Color(0xFFF1F5F9);
}

// -----------------------------------------------------------------------------
// REUSABLE HOVER ELEVATION CARD
// -----------------------------------------------------------------------------
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color border;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
    this.border = C.line,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _hovering ? -4.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? C.primary : widget.border,
            width: _hovering ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? C.primary.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _hovering ? 16 : 8,
              offset: Offset(0, _hovering ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Typography & UI Snippets
Text t(
  String s, {
  double size = 14,
  FontWeight w = FontWeight.w400,
  Color color = C.text,
  TextOverflow? overflow,
  int? maxLines,
}) => Text(
  s,
  overflow: overflow,
  maxLines: maxLines,
  style: TextStyle(fontSize: size, fontWeight: w, color: color),
);

Widget iconBox(IconData i, Color c) => Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: c,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: c.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Icon(i, color: Colors.white, size: 20),
);

Widget pill(String s, Color c) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
  child: t(s, size: 11, w: FontWeight.w700, color: Colors.white),
);

// -----------------------------------------------------------------------------
// DATA MODELS FOR CAMPUS MAP & BUS ROUTES
// -----------------------------------------------------------------------------

class CampusBuilding {
  final String id;
  final String name;
  final String code;
  final Offset position; // Position on map (550 x 360 virtual viewport)
  final Color color;
  final IconData icon;
  final String description;
  final List<String> classes;
  final List<String> floors;
  final String walkingTime;

  const CampusBuilding({
    required this.id,
    required this.name,
    required this.code,
    required this.position,
    required this.color,
    required this.icon,
    required this.description,
    required this.classes,
    required this.floors,
    required this.walkingTime,
  });
}

class BusRouteInfo {
  final String id;
  final String name;
  final String code;
  final Color color;
  final String frequency;
  final String currentBusLocation;
  final String nextArrival;
  final String occupancy;
  final List<String> stops;
  final List<Offset> routePath;

  const BusRouteInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.frequency,
    required this.currentBusLocation,
    required this.nextArrival,
    required this.occupancy,
    required this.stops,
    required this.routePath,
  });
}

// -----------------------------------------------------------------------------
// MAIN APPLICATION ENTRY POINT
// -----------------------------------------------------------------------------

class HubApp extends StatelessWidget {
  const HubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIST University Student Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: C.primary,
          primary: C.primary,
          secondary: C.indigo,
          surface: C.cardBg,
        ),
        scaffoldBackgroundColor: C.bg,
        fontFamily: 'Roboto',
      ),
      home: const Shell(),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN SHELL SCREEN & NAVIGATION CONTROLLER
// -----------------------------------------------------------------------------

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _page = 0;
  int _sem = 4;
  String _day = 'Mon';
  String _tag = 'All';
  String _galleryFilter = 'All'; // 'All', 'Real Campus', 'AI Vision'
  String _q = '';
  String _cat = 'Academic';

  // Map state
  int _mapMode = 0; // 0 = Class Locator, 1 = Bus Tracker
  String _selectedBuildingId = 'tech_c';
  String _selectedRouteId = 'route_a';
  int _selectedFloorIndex = 2; // Floor 2 by default for Tech Block C

  final _ctrl = TextEditingController();
  final _taskInputCtrl = TextEditingController();
  final _mapSearchCtrl = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _reg = <String>{'AI Hack Night'};
  final _tasks = <String>[
    'Submit ML lab record',
    'Read Deep Learning Ch. 5',
    'Register for AI Hack Night',
    'Renew library books',
  ];
  late List<bool> _done;

  final _alerts = <(String, String)>[
    (
      'Lab record submission — due Thu, 4 PM',
      'Submit your ML Lab records to the department office. Bring the signed cover sheet; late work loses 10% internal marks.',
    ),
    (
      'Scholarship briefing — Fri, 11 AM',
      'Merit scholarship briefing in Auditorium 2. Bring your ID card and last semester marksheet.',
    ),
    (
      'Wi-Fi maintenance — Sat, 2–4 AM',
      'Campus Wi-Fi will be offline for upgrades. Download study material beforehand.',
    ),
  ];

  final _tickets = <(String, String, bool)>[
    ('Hostel Wi-Fi not connecting', 'Facilities', false),
    ('Grade discrepancy in Data Mining', 'Academic', true),
  ];

  final Map<String, double> _simulatedMarks = {
    'Deep Learning': 94.0,
    'Data Structures': 89.0,
    'Computer Networks': 82.0,
    'AI Ethics': 95.0,
  };

  // Form state
  String? _formInitialService;
  String? _formInitialEvent;

  static const _nav = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.calendar_month_outlined, 'Timetable'),
    (Icons.school_outlined, 'Results'),
    (Icons.event_outlined, 'Events'),
    (Icons.map_outlined, 'Campus & Bus Map'),
    (Icons.photo_library_outlined, 'Campus Gallery'),
    (Icons.assignment_outlined, 'Student Forms'),
    (Icons.support_agent, 'Helpdesk'),
  ];

  static const _svc = [
    (
      Icons.calendar_month,
      'Timetable',
      'Next: DL Lab, 10 AM',
      'assets/images/ai_cyber_lab.jpg',
    ),
    (
      Icons.map,
      'Campus Map',
      'Locate Class & Bus',
      'assets/images/real_campus_dome.jpg',
    ),
    (
      Icons.school,
      'Results & Placements',
      '2000+ Offers, 53 LPA',
      'assets/images/real_campus_recruitment.jpg',
    ),
    (
      Icons.local_library,
      'Library',
      '2 books issued',
      'assets/images/real_campus_library.jpg',
    ),
    (
      Icons.directions_bus,
      'Bus Routes',
      '4 Active Lines',
      'assets/images/ai_smart_campus.jpg',
    ),
    (
      Icons.event,
      'Events',
      '5 upcoming',
      'assets/images/ai_hackathon_stage.jpg',
    ),
    (
      Icons.assignment,
      'Student Forms',
      'Library, Events & Pass',
      'assets/images/service_lab.jpg',
    ),
    (
      Icons.science,
      'Research & Help',
      'Raise a ticket',
      'assets/images/real_campus_research_centre.jpg',
    ),
  ];

  static const _tt = {
    'Mon': [
      ('9:00 AM', 'Deep Learning', 'Lab 3', 'Dr. Rao', 'tech_c'),
      ('11:00 AM', 'Data Structures', 'Room 204', 'Prof. Smith', 'science_a'),
      ('2:00 PM', 'Ethics in AI', 'Hall B', 'Dr. Mehta', 'hall_d'),
    ],
    'Tue': [
      ('10:00 AM', 'Computer Networks', 'Room 110', 'Prof. Jones', 'science_a'),
      ('1:00 PM', 'Statistics', 'Room 305', 'Dr. Ali', 'science_a'),
    ],
    'Wed': [
      ('9:00 AM', 'Data Structures Lab', 'Lab 1', 'Prof. Smith', 'science_a'),
      ('12:00 PM', 'Deep Learning', 'Room 204', 'Dr. Rao', 'tech_c'),
      ('3:00 PM', 'Seminar', 'Auditorium 2', 'Guest Speaker', 'hall_d'),
    ],
    'Thu': [
      ('11:00 AM', 'Computer Networks', 'Room 110', 'Prof. Jones', 'science_a'),
      ('2:00 PM', 'ML Lab', 'Lab 3', 'Dr. Rao', 'tech_c'),
    ],
    'Fri': [
      ('9:00 AM', 'Ethics in AI', 'Hall B', 'Dr. Mehta', 'hall_d'),
      ('11:00 AM', 'Statistics', 'Room 305', 'Dr. Ali', 'science_a'),
    ],
  };

  static const List<CampusBuilding> _buildings = [
    CampusBuilding(
      id: 'tech_c',
      name: 'Tech Block C (AI & Computing)',
      code: 'BLD-C',
      position: Offset(130, 110),
      color: C.primary,
      icon: Icons.computer,
      description:
          'Houses ML Lab 3, Deep Learning Wing, AI Research Hub, and High-Performance Compute Cluster.',
      classes: [
        'Deep Learning (Lab 3)',
        'ML Lab (Lab 3)',
        'AI Hack Night (Lab 3)',
      ],
      floors: [
        'Ground Floor: Robotics Lab & Server Cluster',
        'Floor 1: Software Engineering Labs 1 & 2',
        'Floor 2: AI & ML Lab 3 (Classroom 202)',
        'Floor 3: Postgraduate Research Hub',
      ],
      walkingTime: '3 min walk from Main Gate (180m)',
    ),
    CampusBuilding(
      id: 'science_a',
      name: 'Science Block A (CS & Math)',
      code: 'BLD-A',
      position: Offset(380, 95),
      color: C.indigo,
      icon: Icons.science,
      description:
          'Data Structures Lab, Computer Networks Lab, and Applied Mathematics lecture rooms.',
      classes: [
        'Data Structures (Room 204)',
        'Computer Networks (Room 110)',
        'Statistics (Room 305)',
      ],
      floors: [
        'Ground Floor: Physics & Electronics Lab',
        'Floor 1: Room 110 (Computer Networks)',
        'Floor 2: Room 204 (Data Structures)',
        'Floor 3: Room 305 (Statistics & Math)',
      ],
      walkingTime: '4 min walk from Main Gate (240m)',
    ),
    CampusBuilding(
      id: 'hall_d',
      name: 'Lecture Complex Hall D',
      code: 'HALL-D',
      position: Offset(120, 270),
      color: C.amber,
      icon: Icons.meeting_room,
      description:
          'Large tier auditoriums for general lectures, ethics seminars, and university keynotes.',
      classes: ['Ethics in AI (Hall B)', 'University Seminars (Auditorium 2)'],
      floors: [
        'Ground Floor: Main Auditorium 1',
        'Floor 1: Lecture Hall B (Ethics in AI)',
        'Floor 2: Conference Hall C',
      ],
      walkingTime: '2 min walk from Main Gate (120m)',
    ),
    CampusBuilding(
      id: 'library',
      name: 'Central Library & Digital Hub',
      code: 'LIB-1',
      position: Offset(260, 190),
      color: C.violet,
      icon: Icons.local_library,
      description:
          '24/7 Quiet Study Wing, Digital Journal Hub, and Book Issue Counter.',
      classes: ['Library Digital Workshop', 'Research Citation Hours'],
      floors: [
        'Ground Floor: Book Circulation & Return Desk',
        'Floor 1: Computer Vision & AI Reference Books',
        'Floor 2: Silent Study Pods & Wi-Fi Zone',
      ],
      walkingTime: '2 min walk from Main Gate (150m)',
    ),
    CampusBuilding(
      id: 'student_center',
      name: 'Student Center & Cafeteria',
      code: 'STU-HUB',
      position: Offset(410, 260),
      color: C.rose,
      icon: Icons.restaurant,
      description:
          'Student lounge, university food court, activity halls, and event stages.',
      classes: ['Robotics & AI Expo', 'Student Council Desk'],
      floors: [
        'Ground Floor: University Food Court & Cafe',
        'Floor 1: Main Event Hall & Exhibition Wing',
        'Floor 2: Student Club Offices & Gaming Lounge',
      ],
      walkingTime: '5 min walk from Main Gate (300m)',
    ),
    CampusBuilding(
      id: 'main_gate',
      name: 'Main Entrance & Transit Station',
      code: 'GATE-1',
      position: Offset(260, 350),
      color: C.primaryDark,
      icon: Icons.door_front_door,
      description:
          'Main campus entry point, shuttle bus pick-up terminal, security desk, and visitor center.',
      classes: ['Shuttle Route A, B, C Boarding Terminal'],
      floors: ['Ground Level: Bus Terminal & Security Desk'],
      walkingTime: '0 min (Starting Point)',
    ),
    CampusBuilding(
      id: 'stadium',
      name: 'University Sports Stadium',
      code: 'SPORT-1',
      position: Offset(490, 160),
      color: C.emerald,
      icon: Icons.sports_soccer,
      description:
          'Full sized football field, athletics track, and indoor fitness gymnasium.',
      classes: ['Football Trials', 'Varsity Athletics'],
      floors: ['Outdoor Main Stadium Field', 'Indoor Gymnasium & Locker Rooms'],
      walkingTime: '6 min walk from Main Gate (380m)',
    ),
  ];

  static const List<BusRouteInfo> _busRoutes = [
    BusRouteInfo(
      id: 'route_a',
      name: 'Route A · Campus Express',
      code: 'SHUTTLE A',
      color: C.primary,
      frequency: 'Every 8 mins',
      currentBusLocation: 'Approaching Tech Block C',
      nextArrival: '2 mins (Main Gate)',
      occupancy: '45% Full (18 seats available)',
      stops: [
        'Main Gate Terminal',
        'Tech Block C',
        'Central Library',
        'Science Block A',
        'North Hostels',
      ],
      routePath: [
        Offset(260, 350),
        Offset(130, 110),
        Offset(260, 190),
        Offset(380, 95),
        Offset(260, 350),
      ],
    ),
    BusRouteInfo(
      id: 'route_b',
      name: 'Route B · City & Metro Shuttle',
      code: 'SHUTTLE B',
      color: C.indigo,
      frequency: 'Every 15 mins',
      currentBusLocation: 'Near Student Center',
      nextArrival: '6 mins (Main Gate)',
      occupancy: '70% Full (9 seats available)',
      stops: [
        'Metro Station',
        'South Campus Gate',
        'Main Gate Terminal',
        'Student Center',
        'Sports Stadium',
      ],
      routePath: [
        Offset(260, 350),
        Offset(410, 260),
        Offset(490, 160),
        Offset(380, 95),
        Offset(260, 350),
      ],
    ),
    BusRouteInfo(
      id: 'route_c',
      name: 'Route C · Hostel Connector',
      code: 'SHUTTLE C',
      color: C.amber,
      frequency: 'Every 10 mins',
      currentBusLocation: 'Leaving West Hostels',
      nextArrival: '4 mins (Main Gate)',
      occupancy: '30% Full (24 seats available)',
      stops: [
        'West Hostels',
        'Lecture Complex D',
        'Central Library',
        'Student Center Cafeteria',
      ],
      routePath: [
        Offset(120, 270),
        Offset(260, 190),
        Offset(410, 260),
        Offset(260, 350),
      ],
    ),
    BusRouteInfo(
      id: 'route_d',
      name: 'Route D · 24/7 Night Crawler',
      code: 'SHUTTLE D',
      color: C.violet,
      frequency: 'Every 20 mins',
      currentBusLocation: 'Library Night Desk',
      nextArrival: '12 mins',
      occupancy: '20% Full (28 seats available)',
      stops: [
        'Central Library Hub',
        '24h Innovation Lab',
        'All Student Hostels',
        'Main Gate Security',
      ],
      routePath: [
        Offset(260, 190),
        Offset(130, 110),
        Offset(410, 260),
        Offset(260, 350),
      ],
    ),
  ];

  static const _res = {
    3: [
      ('Machine Learning', 'A', 92.0),
      ('Algorithms', 'A-', 88.0),
      ('Databases', 'B+', 81.0),
      ('Statistics', 'A', 90.0),
    ],
    4: [
      ('Deep Learning', 'A', 94.0),
      ('Data Structures', 'A-', 89.0),
      ('Computer Networks', 'B+', 82.0),
      ('AI Ethics', 'A', 95.0),
    ],
  };

  static const _ev = [
    (
      'Mega Placement Drive 2024',
      '15',
      'OCT',
      'Central Courtyard Quad',
      'Placements',
      'assets/images/real_campus_recruitment.jpg',
      'Annual university campus recruitment celebration: 2000+ offers from 200+ premier MNCs with 53 LPA highest package.',
      'hall_d',
    ),
    (
      'AI Hack Night 2024',
      '18',
      'OCT',
      'Tech Block C (Lab 3)',
      'Tech',
      'assets/images/ai_hackathon_stage.jpg',
      'Build cutting edge LLM agents and vision models in 24 hours. \$5,000+ prizes and mentor feedback!',
      'tech_c',
    ),
    (
      'University Football Trials',
      '21',
      'OCT',
      'University Sports Stadium',
      'Sports',
      'assets/images/event_sports.jpg',
      'Annual university varsity football selection trials for undergrads under stadium floodlights.',
      'stadium',
    ),
    (
      'Central Library Research Workshop',
      '24',
      'OCT',
      'Central Library Grand Wing',
      'Academic',
      'assets/images/real_campus_library.jpg',
      'Master IEEE & ACM research database search & citation indexing in the grand marble atrium.',
      'library',
    ),
    (
      'Autonomous Rover & Robotics Expo',
      '28',
      'OCT',
      'International Research Centre',
      'Tech',
      'assets/images/ai_smart_campus.jpg',
      'Live demonstration of autonomous campus shuttles, rover navigation, and IoT drone swarms.',
      'student_center',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _done = List<bool>.filled(_tasks.length, false);
    _done[2] = true;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _taskInputCtrl.dispose();
    _mapSearchCtrl.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _page = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _openMapForClass(String buildingId, {String? targetText}) {
    setState(() {
      _page = 4; // Map page index
      _selectedBuildingId = buildingId;
      _mapMode = 0; // Class locator mode
      if (targetText != null) {
        _mapSearchCtrl.text = targetText;
      }
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _openStudentForm({String? service, String? eventTitle}) {
    setState(() {
      _formInitialService = service;
      _formInitialEvent = eventTitle;
      _page = 6; // Student Forms page index
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _snack(String m, {SnackBarAction? action}) {
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(
      SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  void _dialog(
    String title,
    String body,
    String action, {
    VoidCallback? run,
  }) => showDialog(
    context: context,
    builder: (d) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Close'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: C.primary),
          onPressed: () {
            Navigator.pop(d);
            run?.call();
            _snack('$action ✓');
          },
          child: Text(action),
        ),
      ],
    ),
  );

  void _showImageLightbox(
    String imagePath,
    String title,
    String subtitle, {
    String? badgeText,
    bool? isReal,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final bool realPhoto =
        isReal ??
        (imagePath.contains('real_') || imagePath.contains('campus_hero'));
    final String badge =
        badgeText ??
        (realPhoto ? '🏛️ Real Campus Photo' : '✨ AI Concept Vision');

    showDialog(
      context: context,
      builder: (ctx) {
        final screenH = MediaQuery.sizeOf(ctx).height;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 820,
              maxHeight: screenH * 0.90,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: realPhoto ? const Color(0xFF10B981) : C.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (realPhoto ? const Color(0xFF10B981) : C.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
                const BoxShadow(color: Colors.black87, blurRadius: 40),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          maxScale: 3.5,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            height: screenH < 650 ? 240 : 380,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              height: 240,
                              color: C.primaryDark,
                              child: const Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: realPhoto
                                  ? const Color(0xE6065F46)
                                  : const Color(0xE61E1B4B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: realPhoto
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF818CF8),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black45, blurRadius: 6),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  realPhoto
                                      ? Icons.camera_alt
                                      : Icons.auto_awesome,
                                  size: 14,
                                  color: realPhoto
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFA5B4FC),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  badge,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: realPhoto
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFE0E7FF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.6,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          realPhoto
                              ? 'Authentic Campus Photo · Sathyabama Institute of Science and Technology'
                              : 'Futuristic AI Generation · SIST Innovation & Research Concept',
                          style: TextStyle(
                            fontSize: 12,
                            color: realPhoto
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFF93C5FD),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE2E8F0),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.pinch,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Pinch or drag image to zoom in HD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (actionLabel != null) ...[
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: C.amber,
                                      foregroundColor: C.primaryDark,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onAction?.call();
                                    },
                                    icon: const Icon(
                                      Icons.assignment,
                                      size: 15,
                                    ),
                                    label: Text(
                                      actionLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                TextButton.icon(
                                  onPressed: () => Navigator.pop(ctx),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Close'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: realPhoto
                                        ? const Color(0xFF059669)
                                        : C.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  void _open(String n) {
    switch (n) {
      case 'Timetable':
        _go(1);
      case 'Campus Map':
      case 'Bus Routes':
        _go(4);
      case 'Results':
      case 'Results & Placements':
        _go(2);
      case 'Events':
        _go(3);
      case 'Campus Gallery':
        _go(5);
      case 'Student Forms':
      case 'Forms':
      case 'Form Submission':
      case 'Registration':
        _openStudentForm();
      case 'Helpdesk':
      case 'Research & Help':
        _go(7);
      case 'Library':
        _showImageLightbox(
          'assets/images/real_campus_library.jpg',
          'SIST Central University Library & Grand Atrium',
          '2 Books Currently Issued:\n• Data Mining & Analytics (Due: Oct 12)\n• Computer Vision Principles (Due: Oct 15)\n\nLocation: Central Library Wing, Ground & First Floor.\nFeatures Italian checkerboard marble flooring, reading carrels, and digital database terminals.',
          badgeText: '🏛️ Real Campus Photo',
          isReal: true,
          actionLabel: 'Apply for Library Pass / Membership',
          onAction: () => _openStudentForm(service: 'Library Membership'),
        );
      default:
        _dialog(
          'Fees & Dues',
          'Semester 5 Tuition Fee: Paid ✓\nLibrary Dues: \$0.00\nNo outstanding balances found.',
          'Download Official Receipt',
        );
    }
  }

  void _submitTicket() {
    final s = _ctrl.text.trim();
    if (s.isEmpty) {
      _snack('Please describe your issue first');
      return;
    }
    setState(() => _tickets.insert(0, (s, _cat, false)));
    _ctrl.clear();
    _snack('Support ticket submitted successfully!');
  }

  void _addNewTask() {
    final txt = _taskInputCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _tasks.add(txt);
      _done.add(false);
    });
    _taskInputCtrl.clear();
    Navigator.pop(context);
    _snack('New task added!');
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: _taskInputCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Prepare for AI Midterm',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.primary),
            onPressed: _addNewTask,
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    final body = SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : (isMobile ? 12 : 20)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(_page),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _top(isDesktop),
                switch (_page) {
                  0 => _dash(isDesktop, isMobile),
                  1 => _timetable(),
                  2 => _results(isMobile),
                  3 => _events(isMobile),
                  4 => _mapPage(isDesktop, isMobile),
                  5 => _gallery(isMobile),
                  6 => StudentFormPortal(
                    initialService: _formInitialService,
                    initialEventTitle: _formInitialEvent,
                    isDesktop: isDesktop,
                    isMobile: isMobile,
                    onBackToDashboard: () => _go(0),
                    onNotify: (m) => _snack(m),
                  ),
                  _ => _help(),
                },
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : Drawer(child: _sidebarContent()),
      body: SafeArea(
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sidebarContent(),
                  Expanded(child: body),
                ],
              )
            : body,
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _page,
              onDestinationSelected: _go,
              labelBehavior: isMobile
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final n in _nav)
                  NavigationDestination(icon: Icon(n.$1), label: n.$2),
              ],
            ),
    );
  }

  // ---------- RESPONSIVE SIDEBAR CONTENT ----------
  Widget _sidebarContent() => Container(
    width: 260,
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [C.primaryDark, Color(0xFF1E293B), Color(0xFF0F766E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  t(
                    'SIST Hub',
                    size: 20,
                    w: FontWeight.w800,
                    color: Colors.white,
                  ),
                  t('Student Portal', size: 11, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Map Navigation Banner in Sidebar
        GestureDetector(
          onTap: () => _go(4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [C.primary, C.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      t(
                        'Campus Map',
                        size: 13,
                        w: FontWeight.w700,
                        color: Colors.white,
                      ),
                      t('Locate Class & Bus', size: 10, color: Colors.white70),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < _nav.length; i++)
                _NavTile(
                  icon: _nav[i].$1,
                  label: _nav[i].$2,
                  selected: _page == i,
                  onTap: () => _go(i),
                ),
            ],
          ),
        ),

        // Profile Card
        GestureDetector(
          onTap: () => _showImageLightbox(
            'assets/images/student_avatar.jpg',
            'Tanuj · SIST Student',
            'ID: SIST-24-0417\nB.Tech CSE (Artificial Intelligence)\nSemester 5',
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/student_avatar.jpg',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: C.primaryLight,
                      child: t('T', w: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      t('Tanuj', w: FontWeight.w700, color: Colors.white),
                      t('SIST-24-0417', size: 11, color: Colors.white70),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _top(bool isDesktop) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        if (!isDesktop) ...[
          IconButton.filledTonal(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Open Menu',
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            _nav[_page].$2,
            style: TextStyle(
              fontSize: isDesktop ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: C.text,
            ),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: C.primary,
            side: const BorderSide(color: C.primary, width: 1.4),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 14 : 10,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _openStudentForm(),
          icon: const Icon(Icons.edit_document, size: 16),
          label: Text(
            isDesktop ? 'Submit Student Form' : 'Forms',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: _alerts.isNotEmpty,
          label: Text('${_alerts.length}'),
          child: IconButton.filledTonal(
            iconSize: 22,
            tooltip: 'Notifications',
            onPressed: () => _dialog(
              'Notifications Center',
              _alerts.isEmpty
                  ? "You're all caught up!"
                  : _alerts.map((a) => '• ${a.$1}').join('\n\n'),
              'Mark all read',
              run: () => setState(_alerts.clear),
            ),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    ),
  );

  // ---------- DASHBOARD ----------
  Widget _dash(bool isDesktop, bool isMobile) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heroBanner(isMobile),
        const SizedBox(height: 20),
        _campusMapQuickCard(isMobile),
        const SizedBox(height: 20),
        _quick(isMobile),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _announce(),
        const SizedBox(height: 20),
        _tasksCard(),
        const SizedBox(height: 20),
        _shuttle(),
      ],
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: right),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 20), right],
          );
  }

  Widget _heroBanner(bool isMobile) {
    final h = DateTime.now().hour;
    final g = h < 12
        ? 'Good morning'
        : (h < 17 ? 'Good afternoon' : 'Good evening');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/campus_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: C.primaryDark),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    C.primaryDark.withValues(alpha: 0.92),
                    C.primary.withValues(alpha: 0.85),
                    C.indigo.withValues(alpha: 0.50),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: () => _showImageLightbox(
                'assets/images/real_campus_sunset.jpg',
                'SIST Grand Dome - Sunset Aerial View',
                'Authentic golden-hour aerial perspective of the palatial SIST central dome and administrative campus at dusk.',
                badgeText: '🏛️ Real Campus Photo',
                isReal: true,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF34D399),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.photo_camera,
                      size: 13,
                      color: Color(0xFF34D399),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Real Campus Panorama',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD1FAE5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageLightbox(
                        'assets/images/student_avatar.jpg',
                        'Tanuj',
                        'Computer Science & Engineering (AI)',
                      ),
                      child: Container(
                        width: isMobile ? 48 : 58,
                        height: isMobile ? 48 : 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: C.amber, width: 2.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/student_avatar.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CircleAvatar(
                              backgroundColor: C.primaryLight,
                              child: t(
                                'T',
                                size: 20,
                                w: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t(
                            '$g, Tanuj',
                            size: isMobile ? 20 : 24,
                            w: FontWeight.w800,
                            color: Colors.white,
                          ),
                          t(
                            'SIST-24-0417 · B.Tech CSE (AI)',
                            size: isMobile ? 12 : 13,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final s in const [
                      ('8.9', 'CGPA'),
                      ('21', 'Credits'),
                      ('94%', 'Attendance'),
                      ('Dr. Rao', 'Advisor'),
                    ])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            t(
                              s.$1,
                              size: isMobile ? 16 : 18,
                              w: FontWeight.w800,
                              color: Colors.white,
                            ),
                            t(s.$2, size: 10, color: Colors.white70),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: C.amber,
                        foregroundColor: C.primaryDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _openStudentForm(),
                      icon: const Icon(Icons.assignment_turned_in, size: 16),
                      label: const Text(
                        'Submit Student Form (Library, Events, Pass)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          _openStudentForm(service: 'Library Membership'),
                      icon: const Icon(Icons.local_library_outlined, size: 16),
                      label: const Text(
                        'Apply Library Pass',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Campus Map Banner on Dashboard
  Widget _campusMapQuickCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [C.primaryDark, Color(0xFF1E293B), C.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.map, color: C.amber, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    t(
                      'Interactive Campus & Bus Map',
                      size: isMobile ? 16 : 18,
                      w: FontWeight.w800,
                      color: Colors.white,
                    ),
                    t(
                      'Locate your classrooms & track live campus bus shuttles',
                      size: 12,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(
                  Icons.location_on,
                  size: 16,
                  color: C.primary,
                ),
                label: const Text('Locate Classrooms'),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () => _openMapForClass('tech_c'),
              ),
              ActionChip(
                avatar: const Icon(
                  Icons.directions_bus,
                  size: 16,
                  color: C.amber,
                ),
                label: const Text('Live Bus Routes'),
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () {
                  setState(() {
                    _page = 4;
                    _mapMode = 1; // Bus tracker mode
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quick(bool isMobile) {
    final items = _svc
        .where((s) => s.$2.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (ctx, constraints) {
            if (constraints.maxWidth < 450) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  t('Quick Services', size: 18, w: FontWeight.w700),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => setState(() => _q = v),
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: C.line),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: t('Quick Services', size: 20, w: FontWeight.w700),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    onChanged: (v) => setState(() => _q = v),
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: C.line),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          t('No matching service found for "$_q"', color: C.muted)
        else
          LayoutBuilder(
            builder: (ctx, c) {
              final n = c.maxWidth > 750 ? 3 : (c.maxWidth > 420 ? 2 : 1);
              final w = (c.maxWidth - 12 * (n - 1)) / n;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final s in items)
                    SizedBox(
                      width: w,
                      child: InteractiveCard(
                        color: Colors.white,
                        onTap: () => _open(s.$2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    s.$4,
                                    height: 75,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 75,
                                      color: C.tealTint,
                                      child: Icon(
                                        s.$1,
                                        color: C.primary,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: s.$4.contains('real_')
                                          ? const Color(0xEE065F46)
                                          : const Color(0xEE1E1B4B),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: s.$4.contains('real_')
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFF818CF8),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      s.$4.contains('real_')
                                          ? '🏛️ Real'
                                          : '✨ AI',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                iconBox(s.$1, C.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      t(s.$2, size: 14, w: FontWeight.w700),
                                      t(s.$3, size: 11, color: C.muted),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _announce() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      t('Campus Updates', size: 18, w: FontWeight.w700),
      const SizedBox(height: 12),
      if (_alerts.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.tealTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: t('All caught up! 🎉', color: C.muted),
        ),
      for (var i = 0; i < _alerts.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InteractiveCard(
            color: i == 0 ? C.amberTint : C.indigoTint,
            border: i == 0 ? C.amber : C.indigo,
            onTap: () => _dialog(_alerts[i].$1, _alerts[i].$2, 'Got it'),
            child: Row(
              children: [
                iconBox(Icons.campaign, i == 0 ? C.amber : C.indigo),
                const SizedBox(width: 10),
                Expanded(child: t(_alerts[i].$1, w: FontWeight.w600, size: 13)),
                IconButton(
                  iconSize: 20,
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    final a = _alerts[i];
                    final at = i;
                    setState(() => _alerts.removeAt(i));
                    _snack(
                      'Update dismissed',
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => setState(
                          () => _alerts.insert(
                            at > _alerts.length ? _alerts.length : at,
                            a,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _tasksCard() {
    final n = _done.where((d) => d).length;
    final allDone = _done.isNotEmpty && n == _done.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.line),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              t("Today's Tasks", size: 17, w: FontWeight.w700),
              Row(
                children: [
                  pill('$n/${_done.length}', allDone ? C.emerald : C.primary),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    iconSize: 18,
                    tooltip: 'Add Task',
                    onPressed: _showAddTaskDialog,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _done.isEmpty ? 0 : n / _done.length,
              minHeight: 7,
              backgroundColor: C.slateTint,
              color: allDone ? C.emerald : C.primary,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < _tasks.length; i++)
            CheckboxListTile(
              value: _done[i],
              onChanged: (v) => setState(() => _done[i] = v!),
              activeColor: C.primary,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _tasks[i],
                style: TextStyle(
                  fontSize: 13,
                  decoration: _done[i] ? TextDecoration.lineThrough : null,
                  color: _done[i] ? C.muted : C.text,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shuttle() => InteractiveCard(
    onTap: () {
      setState(() {
        _page = 4;
        _mapMode = 1; // Open Bus Tracker
      });
    },
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: C.emerald,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              t(
                'Shuttle Route A · Live Bus Tracker',
                w: FontWeight.w600,
                size: 14,
              ),
              t(
                'Next arrival: 2 mins at Main Gate (45% Full)',
                size: 11,
                color: C.muted,
              ),
            ],
          ),
        ),
        const Icon(Icons.directions_bus, color: C.primary, size: 22),
      ],
    ),
  );

  // ---------- TIMETABLE ----------
  Widget _timetable() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final d in _tt.keys)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(d),
                  selected: _day == d,
                  selectedColor: C.primary,
                  labelStyle: TextStyle(
                    color: _day == d ? Colors.white : C.text,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _day = d),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      for (final c in _tt[_day]!)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InteractiveCard(
            onTap: () => _dialog(
              '${c.$2} Details',
              'Time: ${c.$1}\nVenue: ${c.$3}\nInstructor: ${c.$4}\nAttendance required: 85%',
              'Set Class Reminder',
            ),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.tealTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: t(
                    c.$1,
                    size: 13,
                    w: FontWeight.w800,
                    color: C.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      t(c.$2, size: 15, w: FontWeight.w700),
                      t('${c.$3} · ${c.$4}', size: 12, color: C.muted),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    side: const BorderSide(color: C.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _openMapForClass(c.$5, targetText: c.$2),
                  icon: const Icon(
                    Icons.location_on,
                    size: 14,
                    color: C.primary,
                  ),
                  label: const Text(
                    'Locate Map',
                    style: TextStyle(
                      fontSize: 11,
                      color: C.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  // ---------- RESULTS & INTERACTIVE GPA SIMULATOR ----------
  Widget _results(bool isMobile) {
    final rows = _res[_sem]!;
    double totalWeighted = 0;
    for (final r in rows) {
      final score = _simulatedMarks[r.$1] ?? r.$3;
      totalWeighted += score;
    }
    final gpa = (totalWeighted / rows.length) / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (ctx, c) {
            if (c.maxWidth < 450) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 3, label: Text('Sem 3')),
                      ButtonSegment(value: 4, label: Text('Sem 4')),
                    ],
                    selected: {_sem},
                    onSelectionChanged: (s) => setState(() => _sem = s.first),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: C.indigo),
                    onPressed: () =>
                        _snack('Official Marksheet PDF downloaded'),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF'),
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text('Semester 3')),
                    ButtonSegment(value: 4, label: Text('Semester 4')),
                  ],
                  selected: {_sem},
                  onSelectionChanged: (s) => setState(() => _sem = s.first),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: C.indigo),
                  onPressed: () => _snack('Official Marksheet PDF downloaded'),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download Transcript'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // Live Simulated GPA Header
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.primaryDark, C.primary]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: t(
                  gpa.toStringAsFixed(2),
                  size: isMobile ? 30 : 36,
                  w: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    t(
                      'Semester $_sem Simulated GPA',
                      size: isMobile ? 16 : 19,
                      w: FontWeight.w700,
                      color: Colors.white,
                    ),
                    t(
                      'Adjust sliders to project target CGPA',
                      size: 11,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        t('Interactive Grade Simulator', size: 17, w: FontWeight.w700),
        const SizedBox(height: 10),

        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InteractiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: t(r.$1, size: 15, w: FontWeight.w700)),
                      pill(
                        '${(_simulatedMarks[r.$1] ?? r.$3).toInt()}% · ${r.$2}',
                        C.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Slider(
                    value: _simulatedMarks[r.$1] ?? r.$3,
                    min: 50,
                    max: 100,
                    divisions: 50,
                    activeColor: C.primary,
                    label: '${(_simulatedMarks[r.$1] ?? r.$3).round()}%',
                    onChanged: (val) =>
                        setState(() => _simulatedMarks[r.$1] = val),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ---------- EVENTS & REGISTRATION ----------
  Widget _events(bool isMobile) {
    final list = _ev.where((e) => _tag == 'All' || e.$5 == _tag).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final g in const ['All', 'Tech', 'Sports', 'Academic'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          g,
                          style: TextStyle(
                            fontSize: 12,
                            color: _tag == g ? Colors.white : C.text,
                          ),
                        ),
                        selected: _tag == g,
                        selectedColor: C.primary,
                        onSelected: (_) => setState(() => _tag = g),
                      ),
                    ),
                ],
              ),
            ),
            pill('${_reg.length} Registered', C.indigo),
          ],
        ),
        const SizedBox(height: 16),
        for (final e in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InteractiveCard(
              onTap: () => _showImageLightbox(e.$6, e.$1, '${e.$4}\n\n${e.$7}'),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth < 450) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    e.$6,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70,
                                      height: 70,
                                      color: C.tealTint,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 3,
                                  left: 3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: e.$6.contains('real_')
                                          ? const Color(0xEE065F46)
                                          : const Color(0xEE1E1B4B),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      e.$6.contains('real_')
                                          ? '🏛️ Real'
                                          : '✨ AI',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  t(e.$1, size: 15, w: FontWeight.w700),
                                  t(e.$4, size: 12, color: C.muted),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        t(e.$7, size: 12, color: C.muted),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _openMapForClass(e.$8, targetText: e.$1),
                              icon: const Icon(Icons.map, size: 14),
                              label: const Text(
                                'Locate Map',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            _eventRegisterBtn(e.$1),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              e.$6,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: C.tealTint,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: e.$6.contains('real_')
                                    ? const Color(0xEE065F46)
                                    : const Color(0xEE1E1B4B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e.$6.contains('real_') ? '🏛️ Real' : '✨ AI',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            t(e.$1, size: 16, w: FontWeight.w700),
                            t(e.$4, size: 12, color: C.muted),
                            const SizedBox(height: 4),
                            t(e.$7, size: 12, color: C.muted),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          _eventRegisterBtn(e.$1),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () =>
                                _openMapForClass(e.$8, targetText: e.$1),
                            icon: const Icon(
                              Icons.location_on,
                              size: 14,
                              color: C.primary,
                            ),
                            label: const Text(
                              'Map',
                              style: TextStyle(fontSize: 11, color: C.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _eventRegisterBtn(String title) {
    final registered = _reg.contains(title);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(84, 36),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: registered ? C.emerald : C.primary,
          ),
          onPressed: () {
            setState(() => registered ? _reg.remove(title) : _reg.add(title));
            _snack(
              registered
                  ? 'Cancelled registration for $title'
                  : "Quick registered for $title!",
            );
          },
          child: Text(
            registered ? '✓ Joined' : 'Quick Join',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(96, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            side: const BorderSide(color: C.indigo, width: 1.2),
            foregroundColor: C.indigo,
          ),
          onPressed: () => _openStudentForm(
            service: 'Event Registration',
            eventTitle: title,
          ),
          icon: const Icon(Icons.assignment_outlined, size: 13),
          label: const Text(
            'Full Form',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE CAMPUS & BUS MAP SCREEN
  // Allows students to locate classrooms, buildings, & track live bus routes!
  // ---------------------------------------------------------------------------
  Widget _mapPage(bool isDesktop, bool isMobile) {
    final activeBuilding = _buildings.firstWhere(
      (b) => b.id == _selectedBuildingId,
      orElse: () => _buildings.first,
    );

    final activeRoute = _busRoutes.firstWhere(
      (r) => r.id == _selectedRouteId,
      orElse: () => _busRoutes.first,
    );

    final searchFilteredBuildings = _buildings.where((b) {
      final q = _mapSearchCtrl.text.toLowerCase().trim();
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.code.toLowerCase().contains(q) ||
          b.description.toLowerCase().contains(q) ||
          b.classes.any((c) => c.toLowerCase().contains(q));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selector: Class Locator vs Bus Routes
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: C.slateTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mapMode = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mapMode == 0 ? C.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 18,
                          color: _mapMode == 0 ? Colors.white : C.muted,
                        ),
                        const SizedBox(width: 8),
                        t(
                          'Class & Room Locator',
                          w: FontWeight.bold,
                          color: _mapMode == 0 ? Colors.white : C.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mapMode = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mapMode == 1 ? C.indigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 18,
                          color: _mapMode == 1 ? Colors.white : C.muted,
                        ),
                        const SizedBox(width: 8),
                        t(
                          'Bus Routes & Live Tracker',
                          w: FontWeight.bold,
                          color: _mapMode == 1 ? Colors.white : C.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search Input (Classroom / Building Finder)
        if (_mapMode == 0) ...[
          TextField(
            controller: _mapSearchCtrl,
            onChanged: (v) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Search room, building, or subject (e.g. Lab 3, Deep Learning, Room 204)...',
              prefixIcon: const Icon(Icons.search, color: C.primary),
              suffixIcon: _mapSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _mapSearchCtrl.clear()),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.line),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Main Map Canvas Container
        Container(
          height: isMobile ? 320 : 380,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _mapMode == 0 ? C.primary : C.indigo,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_mapMode == 0 ? C.primary : C.indigo).withValues(
                  alpha: 0.2,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Custom Painter Campus Map View
              Positioned.fill(
                child: InteractiveViewer(
                  maxScale: 2.5,
                  minScale: 0.8,
                  child: CustomPaint(
                    painter: CampusMapPainter(
                      buildings: _buildings,
                      selectedBuildingId: _selectedBuildingId,
                      mapMode: _mapMode,
                      routes: _busRoutes,
                      selectedRouteId: _selectedRouteId,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),

              // Interactive Building Taps overlay
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final scaleX = constraints.maxWidth / 580.0;
                    final scaleY = constraints.maxHeight / 380.0;

                    return Stack(
                      children: [
                        if (_mapMode == 0)
                          for (final b in searchFilteredBuildings)
                            Positioned(
                              left: b.position.dx * scaleX - 22,
                              top: b.position.dy * scaleY - 22,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedBuildingId = b.id);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: b.id == _selectedBuildingId
                                        ? b.color
                                        : b.color.withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: b.id == _selectedBuildingId
                                          ? Colors.white
                                          : Colors.white70,
                                      width: b.id == _selectedBuildingId
                                          ? 3.0
                                          : 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: b.color.withValues(alpha: 0.5),
                                        blurRadius: b.id == _selectedBuildingId
                                            ? 12
                                            : 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    b.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),

              // Floating Map Header Overlay
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _mapMode == 0 ? Icons.map : Icons.directions_bus,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      t(
                        _mapMode == 0
                            ? 'Campus Classroom & Building Map'
                            : 'Live Shuttle Tracker (${activeRoute.code})',
                        size: 12,
                        w: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // DETAILS PANEL: Depending on selected Mode
        if (_mapMode == 0) ...[
          // Building & Classroom Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: C.line),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconBox(activeBuilding.icon, activeBuilding.color),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              t(
                                activeBuilding.name,
                                size: 17,
                                w: FontWeight.bold,
                              ),
                              const SizedBox(width: 8),
                              pill(activeBuilding.code, activeBuilding.color),
                            ],
                          ),
                          const SizedBox(height: 2),
                          t(
                            activeBuilding.walkingTime,
                            size: 12,
                            color: C.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                t(activeBuilding.description, size: 13, color: C.muted),
                const SizedBox(height: 16),

                // Floor Plan Selector & Indoor Directory
                t('Indoor Classroom Directory', size: 14, w: FontWeight.bold),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (
                        int idx = 0;
                        idx < activeBuilding.floors.length;
                        idx++
                      )
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              activeBuilding.floors[idx].split(':')[0],
                            ),
                            selected: _selectedFloorIndex == idx,
                            selectedColor: activeBuilding.color,
                            labelStyle: TextStyle(
                              color: _selectedFloorIndex == idx
                                  ? Colors.white
                                  : C.text,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) =>
                                setState(() => _selectedFloorIndex = idx),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.slateTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        color: C.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: t(
                          activeBuilding.floors[_selectedFloorIndex.clamp(
                            0,
                            activeBuilding.floors.length - 1,
                          )],
                          size: 13,
                          w: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                t(
                  'Scheduled Classes in this Building:',
                  size: 14,
                  w: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cls in activeBuilding.classes)
                      Chip(
                        avatar: const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: C.primary,
                        ),
                        label: Text(
                          cls,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: C.tealTint,
                        side: const BorderSide(color: C.primary),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List of All Campus Buildings for Quick Selection
          t('All Campus Locations', size: 18, w: FontWeight.bold),
          const SizedBox(height: 12),
          for (final b in searchFilteredBuildings)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InteractiveCard(
                color: b.id == _selectedBuildingId ? C.tealTint : Colors.white,
                border: b.id == _selectedBuildingId ? C.primary : C.line,
                onTap: () => setState(() => _selectedBuildingId = b.id),
                child: Row(
                  children: [
                    iconBox(b.icon, b.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t(b.name, w: FontWeight.bold, size: 14),
                          t(
                            '${b.code} · ${b.walkingTime}',
                            size: 11,
                            color: C.muted,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      b.id == _selectedBuildingId
                          ? Icons.my_location
                          : Icons.chevron_right,
                      color: b.id == _selectedBuildingId ? C.primary : C.muted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          // Bus Routes & Live Tracker Details Panel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              t('Campus Shuttle Bus Lines', size: 18, w: FontWeight.bold),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: C.amber,
                  foregroundColor: C.primaryDark,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _openStudentForm(service: 'Campus Bus Pass'),
                icon: const Icon(Icons.assignment_outlined, size: 14),
                label: const Text(
                  'Apply for Bus Pass',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in _busRoutes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InteractiveCard(
                color: r.id == _selectedRouteId ? C.indigoTint : Colors.white,
                border: r.id == _selectedRouteId ? C.indigo : C.line,
                onTap: () => setState(() => _selectedRouteId = r.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconBox(Icons.directions_bus, r.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              t(r.name, w: FontWeight.bold, size: 15),
                              t(
                                '${r.code} · ${r.frequency}',
                                size: 12,
                                color: C.muted,
                              ),
                            ],
                          ),
                        ),
                        pill(r.nextArrival, r.color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        t(
                          'Status: ${r.currentBusLocation}',
                          size: 12,
                          w: FontWeight.w600,
                          color: C.primaryDark,
                        ),
                        t(r.occupancy, size: 11, color: C.muted),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Bus Stop Timeline
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int sIdx = 0; sIdx < r.stops.length; sIdx++) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sIdx == 0 ? r.color : C.slateTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: t(
                                r.stops[sIdx],
                                size: 11,
                                w: FontWeight.bold,
                                color: sIdx == 0 ? Colors.white : C.text,
                              ),
                            ),
                            if (sIdx < r.stops.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.arrow_right_alt,
                                  size: 16,
                                  color: C.muted,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ---------- CAMPUS GALLERY SCREEN ----------
  Widget _gallery(bool isMobile) {
    final galleryItems = [
      (
        'SIST Grand Dome - Sunset Aerial View',
        'assets/images/real_campus_sunset.jpg',
        'Spectacular golden-hour sunset aerial panorama of the iconic white dome campus architecture with evening illumination.',
        'Architecture',
        true,
      ),
      (
        'Campus Recruitment & Placements Celebration',
        'assets/images/real_campus_recruitment.jpg',
        'Open-air courtyard celebration with students and faculty celebrating 2000+ offers from 200+ MNCs (53 LPA highest package).',
        'Placements',
        true,
      ),
      (
        'Central Library & Grand Marble Atrium',
        'assets/images/real_campus_library.jpg',
        'World-class university library featuring Italian checkerboard marble paving, chandelier lighting, and quiet study alcoves.',
        'Academics',
        true,
      ),
      (
        'Iconic Central Dome & Heritage Gazebo',
        'assets/images/real_campus_dome.jpg',
        'Front colonnade perspective of the palatial main university block with classical colonnades and landscaped circular rotunda.',
        'Landmarks',
        true,
      ),
      (
        'International Research Centre & Lawns',
        'assets/images/real_campus_research_centre.jpg',
        'Contemporary glass-facade International Research Centre wing adjoining lush botanical lawns and gardens.',
        'Research',
        true,
      ),
      (
        'Autonomous Campus Shuttle & Waypoint Station',
        'assets/images/ai_smart_campus.jpg',
        'AI-driven autonomous electric rover and holographic interactive waypoint timetable navigation along the central quad.',
        'Smart Campus',
        false,
      ),
      (
        'Quantum AI & Neural Network Lab',
        'assets/images/ai_cyber_lab.jpg',
        'Interactive 3D neural network hologram projection, high-compute AI GPU clusters, and student engineering pods.',
        'Innovation',
        false,
      ),
      (
        '24-Hour AI Hackfest Arena',
        'assets/images/ai_hackathon_stage.jpg',
        'Futuristic coding marathon floor with illuminated curved workstations and real-time live scoreboard.',
        'Hackathons',
        false,
      ),
      (
        'Robotics & Automation Testbed',
        'assets/images/service_lab.jpg',
        'Autonomous humanoid rover rigs, precision robotic limbs, and sensors test arena.',
        'Robotics',
        false,
      ),
      (
        'University Varsity Sports Stadium',
        'assets/images/event_sports.jpg',
        'Full-size varsity football and track arena illuminated under modern night floodlights.',
        'Athletics',
        false,
      ),
      (
        'Tanuj - AI Student Ambassador',
        'assets/images/student_avatar.jpg',
        'Computer Science and Artificial Intelligence student ambassador profile at SIST Innovation Hub.',
        'Community',
        false,
      ),
    ];

    final filtered = galleryItems.where((item) {
      if (_galleryFilter == 'Real Campus') return item.$5;
      if (_galleryFilter == 'AI Vision') return !item.$5;
      return true;
    }).toList();

    final realCount = galleryItems.where((item) => item.$5).length;
    final aiCount = galleryItems.where((item) => !item.$5).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        t(
          'Campus & AI Vision Gallery',
          size: isMobile ? 20 : 22,
          w: FontWeight.w800,
        ),
        const SizedBox(height: 4),
        t(
          'Explore authentic SIST campus landmarks alongside our futuristic AI concept visions',
          color: C.muted,
          size: 13,
        ),
        const SizedBox(height: 14),

        // Filter chips
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('All (${galleryItems.length})'),
              selected: _galleryFilter == 'All',
              selectedColor: C.primary.withValues(alpha: 0.15),
              onSelected: (_) => setState(() => _galleryFilter = 'All'),
            ),
            ChoiceChip(
              avatar: const Text('🏛️'),
              label: Text('Real Campus ($realCount)'),
              selected: _galleryFilter == 'Real Campus',
              selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
              onSelected: (_) => setState(() => _galleryFilter = 'Real Campus'),
            ),
            ChoiceChip(
              avatar: const Text('✨'),
              label: Text('AI Concept Vision ($aiCount)'),
              selected: _galleryFilter == 'AI Vision',
              selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
              onSelected: (_) => setState(() => _galleryFilter = 'AI Vision'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (ctx, c) {
            final n = c.maxWidth > 850 ? 3 : (c.maxWidth > 500 ? 2 : 1);
            final w = (c.maxWidth - 14 * (n - 1)) / n;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final g in filtered)
                  SizedBox(
                    width: w,
                    child: InteractiveCard(
                      onTap: () => _showImageLightbox(
                        g.$2,
                        g.$1,
                        g.$3,
                        badgeText: g.$5
                            ? '🏛️ Real Campus Photo'
                            : '✨ AI Concept Vision',
                        isReal: g.$5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  g.$2,
                                  height: isMobile ? 150 : 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 150,
                                    color: C.tealTint,
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: C.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: g.$5
                                        ? const Color(0xEE065F46)
                                        : const Color(0xEE1E1B4B),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: g.$5
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF818CF8),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        g.$5
                                            ? Icons.camera_alt
                                            : Icons.auto_awesome,
                                        size: 11,
                                        color: g.$5
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFFA5B4FC),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        g.$5 ? 'Real Photo' : 'AI Vision',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: g.$5
                                              ? const Color(0xFFD1FAE5)
                                              : const Color(0xFFE0E7FF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    g.$4,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          t(g.$1, size: 14, w: FontWeight.w700),
                          const SizedBox(height: 3),
                          t(g.$3, size: 11, color: C.muted),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.zoom_in, size: 13, color: C.primary),
                              SizedBox(width: 4),
                              Text(
                                'Tap to inspect HD view',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: C.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ---------- HELPDESK SCREEN ----------
  Widget _help() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            t('Submit Support Ticket', size: 18, w: FontWeight.w700),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _cat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Issue Category',
              ),
              items: [
                for (final c in const [
                  'Academic',
                  'Facilities',
                  'IT',
                  'Finance',
                ])
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _cat = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Detailed Description of Issue',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(140, 44),
                  backgroundColor: C.primary,
                ),
                onPressed: _submitTicket,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Submit Ticket'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      t('Your Tickets', size: 18, w: FontWeight.w700),
      const SizedBox(height: 12),
      for (var i = 0; i < _tickets.length; i++) _ticketItem(i),
    ],
  );

  Widget _ticketItem(int i) {
    final k = _tickets[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InteractiveCard(
        onTap: () => setState(() => _tickets[i] = (k.$1, k.$2, !k.$3)),
        child: Row(
          children: [
            iconBox(Icons.confirmation_number, k.$3 ? C.emerald : C.indigo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  t(k.$1, w: FontWeight.w600, size: 14),
                  t('${k.$2} · Tap to toggle status', size: 11, color: C.muted),
                ],
              ),
            ),
            pill(k.$3 ? 'Resolved' : 'Open', k.$3 ? C.emerald : C.indigo),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAVIGATION TILE COMPONENT
// -----------------------------------------------------------------------------

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 44,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white24,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? C.primary : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                t(
                  label,
                  w: FontWeight.w600,
                  size: 13,
                  color: selected ? C.primary : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CAMPUS MAP PAINTER (2D CANVAS GRAPHICS FOR MAP & BUS ROUTES)
// -----------------------------------------------------------------------------

class CampusMapPainter extends CustomPainter {
  final List<CampusBuilding> buildings;
  final String selectedBuildingId;
  final int mapMode; // 0 = Building/Class, 1 = Bus Routes
  final List<BusRouteInfo> routes;
  final String selectedRouteId;

  CampusMapPainter({
    required this.buildings,
    required this.selectedBuildingId,
    required this.mapMode,
    required this.routes,
    required this.selectedRouteId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 580.0;
    final scaleY = size.height / 380.0;

    // 1. Draw Campus Background Lawn / Terrain
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final parkPaint = Paint()
      ..color = const Color(0xFF064E3B).withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(80 * scaleX, 50 * scaleY, 420 * scaleX, 280 * scaleY),
        const Radius.circular(30),
      ),
      parkPaint,
    );

    // 2. Draw Campus Roads & Walkways
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0 * math.min(scaleX, scaleY)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final roadDashes = Path()
      ..moveTo(260 * scaleX, 360 * scaleY)
      ..lineTo(260 * scaleX, 190 * scaleY)
      ..lineTo(130 * scaleX, 110 * scaleY)
      ..moveTo(260 * scaleX, 190 * scaleY)
      ..lineTo(380 * scaleX, 95 * scaleY)
      ..moveTo(260 * scaleX, 270 * scaleY)
      ..lineTo(120 * scaleX, 270 * scaleY)
      ..moveTo(260 * scaleX, 260 * scaleY)
      ..lineTo(410 * scaleX, 260 * scaleY)
      ..lineTo(490 * scaleX, 160 * scaleY);

    canvas.drawPath(roadDashes, roadPaint);

    // Road Center Line
    final centerLinePaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(roadDashes, centerLinePaint);

    // 3. Mode Specific Overlays (Route Highlights & Walking Navigation)
    if (mapMode == 0) {
      // Draw Walking Path from Main Gate (260,350) to Selected Building
      final selectedBld = buildings.firstWhere(
        (b) => b.id == selectedBuildingId,
        orElse: () => buildings.first,
      );
      final pathPaint = Paint()
        ..color = C.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final walkPath = Path()
        ..moveTo(260 * scaleX, 350 * scaleY)
        ..lineTo(
          selectedBld.position.dx * scaleX,
          selectedBld.position.dy * scaleY,
        );

      canvas.drawPath(walkPath, pathPaint);
    } else {
      // Draw Bus Routes Path
      final selectedRoute = routes.firstWhere(
        (r) => r.id == selectedRouteId,
        orElse: () => routes.first,
      );
      final routePathPaint = Paint()
        ..color = selectedRoute.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      final routePath = Path();
      for (int i = 0; i < selectedRoute.routePath.length; i++) {
        final pt = Offset(
          selectedRoute.routePath[i].dx * scaleX,
          selectedRoute.routePath[i].dy * scaleY,
        );
        if (i == 0) {
          routePath.moveTo(pt.dx, pt.dy);
        } else {
          routePath.lineTo(pt.dx, pt.dy);
        }
      }

      canvas.drawPath(routePath, routePathPaint);

      // Draw Moving Bus Icon Markers on Route Path
      final busPaint = Paint()..color = selectedRoute.color;
      final busBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      for (int i = 0; i < selectedRoute.routePath.length - 1; i++) {
        final p1 = Offset(
          selectedRoute.routePath[i].dx * scaleX,
          selectedRoute.routePath[i].dy * scaleY,
        );
        final p2 = Offset(
          selectedRoute.routePath[i + 1].dx * scaleX,
          selectedRoute.routePath[i + 1].dy * scaleY,
        );
        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

        canvas.drawCircle(mid, 12, busPaint);
        canvas.drawCircle(mid, 12, busBorderPaint);
      }
    }

    // 4. Draw Building Nodes & Label Badges
    for (final b in buildings) {
      final pos = Offset(b.position.dx * scaleX, b.position.dy * scaleY);
      final isSelected = mapMode == 0 && b.id == selectedBuildingId;

      // Glow Pulse Ring for Selected Building
      if (isSelected) {
        final glowPaint = Paint()..color = b.color.withValues(alpha: 0.35);
        canvas.drawCircle(pos, 32 * math.min(scaleX, scaleY), glowPaint);
      }

      // Building Label Text
      final textSpan = TextSpan(
        text: b.code,
        style: TextStyle(
          color: isSelected ? C.amber : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 24),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CampusMapPainter oldDelegate) =>
      oldDelegate.selectedBuildingId != selectedBuildingId ||
      oldDelegate.mapMode != mapMode ||
      oldDelegate.selectedRouteId != selectedRouteId;
}
