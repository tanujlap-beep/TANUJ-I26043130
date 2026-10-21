import 'dart:async';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

// -----------------------------------------------------------------------------
// COLOR SYSTEM & DESIGN CONSTANTS
// -----------------------------------------------------------------------------
class FormColors {
  static const primary = Color(0xFF0D9488); // Teal
  static const primaryDark = Color(0xFF0F172A); // Midnight Slate
  static const primaryLight = Color(0xFF14B8A6);
  static const indigo = Color(0xFF6366F1);
  static const indigoDark = Color(0xFF4338CA);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);
  static const violet = Color(0xFF8B5CF6);
  static const emerald = Color(0xFF10B981);
  static const cyan = Color(0xFF06B6D4);

  static const bg = Color(0xFFF8FAFC);
  static const cardBg = Colors.white;
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);

  static const tealTint = Color(0xFFF0FDFA);
  static const indigoTint = Color(0xFFEEF2FF);
  static const amberTint = Color(0xFFFFFBEB);
  static const roseTint = Color(0xFFFFF1F2);
  static const emeraldTint = Color(0xFFECFDF5);
}

// -----------------------------------------------------------------------------
// STUDENT SUBMISSION DATA MODEL
// -----------------------------------------------------------------------------
class StudentSubmission {
  final String refId;
  final String serviceType; // 'Library Membership', 'Event Registration', etc.
  final IconData serviceIcon;
  final Color serviceColor;
  final String studentName;
  final String rollNo;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String bloodGroup;
  final String school;
  final String degree;
  final String year;
  final String semester;
  final String section;
  final String cgpa;
  final bool isHosteler;
  final String guardianName;
  final String guardianPhone;
  final String guardianRelation;
  final String city;
  final Map<String, String> serviceDetails;
  final DateTime submittedAt;
  final String status; // 'Verified & Active', 'Approved', 'Pending Review'
  final String attachedDoc;

  const StudentSubmission({
    required this.refId,
    required this.serviceType,
    required this.serviceIcon,
    required this.serviceColor,
    required this.studentName,
    required this.rollNo,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.school,
    required this.degree,
    required this.year,
    required this.semester,
    required this.section,
    required this.cgpa,
    required this.isHosteler,
    required this.guardianName,
    required this.guardianPhone,
    required this.guardianRelation,
    required this.city,
    required this.serviceDetails,
    required this.submittedAt,
    required this.status,
    required this.attachedDoc,
  });
}

// -----------------------------------------------------------------------------
// STUDENT FORM & APPLICATION PORTAL WIDGET
// -----------------------------------------------------------------------------
class StudentFormPortal extends StatefulWidget {
  final String? initialService;
  final String? initialEventTitle;
  final bool isDesktop;
  final bool isMobile;
  final VoidCallback? onBackToDashboard;
  final Function(String message)? onNotify;

  const StudentFormPortal({
    super.key,
    this.initialService,
    this.initialEventTitle,
    this.isDesktop = true,
    this.isMobile = false,
    this.onBackToDashboard,
    this.onNotify,
  });

  @override
  State<StudentFormPortal> createState() => _StudentFormPortalState();
}

class _StudentFormPortalState extends State<StudentFormPortal> {
  final _formKey = GlobalKey<FormState>();

  // Active top tab: 0 = New Application, 1 = Submitted Applications
  int _activeTab = 0;

  // Selected Service
  late String _selectedService;

  // Personal Information Controllers
  final _nameCtrl = TextEditingController(text: 'Tanuj');
  final _rollCtrl = TextEditingController(text: 'SIST-24-0417');
  final _emailCtrl = TextEditingController(text: 'tanuj.sist@university.edu');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  String _gender = 'Male';
  final _dobCtrl = TextEditingController(text: '2004-05-14');
  String _bloodGroup = 'O+';

  // Academic Credentials Controllers
  String _school = 'School of Computing';
  String _degree = 'B.Tech Computer Science & Engineering (AI)';
  String _year = 'Year 3';
  String _semester = 'Semester 5';
  final _sectionCtrl = TextEditingController(text: 'AI-B');
  final _cgpaCtrl = TextEditingController(text: '8.92');
  bool _isHosteler = false;

  // Guardian & Emergency Contact Controllers
  final _guardianNameCtrl = TextEditingController(text: 'Ramesh Kumar');
  final _guardianPhoneCtrl = TextEditingController(text: '+91 98410 12345');
  String _guardianRelation = 'Father';
  final _cityCtrl = TextEditingController(text: 'Chennai, Tamil Nadu');

  // Dynamic Service-Specific Controllers
  // 1. Library
  String _libraryPassType = 'Full Book Borrowing Pass (4 Books)';
  String _libraryStudyZone = 'Central Library Grand Atrium (Fl 1)';
  final Set<String> _selectedLibraryTopics = {
    'Artificial Intelligence',
    'Deep Learning',
    'Algorithms & Data Structures',
  };
  final _bookTitleCtrl = TextEditingController(
    text: 'Pattern Recognition and Machine Learning',
  );
  final _bookAuthorCtrl = TextEditingController(text: 'Christopher M. Bishop');

  // 2. Event Registration
  late String _selectedEvent;
  String _eventParticipationRole = 'Team Lead';
  final _eventTeamNameCtrl = TextEditingController(text: 'NeuralKnights');
  int _eventTeamSize = 4;
  String _tShirtSize = 'L';
  String _dietPreference = 'Regular Veg';
  final _eventTrackCtrl = TextEditingController(
    text: 'Generative AI & Agentic Workflows',
  );

  // 3. Bus Pass
  String _busRoute = 'Route A · Campus Express';
  String _busStop = 'Main Gate Transit Terminal';
  String _busShift = 'Both Morning & Evening';
  String _busPassDuration = 'Semester Pass (5 Months)';

  // 4. Lab Access
  String _labName = 'ML & Deep Learning Lab 3 (Tech Block C)';
  String _labSupervisor = 'Dr. Rao (AI Dept Chair)';
  String _labAccessLevel = '24/7 Extended Research Clearance';
  final _labProjectCtrl = TextEditingController(
    text: 'Autonomous Vision Agent for Campus Navigation',
  );

  // 5. Hostel Request
  String _hostelBlock = 'Scholars Hall Block A';
  String _hostelRoomType = 'Double Occupancy AC';
  String _hostelMessPlan = 'South Indian Deluxe Veg';

  // 6. Bonafide / Certificate
  String _bonafidePurpose = 'Internship & Research Grant Verification';
  int _bonafideCopies = 2;

  // Documents & Undertaking
  bool _undertakingAccepted = true;
  String _uploadedDocName = 'SIST_Student_ID_Tanuj.pdf';

  // Filter for Submissions tab
  String _historyFilter = 'All';

  // Firebase Firestore State & Subscription
  StreamSubscription<List<StudentSubmission>>? _submissionsSub;
  final _fbProjectCtrl =
      TextEditingController(text: 'sist-student-hub-2026');
  final _fbApiKeyCtrl = TextEditingController(
    text: 'AIzaSyDemoStudentHubKey2026SISTPlatform',
  );

  // Active Submissions List (Includes realistic existing records)
  List<StudentSubmission> _submissions = [
    StudentSubmission(
      refId: 'SIST-EVT-2026-9481',
      serviceType: 'Event Registration',
      serviceIcon: Icons.event,
      serviceColor: FormColors.indigo,
      studentName: 'Tanuj',
      rollNo: 'SIST-24-0417',
      email: 'tanuj.sist@university.edu',
      phone: '+91 98765 43210',
      gender: 'Male',
      dob: '2004-05-14',
      bloodGroup: 'O+',
      school: 'School of Computing',
      degree: 'B.Tech CSE (Artificial Intelligence)',
      year: 'Year 3',
      semester: 'Semester 5',
      section: 'AI-B',
      cgpa: '8.92',
      isHosteler: false,
      guardianName: 'Ramesh Kumar',
      guardianPhone: '+91 98410 12345',
      guardianRelation: 'Father',
      city: 'Chennai, Tamil Nadu',
      serviceDetails: {
        'Event Name': 'AI Hack Night 2024',
        'Role': 'Team Lead',
        'Team Name': 'NeuralKnights',
        'Team Size': '4 Members',
        'Track': 'Generative AI & LLMs',
        'T-Shirt': 'Size L',
      },
      submittedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      status: 'Verified & Confirmed',
      attachedDoc: 'SIST_Student_ID_Tanuj.pdf',
    ),
    StudentSubmission(
      refId: 'SIST-LIB-2026-6112',
      serviceType: 'Library Membership',
      serviceIcon: Icons.local_library,
      serviceColor: FormColors.primary,
      studentName: 'Tanuj',
      rollNo: 'SIST-24-0417',
      email: 'tanuj.sist@university.edu',
      phone: '+91 98765 43210',
      gender: 'Male',
      dob: '2004-05-14',
      bloodGroup: 'O+',
      school: 'School of Computing',
      degree: 'B.Tech CSE (Artificial Intelligence)',
      year: 'Year 3',
      semester: 'Semester 5',
      section: 'AI-B',
      cgpa: '8.92',
      isHosteler: false,
      guardianName: 'Ramesh Kumar',
      guardianPhone: '+91 98410 12345',
      guardianRelation: 'Father',
      city: 'Chennai, Tamil Nadu',
      serviceDetails: {
        'Pass Type': 'Full Book Borrowing Pass (4 Books)',
        'Preferred Wing': 'Central Library Grand Wing (Fl 1)',
        'Topics': 'AI, Machine Learning, Data Mining',
        'Active Books Borrowed': '2 Books Issued',
      },
      submittedAt: DateTime.now().subtract(const Duration(days: 14)),
      status: 'Active Pass Issued',
      attachedDoc: 'SIST_Student_ID_Tanuj.pdf',
    ),
    StudentSubmission(
      refId: 'SIST-BUS-2026-3820',
      serviceType: 'Campus Bus Pass',
      serviceIcon: Icons.directions_bus,
      serviceColor: FormColors.amber,
      studentName: 'Tanuj',
      rollNo: 'SIST-24-0417',
      email: 'tanuj.sist@university.edu',
      phone: '+91 98765 43210',
      gender: 'Male',
      dob: '2004-05-14',
      bloodGroup: 'O+',
      school: 'School of Computing',
      degree: 'B.Tech CSE (Artificial Intelligence)',
      year: 'Year 3',
      semester: 'Semester 5',
      section: 'AI-B',
      cgpa: '8.92',
      isHosteler: false,
      guardianName: 'Ramesh Kumar',
      guardianPhone: '+91 98410 12345',
      guardianRelation: 'Father',
      city: 'Chennai, Tamil Nadu',
      serviceDetails: {
        'Route': 'Route A · Campus Express',
        'Boarding Stop': 'Main Gate Transit Terminal',
        'Shift': 'Both Morning & Evening',
        'Validity': 'Semester 5 Pass',
      },
      submittedAt: DateTime.now().subtract(const Duration(days: 28)),
      status: 'Active Pass Issued',
      attachedDoc: 'SIST_Student_ID_Tanuj.pdf',
    ),
  ];

  static const List<(String, IconData, Color, String)> _services = [
    (
      'Library Membership',
      Icons.local_library,
      FormColors.primary,
      'Issue borrowing card, study pod pass & book reservations',
    ),
    (
      'Event Registration',
      Icons.event,
      FormColors.indigo,
      'Register for Hackathons, Placements, Workshops & Sports',
    ),
    (
      'Campus Bus Pass',
      Icons.directions_bus,
      FormColors.amber,
      'Apply for semester campus shuttle & transit routes',
    ),
    (
      'Lab Access Clearance',
      Icons.science,
      FormColors.rose,
      '24/7 clearance for ML Labs, Robotics & Compute Clusters',
    ),
    (
      'Hostel Accommodation',
      Icons.hotel,
      FormColors.violet,
      'Room allocation, dining mess enrollment & hostel clearance',
    ),
    (
      'Bonafide Certificate',
      Icons.verified,
      FormColors.cyan,
      'Official verification letter for loans, visa & internships',
    ),
  ];

  static const List<String> _campusEvents = [
    'Mega Placement Drive 2024',
    'AI Hack Night 2024',
    'University Football Trials',
    'Central Library Research Workshop',
    'Autonomous Rover & Robotics Expo',
    'National Coding Olympiad',
    'Other / Custom University Event',
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService ?? 'Library Membership';
    _selectedEvent = widget.initialEventTitle ?? _campusEvents[1];

    // Seed initial submissions into Firebase service
    FirebaseService.instance.seedInitialSubmissions(_submissions);

    // Subscribe to live Cloud Firestore updates
    _submissionsSub =
        FirebaseService.instance.submissionsStream.listen((list) {
      if (mounted && list.isNotEmpty) {
        setState(() {
          _submissions = List.from(list);
        });
      }
    });
  }

  @override
  void dispose() {
    _submissionsSub?.cancel();
    _fbProjectCtrl.dispose();
    _fbApiKeyCtrl.dispose();
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _sectionCtrl.dispose();
    _cgpaCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _cityCtrl.dispose();
    _bookTitleCtrl.dispose();
    _bookAuthorCtrl.dispose();
    _eventTeamNameCtrl.dispose();
    _eventTrackCtrl.dispose();
    _labProjectCtrl.dispose();
    super.dispose();
  }

  void _autofillProfile() {
    setState(() {
      _nameCtrl.text = 'Tanuj';
      _rollCtrl.text = 'SIST-24-0417';
      _emailCtrl.text = 'tanuj.sist@university.edu';
      _phoneCtrl.text = '+91 98765 43210';
      _gender = 'Male';
      _dobCtrl.text = '2004-05-14';
      _bloodGroup = 'O+';
      _school = 'School of Computing';
      _degree = 'B.Tech Computer Science & Engineering (AI)';
      _year = 'Year 3';
      _semester = 'Semester 5';
      _sectionCtrl.text = 'AI-B';
      _cgpaCtrl.text = '8.92';
      _isHosteler = false;
      _guardianNameCtrl.text = 'Ramesh Kumar';
      _guardianPhoneCtrl.text = '+91 98410 12345';
      _guardianRelation = 'Father';
      _cityCtrl.text = 'Chennai, Tamil Nadu';
      _undertakingAccepted = true;
      _uploadedDocName = 'SIST_Student_ID_Tanuj.pdf';
    });
    _notify('⚡ Auto-filled student profile credentials successfully!');
  }

  void _resetForm() {
    setState(() {
      _nameCtrl.clear();
      _rollCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _dobCtrl.clear();
      _sectionCtrl.clear();
      _cgpaCtrl.clear();
      _guardianNameCtrl.clear();
      _guardianPhoneCtrl.clear();
      _cityCtrl.clear();
      _bookTitleCtrl.clear();
      _bookAuthorCtrl.clear();
      _eventTeamNameCtrl.clear();
      _eventTrackCtrl.clear();
      _labProjectCtrl.clear();
      _undertakingAccepted = false;
    });
    _notify('Form fields cleared.');
  }

  void _notify(String msg) {
    if (widget.onNotify != null) {
      widget.onNotify!(msg);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      _notify('⚠️ Please correct highlighted errors before submitting.');
      return;
    }

    if (!_undertakingAccepted) {
      _notify('⚠️ Please accept the student declaration undertaking.');
      return;
    }

    // Generate service details map based on active service
    final Map<String, String> details = {};
    IconData icon = Icons.assignment;
    Color color = FormColors.primary;

    switch (_selectedService) {
      case 'Library Membership':
        icon = Icons.local_library;
        color = FormColors.primary;
        details['Pass Type'] = _libraryPassType;
        details['Study Zone'] = _libraryStudyZone;
        details['Interests'] = _selectedLibraryTopics.join(', ');
        if (_bookTitleCtrl.text.isNotEmpty) {
          details['Reserved Book'] =
              '${_bookTitleCtrl.text} by ${_bookAuthorCtrl.text}';
        }
        break;
      case 'Event Registration':
        icon = Icons.event;
        color = FormColors.indigo;
        details['Event Name'] = _selectedEvent;
        details['Role'] = _eventParticipationRole;
        if (_eventParticipationRole.contains('Team')) {
          details['Team Name'] = _eventTeamNameCtrl.text;
          details['Team Size'] = '$_eventTeamSize Members';
        }
        details['Track'] = _eventTrackCtrl.text;
        details['T-Shirt Size'] = _tShirtSize;
        details['Diet'] = _dietPreference;
        break;
      case 'Campus Bus Pass':
        icon = Icons.directions_bus;
        color = FormColors.amber;
        details['Route'] = _busRoute;
        details['Boarding Stop'] = _busStop;
        details['Shift'] = _busShift;
        details['Validity'] = _busPassDuration;
        break;
      case 'Lab Access Clearance':
        icon = Icons.science;
        color = FormColors.rose;
        details['Laboratory'] = _labName;
        details['Supervisor'] = _labSupervisor;
        details['Clearance Level'] = _labAccessLevel;
        details['Research Topic'] = _labProjectCtrl.text;
        break;
      case 'Hostel Accommodation':
        icon = Icons.hotel;
        color = FormColors.violet;
        details['Hostel Block'] = _hostelBlock;
        details['Room Type'] = _hostelRoomType;
        details['Meal Plan'] = _hostelMessPlan;
        break;
      case 'Bonafide Certificate':
        icon = Icons.verified;
        color = FormColors.cyan;
        details['Purpose'] = _bonafidePurpose;
        details['Copies'] = '$_bonafideCopies Official Hardcopies';
        break;
    }

    final int randSuffix = 1000 + (DateTime.now().millisecond * 9) % 8999;
    final String prefix = _selectedService.split(' ').first.substring(0, 3).toUpperCase();
    final String newRefId = 'SIST-$prefix-2026-$randSuffix';

    final newSubmission = StudentSubmission(
      refId: newRefId,
      serviceType: _selectedService,
      serviceIcon: icon,
      serviceColor: color,
      studentName: _nameCtrl.text.trim(),
      rollNo: _rollCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      dob: _dobCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      school: _school,
      degree: _degree,
      year: _year,
      semester: _semester,
      section: _sectionCtrl.text.trim(),
      cgpa: _cgpaCtrl.text.trim(),
      isHosteler: _isHosteler,
      guardianName: _guardianNameCtrl.text.trim(),
      guardianPhone: _guardianPhoneCtrl.text.trim(),
      guardianRelation: _guardianRelation,
      city: _cityCtrl.text.trim(),
      serviceDetails: details,
      submittedAt: DateTime.now(),
      status: 'Verified & Confirmed',
      attachedDoc: _uploadedDocName,
    );

    setState(() {
      _submissions.removeWhere((s) => s.refId == newSubmission.refId);
      _submissions.insert(0, newSubmission);
    });

    // Save to Firebase Cloud Firestore collection 'student_submissions'
    FirebaseService.instance.saveSubmission(newSubmission).then((result) {
      if (mounted) {
        _notify(result.$2);
      }
    });

    _showOfficialReceiptDialog(newSubmission);
  }

  void _showOfficialReceiptDialog(StudentSubmission sub) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner with Holographic University Colors
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sub.serviceColor,
                        sub.serviceColor.withValues(alpha: 0.8),
                        FormColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'SIST UNIVERSITY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Official Digital Submission Pass',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: FormColors.emerald,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Service Title & Ref
                      Text(
                        sub.serviceType.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ref ID: ${sub.refId}',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Identity Capsule
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FormColors.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FormColors.line),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: sub.serviceColor.withValues(
                                alpha: 0.15,
                              ),
                              child: Text(
                                sub.studentName.isNotEmpty
                                    ? sub.studentName[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: sub.serviceColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sub.studentName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: FormColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sub.rollNo} · ${sub.semester}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: FormColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    sub.degree,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: FormColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Details Grid
                      const Text(
                        'Application Breakdown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FormColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: FormColors.line),
                        ),
                        child: Column(
                          children: [
                            for (final entry in sub.serviceDetails.entries)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: FormColors.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: FormColors.text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Submitted On:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FormColors.muted,
                                  ),
                                ),
                                Text(
                                  _formatDate(sub.submittedAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Attachment:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FormColors.muted,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: FormColors.emerald,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      sub.attachedDoc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Cloud Database Sync:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FormColors.muted,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.cloud_done,
                                      color: FormColors.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Firestore (student_submissions)',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: FormColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // QR Code & Barcode Simulation
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: FormColors.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: FormColors.line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: FormColors.line),
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                size: 48,
                                color: FormColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Institutional Digital Verification',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Scan at campus entrance, library turnstiles or event kiosks for instant check-in.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: FormColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dialog Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: FormColors.line),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _notify('📥 Receipt downloaded as PDF!');
                              },
                              icon: const Icon(
                                Icons.download,
                                size: 18,
                                color: FormColors.text,
                              ),
                              label: const Text(
                                'Download Pass',
                                style: TextStyle(color: FormColors.text),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: sub.serviceColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() => _activeTab = 1);
                              },
                              icon: const Icon(Icons.list_alt, size: 18),
                              label: const Text('View All Passes'),
                            ),
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
      ),
    );
  }

  void _showFirebaseConfigDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.cloud_sync,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Firebase Cloud Firestore',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Student Form Submissions Database',
                    style: TextStyle(fontSize: 11, color: FormColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FormColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FormColors.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cloud Status:',
                            style: TextStyle(
                              fontSize: 12,
                              color: FormColors.muted,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                FirebaseService.instance.isLiveCloud
                                    ? Icons.check_circle
                                    : Icons.cloud_done,
                                size: 14,
                                color: FirebaseService.instance.isLiveCloud
                                    ? FormColors.emerald
                                    : FormColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                FirebaseService.instance.isLiveCloud
                                    ? 'Live Firestore Active'
                                    : 'Connected & Ready',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: FirebaseService.instance.isLiveCloud
                                      ? FormColors.emerald
                                      : FormColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Firestore Collection:',
                            style: TextStyle(
                              fontSize: 12,
                              color: FormColors.muted,
                            ),
                          ),
                          Text(
                            'student_submissions',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Project Configuration:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fbProjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Firebase Project ID',
                    hintText: 'e.g. sist-student-hub-2026',
                    prefixIcon: Icon(Icons.business, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fbApiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Web API Key',
                    hintText: 'AIzaSy...',
                    prefixIcon: Icon(Icons.key, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FormColors.indigoTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: FormColors.indigo.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '💡 How student form submissions are stored in Firebase:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: FormColors.indigoDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1. Every student form submission writes a JSON document with student personal details, academic program, guardian contact, and service specifics directly to Cloud Firestore.\n'
                        '2. Real-time snapshots automatically sync submitted forms across devices.\n'
                        '3. Documents are saved in the `student_submissions` Firestore collection keyed by Reference ID (e.g., SIST-LIB-2026-XXXX).',
                        style: TextStyle(
                          fontSize: 11,
                          color: FormColors.text,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: FormColors.primary),
            onPressed: () {
              FirebaseService.instance.updateConfig(
                newProjectId: _fbProjectCtrl.text.trim(),
                newApiKey: _fbApiKeyCtrl.text.trim(),
                newAppId: '1:108429381029:web:client',
              );
              Navigator.pop(ctx);
              _notify(
                'Firebase configuration updated for ${_fbProjectCtrl.text.trim()}!',
              );
            },
            icon: const Icon(Icons.cloud_done, size: 16),
            label: const Text('Save & Apply'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroPortalHeader(),
        const SizedBox(height: 20),
        _buildTabSwitcher(),
        const SizedBox(height: 20),
        if (_activeTab == 0) _buildNewApplicationView() else _buildSubmissionsHistoryView(),
      ],
    );
  }

  // ---------- TOP HERO PORTAL BANNER ----------
  Widget _buildHeroPortalHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 18 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            FormColors.primaryDark,
            Color(0xFF1E293B),
            Color(0xFF0F766E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FormColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: FormColors.emerald.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: FormColors.emerald.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified,
                              size: 13,
                              color: FormColors.emerald,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'SIST Official Unified Portal',
                              style: TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Firebase Live Indicator
                      InkWell(
                        onTap: _showFirebaseConfigDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF59E0B),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FirebaseService.instance.isLiveCloud
                                    ? Icons.cloud_done
                                    : Icons.cloud_sync,
                                size: 13,
                                color: const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Firestore: ${FirebaseService.instance.projectId}',
                                style: const TextStyle(
                                  color: Color(0xFFFEF3C7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.settings,
                                size: 11,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Quick autofill button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFDE047),
                      backgroundColor: Colors.white12,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    onPressed: _autofillProfile,
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text(
                      'Auto-Fill My Info',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Student Form Submission & Services Hub',
                style: TextStyle(
                  fontSize: widget.isMobile ? 20 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete all student registrations in one place: Library borrowing cards, campus hackathons & events, transit bus passes, lab clearances, and official certificates.',
                style: TextStyle(
                  fontSize: widget.isMobile ? 12 : 14,
                  color: const Color(0xFFCBD5E1),
                  height: 1.5,
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _heroStat(
                      '${_submissions.length} Applications',
                      Icons.folder_shared_outlined,
                    ),
                    _heroStat(
                      'Cloud Firestore: collection("student_submissions")',
                      Icons.cloud_queue_outlined,
                    ),
                    _heroStat(
                      'Instant QR Pass Generation',
                      Icons.qr_code_scanner_outlined,
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _heroStat(String text, IconData icon) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: const Color(0xFF2DD4BF)),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  // ---------- TAB SWITCHER (NEW APPLICATION vs SUBMISSIONS) ----------
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FormColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _activeTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? FormColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 0
                      ? [
                          BoxShadow(
                            color: FormColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_document,
                      size: 18,
                      color: _activeTab == 0 ? Colors.white : FormColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New Student Application',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _activeTab == 0 ? Colors.white : FormColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _activeTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? FormColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 1
                      ? [
                          BoxShadow(
                            color: FormColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 18,
                      color: _activeTab == 1 ? Colors.white : FormColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Submitted Applications (${_submissions.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _activeTab == 1 ? Colors.white : FormColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- VIEW 1: NEW APPLICATION FORM ----------
  Widget _buildNewApplicationView() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth >= 960;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Form Fields Column
              Expanded(
                flex: isWide ? 65 : 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Service Selector
                    _buildServiceTypeSelector(),
                    const SizedBox(height: 20),

                    // Section 1: Student Personal Details
                    _buildSectionCard(
                      stepNum: '1',
                      title: 'Personal Information',
                      subtitle:
                          'Primary student identity details verified with university registry.',
                      icon: Icons.person_outline,
                      color: FormColors.primary,
                      child: _buildPersonalDetailsFields(),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Academic Program & Credentials
                    _buildSectionCard(
                      stepNum: '2',
                      title: 'Academic Program & Credentials',
                      subtitle:
                          'Department, year, current semester & CGPA information.',
                      icon: Icons.school_outlined,
                      color: FormColors.indigo,
                      child: _buildAcademicFields(),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Guardian & Emergency Contact
                    _buildSectionCard(
                      stepNum: '3',
                      title: 'Guardian & Emergency Contact',
                      subtitle:
                          'Required for official records, notifications and travel safety.',
                      icon: Icons.contact_phone_outlined,
                      color: FormColors.amber,
                      child: _buildGuardianFields(),
                    ),
                    const SizedBox(height: 20),

                    // Section 4: Dynamic Service-Specific Fields
                    _buildSectionCard(
                      stepNum: '4',
                      title: '$_selectedService Details',
                      subtitle:
                          'Specific preferences, options and requests for this service.',
                      icon: _getServiceIcon(_selectedService),
                      color: _getServiceColor(_selectedService),
                      child: _buildDynamicServiceFields(),
                    ),
                    const SizedBox(height: 20),

                    // Section 5: Documents & Declaration Undertaking
                    _buildSectionCard(
                      stepNum: '5',
                      title: 'Verification & Undertaking',
                      subtitle:
                          'Review institutional honor code and submit application.',
                      icon: Icons.verified_user_outlined,
                      color: FormColors.emerald,
                      child: _buildUndertakingFields(),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons (Submit & Reset)
                    _buildFormActionButtons(),
                  ],
                ),
              ),

              // Sticky / Side Live Preview (Desktop only)
              if (isWide) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 35,
                  child: _buildLiveStudentPreviewCard(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ---------- SERVICE SELECTOR TILES ----------
  Widget _buildServiceTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FormColors.line),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.category_outlined, color: FormColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Select Application / Service Purpose',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: FormColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the university facility or registration you are applying for. The form adapts dynamically.',
            style: TextStyle(fontSize: 12, color: FormColors.muted),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (ctx, c) {
              final cols = c.maxWidth > 550 ? 3 : (c.maxWidth > 360 ? 2 : 1);
              final itemWidth = (c.maxWidth - (cols - 1) * 10) / cols;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in _services)
                    SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _selectedService = s.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedService == s.$1
                                ? s.$3.withValues(alpha: 0.08)
                                : FormColors.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedService == s.$1
                                  ? s.$3
                                  : FormColors.line,
                              width: _selectedService == s.$1 ? 2.0 : 1.0,
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
                                      color: _selectedService == s.$1
                                          ? s.$3
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedService == s.$1
                                            ? Colors.transparent
                                            : FormColors.line,
                                      ),
                                    ),
                                    child: Icon(
                                      s.$2,
                                      size: 18,
                                      color: _selectedService == s.$1
                                          ? Colors.white
                                          : s.$3,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedService == s.$1)
                                    Icon(
                                      Icons.check_circle,
                                      color: s.$3,
                                      size: 16,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.$1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: _selectedService == s.$1
                                      ? s.$3
                                      : FormColors.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.$4,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: FormColors.muted,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- REUSABLE SECTION CARD WRAPPER ----------
  Widget _buildSectionCard({
    required String stepNum,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FormColors.line),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  stepNum,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FormColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: FormColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: FormColors.line),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ---------- SECTION 1: PERSONAL DETAILS ----------
  Widget _buildPersonalDetailsFields() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 500;

        return Column(
          children: [
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _formTextField(
                      controller: _nameCtrl,
                      label: 'Student Full Name *',
                      icon: Icons.person,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _formTextField(
                      controller: _rollCtrl,
                      label: 'Student Roll / Reg Number *',
                      icon: Icons.badge_outlined,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              )
            else ...[
              _formTextField(
                controller: _nameCtrl,
                label: 'Student Full Name *',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _formTextField(
                controller: _rollCtrl,
                label: 'Student Roll / Reg Number *',
                icon: Icons.badge_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 14),
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _formTextField(
                      controller: _emailCtrl,
                      label: 'University Email Address *',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _formTextField(
                      controller: _phoneCtrl,
                      label: 'Contact Mobile / WhatsApp *',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.length < 8 ? 'Enter valid phone' : null,
                    ),
                  ),
                ],
              )
            else ...[
              _formTextField(
                controller: _emailCtrl,
                label: 'University Email Address *',
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 14),
              _formTextField(
                controller: _phoneCtrl,
                label: 'Contact Mobile / WhatsApp *',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.length < 8 ? 'Enter valid phone' : null,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    label: 'Gender',
                    value: _gender,
                    items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _dropdownField(
                    label: 'Blood Group',
                    value: _bloodGroup,
                    items: const ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'],
                    onChanged: (v) => setState(() => _bloodGroup = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _formTextField(
              controller: _dobCtrl,
              label: 'Date of Birth (YYYY-MM-DD)',
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2004, 5, 14),
                  firstDate: DateTime(1995),
                  lastDate: DateTime(2010),
                );
                if (picked != null) {
                  setState(() {
                    _dobCtrl.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ---------- SECTION 2: ACADEMIC DETAILS ----------
  Widget _buildAcademicFields() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 500;

        return Column(
          children: [
            _dropdownField(
              label: 'Faculty / School *',
              value: _school,
              items: const [
                'School of Computing',
                'School of Electrical & Electronics',
                'School of Mechanical Engineering',
                'School of Science & Humanities',
                'School of Management Studies',
              ],
              onChanged: (v) => setState(() => _school = v!),
            ),
            const SizedBox(height: 14),
            _dropdownField(
              label: 'Degree & Program Specialization *',
              value: _degree,
              items: const [
                'B.Tech Computer Science & Engineering (AI)',
                'B.Tech Computer Science & Engineering (Core)',
                'B.Tech Artificial Intelligence & Data Science',
                'B.Tech Information Technology',
                'B.Tech Electronics & Communication Engineering',
                'M.Tech Computer Science & AI',
                'MCA Master of Computer Applications',
              ],
              onChanged: (v) => setState(() => _degree = v!),
            ),
            const SizedBox(height: 14),
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _dropdownField(
                      label: 'Academic Year',
                      value: _year,
                      items: const ['Year 1', 'Year 2', 'Year 3', 'Year 4'],
                      onChanged: (v) => setState(() => _year = v!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _dropdownField(
                      label: 'Current Semester',
                      value: _semester,
                      items: const [
                        'Semester 1',
                        'Semester 2',
                        'Semester 3',
                        'Semester 4',
                        'Semester 5',
                        'Semester 6',
                        'Semester 7',
                        'Semester 8',
                      ],
                      onChanged: (v) => setState(() => _semester = v!),
                    ),
                  ),
                ],
              )
            else ...[
              _dropdownField(
                label: 'Academic Year',
                value: _year,
                items: const ['Year 1', 'Year 2', 'Year 3', 'Year 4'],
                onChanged: (v) => setState(() => _year = v!),
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Current Semester',
                value: _semester,
                items: const [
                  'Semester 1',
                  'Semester 2',
                  'Semester 3',
                  'Semester 4',
                  'Semester 5',
                  'Semester 6',
                  'Semester 7',
                  'Semester 8',
                ],
                onChanged: (v) => setState(() => _semester = v!),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _formTextField(
                    controller: _sectionCtrl,
                    label: 'Class Section (e.g. AI-B)',
                    icon: Icons.groups_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _formTextField(
                    controller: _cgpaCtrl,
                    label: 'Cumulative CGPA / GPA',
                    icon: Icons.auto_graph,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: FormColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FormColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    color: FormColors.muted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Residency Status: Are you staying in university campus hostel?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: _isHosteler,
                    activeThumbColor: FormColors.primary,
                    onChanged: (v) => setState(() => _isHosteler = v),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- SECTION 3: GUARDIAN & EMERGENCY CONTACT ----------
  Widget _buildGuardianFields() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 500;

        return Column(
          children: [
            if (isWide)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _formTextField(
                      controller: _guardianNameCtrl,
                      label: 'Parent / Guardian Full Name *',
                      icon: Icons.family_restroom,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _dropdownField(
                      label: 'Relationship',
                      value: _guardianRelation,
                      items: const ['Father', 'Mother', 'Local Guardian', 'Spouse'],
                      onChanged: (v) => setState(() => _guardianRelation = v!),
                    ),
                  ),
                ],
              )
            else ...[
              _formTextField(
                controller: _guardianNameCtrl,
                label: 'Parent / Guardian Full Name *',
                icon: Icons.family_restroom,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Relationship',
                value: _guardianRelation,
                items: const ['Father', 'Mother', 'Local Guardian', 'Spouse'],
                onChanged: (v) => setState(() => _guardianRelation = v!),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _formTextField(
                    controller: _guardianPhoneCtrl,
                    label: 'Emergency Phone Number *',
                    icon: Icons.emergency,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.length < 8 ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _formTextField(
                    controller: _cityCtrl,
                    label: 'Residential City & State',
                    icon: Icons.location_city_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ---------- SECTION 4: DYNAMIC SERVICE-SPECIFIC FIELDS ----------
  Widget _buildDynamicServiceFields() {
    switch (_selectedService) {
      case 'Library Membership':
        return _buildLibrarySubFields();
      case 'Event Registration':
        return _buildEventSubFields();
      case 'Campus Bus Pass':
        return _buildBusSubFields();
      case 'Lab Access Clearance':
        return _buildLabSubFields();
      case 'Hostel Accommodation':
        return _buildHostelSubFields();
      case 'Bonafide Certificate':
      default:
        return _buildBonafideSubFields();
    }
  }

  // 1. Library Specific Subfields
  Widget _buildLibrarySubFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownField(
          label: 'Library Card & Access Tier *',
          value: _libraryPassType,
          items: const [
            'Full Book Borrowing Pass (4 Books)',
            'General Reading & Digital Hub Pass',
            'Research Scholar Access (IEEE/ACM Full Access)',
          ],
          onChanged: (v) => setState(() => _libraryPassType = v!),
        ),
        const SizedBox(height: 14),
        _dropdownField(
          label: 'Primary Study Zone & Branch',
          value: _libraryStudyZone,
          items: const [
            'Central Library Grand Atrium (Fl 1)',
            'Silent Study Pods & Carrels (Fl 2)',
            'Digital Reference & Journal Lab (Fl 3)',
          ],
          onChanged: (v) => setState(() => _libraryStudyZone = v!),
        ),
        const SizedBox(height: 14),
        const Text(
          'Primary Research & Reading Topics of Interest:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final topic in [
              'Artificial Intelligence',
              'Deep Learning',
              'Algorithms & Data Structures',
              'Cloud & Distributed Systems',
              'Cyber Security',
              'Robotics & Embedded Systems',
              'Applied Mathematics',
              'Quantum Computing',
            ])
              FilterChip(
                label: Text(topic),
                selected: _selectedLibraryTopics.contains(topic),
                selectedColor: FormColors.primary.withValues(alpha: 0.18),
                checkmarkColor: FormColors.primary,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _selectedLibraryTopics.contains(topic)
                      ? FormColors.primary
                      : FormColors.text,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLibraryTopics.add(topic);
                    } else {
                      _selectedLibraryTopics.remove(topic);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FormColors.tealTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FormColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bookmark_add, size: 16, color: FormColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Optional: Request First Book Reservation',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: FormColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _formTextField(
                controller: _bookTitleCtrl,
                label: 'Book Title / Subject Query',
                icon: Icons.menu_book,
              ),
              const SizedBox(height: 10),
              _formTextField(
                controller: _bookAuthorCtrl,
                label: 'Author Name (Optional)',
                icon: Icons.person_search,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Event Specific Subfields
  Widget _buildEventSubFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownField(
          label: 'Select Campus Event to Register *',
          value: _selectedEvent,
          items: _campusEvents,
          onChanged: (v) => setState(() => _selectedEvent = v!),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                label: 'Participation Role *',
                value: _eventParticipationRole,
                items: const [
                  'Team Lead',
                  'Team Member',
                  'Solo Participant',
                  'Student Volunteer',
                  'Observer / Attendee',
                ],
                onChanged: (v) => setState(() => _eventParticipationRole = v!),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField(
                label: 'T-Shirt / Swag Size',
                value: _tShirtSize,
                items: const ['S', 'M', 'L', 'XL', 'XXL'],
                onChanged: (v) => setState(() => _tShirtSize = v!),
              ),
            ),
          ],
        ),
        if (_eventParticipationRole.contains('Team')) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _formTextField(
                  controller: _eventTeamNameCtrl,
                  label: 'Team Name *',
                  icon: Icons.shield_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Team name required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: _dropdownField(
                  label: 'Team Size',
                  value: '$_eventTeamSize Members',
                  items: const ['2 Members', '3 Members', '4 Members', '5 Members'],
                  onChanged: (v) {
                    final num = int.tryParse(v!.split(' ').first) ?? 4;
                    setState(() => _eventTeamSize = num);
                  },
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _formTextField(
                controller: _eventTrackCtrl,
                label: 'Technical Domain / Track *',
                icon: Icons.code,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField(
                label: 'Dietary Preference',
                value: _dietPreference,
                items: const ['Regular Veg', 'Special Jain Veg', 'Non-Veg', 'No Refreshment'],
                onChanged: (v) => setState(() => _dietPreference = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Bus Pass Specific Subfields
  Widget _buildBusSubFields() {
    return Column(
      children: [
        _dropdownField(
          label: 'Shuttle Route *',
          value: _busRoute,
          items: const [
            'Route A · Campus Express',
            'Route B · Hostel Shuttle',
            'Route C · Sports Arena Loop',
            'Route D · Metro Transit Link',
          ],
          onChanged: (v) => setState(() => _busRoute = v!),
        ),
        const SizedBox(height: 14),
        _dropdownField(
          label: 'Boarding Stop *',
          value: _busStop,
          items: const [
            'Main Gate Transit Terminal',
            'Central Library Stop',
            'Tech Block C Terminal',
            'Hostels South Gate',
            'Metro Station Connector',
          ],
          onChanged: (v) => setState(() => _busStop = v!),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                label: 'Daily Shift',
                value: _busShift,
                items: const [
                  'Both Morning & Evening',
                  'Morning Pickup Only (8:00 AM)',
                  'Evening Drop Only (4:30 PM)',
                ],
                onChanged: (v) => setState(() => _busShift = v!),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField(
                label: 'Pass Validity',
                value: _busPassDuration,
                items: const [
                  'Semester Pass (5 Months)',
                  'Monthly Pass (30 Days)',
                  'Annual Pass (Full Year)',
                ],
                onChanged: (v) => setState(() => _busPassDuration = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Lab Access Specific Subfields
  Widget _buildLabSubFields() {
    return Column(
      children: [
        _dropdownField(
          label: 'Laboratory / Research Arena *',
          value: _labName,
          items: const [
            'ML & Deep Learning Lab 3 (Tech Block C)',
            'Autonomous Robotics & Drone Arena',
            'High-Performance Compute Cluster',
            'Cyber Security & Cryptography Center',
          ],
          onChanged: (v) => setState(() => _labName = v!),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                label: 'Supervisor / Faculty *',
                value: _labSupervisor,
                items: const [
                  'Dr. Rao (AI Dept Chair)',
                  'Prof. Smith (CS Dept)',
                  'Dr. Mehta (Ethics & Systems)',
                  'Dr. Ali (Data Science)',
                ],
                onChanged: (v) => setState(() => _labSupervisor = v!),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField(
                label: 'Access Hours Tier',
                value: _labAccessLevel,
                items: const [
                  '24/7 Extended Research Clearance',
                  'Standard Lab Hours (8 AM - 5 PM)',
                  'Evening Research Hours (5 PM - 9 PM)',
                ],
                onChanged: (v) => setState(() => _labAccessLevel = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _formTextField(
          controller: _labProjectCtrl,
          label: 'Project Title / Research Justification *',
          icon: Icons.lightbulb_outline,
          validator: (v) => v == null || v.isEmpty ? 'Project title required' : null,
        ),
      ],
    );
  }

  // 5. Hostel Specific Subfields
  Widget _buildHostelSubFields() {
    return Column(
      children: [
        _dropdownField(
          label: 'Hostel Block Preference *',
          value: _hostelBlock,
          items: const [
            'Scholars Hall Block A',
            'Tech Block Hostel B',
            'International Student Residence',
          ],
          onChanged: (v) => setState(() => _hostelBlock = v!),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField(
                label: 'Room Type',
                value: _hostelRoomType,
                items: const [
                  'Double Occupancy AC',
                  'Single Occupancy AC',
                  '3-Sharing Standard Non-AC',
                ],
                onChanged: (v) => setState(() => _hostelRoomType = v!),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField(
                label: 'Dining Mess Plan',
                value: _hostelMessPlan,
                items: const [
                  'South Indian Deluxe Veg',
                  'North Indian Veg Special',
                  'Non-Veg Mixed Meal Plan',
                ],
                onChanged: (v) => setState(() => _hostelMessPlan = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 6. Bonafide Specific Subfields
  Widget _buildBonafideSubFields() {
    return Column(
      children: [
        _dropdownField(
          label: 'Certificate Purpose *',
          value: _bonafidePurpose,
          items: const [
            'Internship & Research Grant Verification',
            'Education Loan & Bank Verification',
            'Passport / Visa Application',
            'Transit & Bus Pass Concession',
          ],
          onChanged: (v) => setState(() => _bonafidePurpose = v!),
        ),
        const SizedBox(height: 14),
        _dropdownField(
          label: 'Number of Official Hardcopies',
          value: '$_bonafideCopies Copies',
          items: const ['1 Copy', '2 Copies', '3 Copies', '5 Copies'],
          onChanged: (v) {
            final count = int.tryParse(v!.split(' ').first) ?? 2;
            setState(() => _bonafideCopies = count);
          },
        ),
      ],
    );
  }

  // ---------- SECTION 5: UNDERTAKING & ATTACHMENTS ----------
  Widget _buildUndertakingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simulated Attachment Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FormColors.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FormColors.line),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FormColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: FormColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _uploadedDocName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: FormColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Institutional Digital Verification ID · 420 KB',
                      style: TextStyle(
                        fontSize: 11,
                        color: FormColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: FormColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _uploadedDocName =
                        'SIST_Student_ID_${_nameCtrl.text.replaceAll(' ', '_')}.pdf';
                  });
                  _notify('ID document verified & attached!');
                },
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Re-Attach', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Undertaking Checkbox
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              setState(() => _undertakingAccepted = !_undertakingAccepted),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _undertakingAccepted
                  ? FormColors.emerald.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _undertakingAccepted
                    ? FormColors.emerald.withValues(alpha: 0.4)
                    : FormColors.line,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _undertakingAccepted,
                  activeColor: FormColors.emerald,
                  onChanged: (v) =>
                      setState(() => _undertakingAccepted = v ?? false),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'I hereby declare that all information furnished in this form is true and authentic. I agree to abide by the university statutes, disciplinary regulations, and specific terms for this service.',
                    style: TextStyle(
                      fontSize: 12,
                      color: FormColors.text,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- FORM ACTION BUTTONS ----------
  Widget _buildFormActionButtons() {
    return LayoutBuilder(
      builder: (ctx, c) {
        if (c.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _getServiceColor(_selectedService),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: _submitForm,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  'Submit $_selectedService Application',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: FormColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _resetForm,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Reset Form'),
              ),
            ],
          );
        }
        return Row(
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                side: const BorderSide(color: FormColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _resetForm,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Reset Form'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _getServiceColor(_selectedService),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: _submitForm,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  'Submit $_selectedService Application',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- LIVE PREVIEW CARD (DESKTOP RIGHT SIDEBAR) ----------
  Widget _buildLiveStudentPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FormColors.line),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: FormColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.badge,
                  color: FormColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Live Digital ID',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: FormColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FormColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SYNCED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: FormColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Digital Student ID Badge
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FormColors.primaryDark,
                  const Color(0xFF1E293B),
                  _getServiceColor(_selectedService).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _getServiceColor(_selectedService).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SIST UNIVERSITY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(
                      _getServiceIcon(_selectedService),
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text.isNotEmpty
                                ? _nameCtrl.text
                                : 'Student Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _rollCtrl.text.isNotEmpty
                                ? _rollCtrl.text
                                : 'SIST-24-0000',
                            style: const TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            '$_semester · $_year',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedService,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'PENDING SUBMIT',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Live Quick Checklist
          const Text(
            'Checklist Before Submission',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: FormColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          _checklistRow(
            'Personal Info Filled',
            _nameCtrl.text.isNotEmpty && _rollCtrl.text.isNotEmpty,
          ),
          _checklistRow(
            'University Email & Contact Valid',
            _emailCtrl.text.contains('@') && _phoneCtrl.text.length >= 8,
          ),
          _checklistRow(
            'Emergency Contact Recorded',
            _guardianNameCtrl.text.isNotEmpty &&
                _guardianPhoneCtrl.text.isNotEmpty,
          ),
          _checklistRow(
            'Target Facility Selected',
            _selectedService.isNotEmpty,
          ),
          _checklistRow(
            'Declaration Accepted',
            _undertakingAccepted,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: FormColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _submitForm,
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  Widget _checklistRow(String label, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 15,
          color: done ? FormColors.emerald : FormColors.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: done ? FormColors.text : FormColors.muted,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );

  // ---------- VIEW 2: SUBMITTED APPLICATIONS HISTORY ----------
  Widget _buildSubmissionsHistoryView() {
    final filtered = _historyFilter == 'All'
        ? _submissions
        : _submissions.where((s) => s.serviceType.contains(_historyFilter)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cat in ['All', 'Library', 'Event', 'Bus', 'Lab', 'Hostel', 'Bonafide'])
              ChoiceChip(
                label: Text(cat),
                selected: _historyFilter == cat,
                selectedColor: FormColors.primary,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _historyFilter == cat ? Colors.white : FormColors.text,
                ),
                onSelected: (sel) {
                  if (sel) setState(() => _historyFilter = cat);
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FormColors.line),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: FormColors.muted,
                ),
                const SizedBox(height: 12),
                Text(
                  'No submitted applications found in "$_historyFilter"',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: FormColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Switch to "New Student Application" to submit a new request.',
                  style: TextStyle(fontSize: 12, color: FormColors.muted),
                ),
              ],
            ),
          )
        else
          for (final sub in filtered) ...[
            _buildSubmissionHistoryItem(sub),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildSubmissionHistoryItem(StudentSubmission sub) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FormColors.line),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showOfficialReceiptDialog(sub),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sub.serviceColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        sub.serviceIcon,
                        color: sub.serviceColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                sub.serviceType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: FormColors.text,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: FormColors.emerald.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: FormColors.emerald.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: FormColors.emerald,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      sub.status,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: FormColors.emerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${sub.refId} · Submitted ${_formatDate(sub.submittedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: FormColors.muted,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: FormColors.line),
                const SizedBox(height: 12),

                // Key Service Details Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final entry in sub.serviceDetails.entries.take(3))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: FormColors.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: FormColors.line),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: FormColors.text,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Student: ${sub.studentName} (${sub.rollNo})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: FormColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: sub.serviceColor,
                      ),
                      onPressed: () => _showOfficialReceiptDialog(sub),
                      icon: const Icon(Icons.qr_code_2, size: 16),
                      label: const Text(
                        'View Digital Pass & QR',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HELPER UI FORM COMPONENTS ----------
  Widget _formTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      readOnly: onTap != null,
      style: const TextStyle(fontSize: 13, color: FormColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: FormColors.muted),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: FormColors.primary)
            : null,
        filled: true,
        fillColor: FormColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.primary, width: 1.6),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      isExpanded: true,
      initialValue: items.contains(value) ? value : items.first,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: FormColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: FormColors.muted),
        filled: true,
        fillColor: FormColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FormColors.primary, width: 1.6),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
      ],
    );
  }

  IconData _getServiceIcon(String service) {
    for (final s in _services) {
      if (s.$1 == service) return s.$2;
    }
    return Icons.assignment;
  }

  Color _getServiceColor(String service) {
    for (final s in _services) {
      if (s.$1 == service) return s.$3;
    }
    return FormColors.primary;
  }
}
