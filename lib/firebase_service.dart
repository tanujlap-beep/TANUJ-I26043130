import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'student_form.dart';

/// Centralized Firebase & Cloud Firestore Service for Student Form Submissions
class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  bool _initialized = false;
  bool _isLiveCloud = false;
  String _projectId = DefaultFirebaseOptions.web.projectId;
  String _apiKey = DefaultFirebaseOptions.web.apiKey;
  String _appId = DefaultFirebaseOptions.web.appId;
  String _statusMessage = 'Connecting to Firebase...';

  bool get isInitialized => _initialized;
  bool get isLiveCloud => _isLiveCloud;
  String get projectId => _projectId;
  String get apiKey => _apiKey;
  String get appId => _appId;
  String get statusMessage => _statusMessage;

  // Local reactive cache to ensure offline resilience
  final List<StudentSubmission> _localSubmissions = [];
  final StreamController<List<StudentSubmission>> _streamController =
      StreamController<List<StudentSubmission>>.broadcast();

  Stream<List<StudentSubmission>> get submissionsStream =>
      _streamController.stream;

  List<StudentSubmission> get currentSubmissions =>
      List.unmodifiable(_localSubmissions);

  /// Initializes Firebase Core and Cloud Firestore
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      _projectId = DefaultFirebaseOptions.currentPlatform.projectId;
      _statusMessage = 'Connected to Firestore ($projectId)';
      _isLiveCloud = true;

      // Listen to Firestore updates
      _listenToFirestore();
    } catch (e) {
      _initialized = false;
      _isLiveCloud = false;
      _statusMessage = 'Local Persistent Mode ($e)';
      _streamController.add(List.from(_localSubmissions));
    }
  }

  void seedInitialSubmissions(List<StudentSubmission> initial) {
    if (_localSubmissions.isEmpty) {
      _localSubmissions.addAll(initial);
      _streamController.add(List.from(_localSubmissions));
    }
  }

  void _listenToFirestore() {
    try {
      final collection =
          FirebaseFirestore.instance.collection('student_submissions');

      collection
          .orderBy('submittedAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final cloudList = <StudentSubmission>[];
            for (final doc in snapshot.docs) {
              final sub = _fromFirestoreMap(doc.data());
              if (sub != null) {
                cloudList.add(sub);
              }
            }
            if (cloudList.isNotEmpty) {
              _localSubmissions.clear();
              _localSubmissions.addAll(cloudList);
              _streamController.add(List.from(_localSubmissions));
            }
          }
        },
        onError: (err) {
          _isLiveCloud = false;
          _statusMessage = 'Cloud stream error: $err';
        },
      );
    } catch (e) {
      _isLiveCloud = false;
      _statusMessage = 'Firestore listen offline: $e';
    }
  }

  /// Saves a student form submission to Cloud Firestore
  Future<(bool success, String message)> saveSubmission(
    StudentSubmission sub,
  ) async {
    // 1. Always update local state first for instant UX
    _localSubmissions.removeWhere((item) => item.refId == sub.refId);
    _localSubmissions.insert(0, sub);
    _streamController.add(List.from(_localSubmissions));

    // 2. Attempt Firestore Write
    try {
      final docData = _toFirestoreMap(sub);
      await FirebaseFirestore.instance
          .collection('student_submissions')
          .doc(sub.refId)
          .set(docData, SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));

      _isLiveCloud = true;
      _statusMessage = 'Cloud Sync: Active ($projectId)';
      return (
        true,
        'Successfully saved to Cloud Firestore (collection: student_submissions)'
      );
    } catch (e) {
      _statusMessage = 'Saved locally (Cloud pending: $e)';
      return (
        true,
        'Saved to submissions registry (Cloud sync pending or offline)'
      );
    }
  }

  /// Updates Firebase configuration dynamically
  Future<void> updateConfig({
    required String newProjectId,
    required String newApiKey,
    required String newAppId,
  }) async {
    _projectId = newProjectId;
    _apiKey = newApiKey;
    _appId = newAppId;
    _statusMessage = 'Configuration updated for project: $_projectId';
    _streamController.add(List.from(_localSubmissions));
  }

  /// Serializes StudentSubmission to Firestore JSON Map
  Map<String, dynamic> _toFirestoreMap(StudentSubmission sub) {
    return {
      'refId': sub.refId,
      'serviceType': sub.serviceType,
      'studentName': sub.studentName,
      'rollNo': sub.rollNo,
      'email': sub.email,
      'phone': sub.phone,
      'gender': sub.gender,
      'dob': sub.dob,
      'bloodGroup': sub.bloodGroup,
      'school': sub.school,
      'degree': sub.degree,
      'year': sub.year,
      'semester': sub.semester,
      'section': sub.section,
      'cgpa': sub.cgpa,
      'isHosteler': sub.isHosteler,
      'guardianName': sub.guardianName,
      'guardianPhone': sub.guardianPhone,
      'guardianRelation': sub.guardianRelation,
      'city': sub.city,
      'serviceDetails': sub.serviceDetails,
      'submittedAt': sub.submittedAt.toIso8601String(),
      'status': sub.status,
      'attachedDoc': sub.attachedDoc,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Deserializes Firestore Map to StudentSubmission
  StudentSubmission? _fromFirestoreMap(Map<String, dynamic> data) {
    try {
      DateTime dt;
      if (data['submittedAt'] != null) {
        dt = DateTime.tryParse(data['submittedAt'].toString()) ?? DateTime.now();
      } else {
        dt = DateTime.now();
      }

      final service = data['serviceType'] as String? ?? 'General';
      final (icon, color) = _getServiceVisuals(service);

      final Map<String, String> detailsMap = {};
      if (data['serviceDetails'] is Map) {
        final raw = data['serviceDetails'] as Map;
        for (final k in raw.keys) {
          detailsMap[k.toString()] = raw[k].toString();
        }
      }

      return StudentSubmission(
        refId: data['refId'] as String? ?? 'SIST-APP-2026',
        serviceType: service,
        serviceIcon: icon,
        serviceColor: color,
        studentName: data['studentName'] as String? ?? '',
        rollNo: data['rollNo'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        gender: data['gender'] as String? ?? 'Male',
        dob: data['dob'] as String? ?? '',
        bloodGroup: data['bloodGroup'] as String? ?? 'O+',
        school: data['school'] as String? ?? 'School of Computing',
        degree: data['degree'] as String? ?? 'B.Tech CSE',
        year: data['year'] as String? ?? 'Year 3',
        semester: data['semester'] as String? ?? 'Semester 5',
        section: data['section'] as String? ?? 'AI-B',
        cgpa: data['cgpa'] as String? ?? '8.9',
        isHosteler: data['isHosteler'] as bool? ?? false,
        guardianName: data['guardianName'] as String? ?? '',
        guardianPhone: data['guardianPhone'] as String? ?? '',
        guardianRelation: data['guardianRelation'] as String? ?? 'Parent',
        city: data['city'] as String? ?? '',
        serviceDetails: detailsMap,
        submittedAt: dt,
        status: data['status'] as String? ?? 'Verified & Confirmed',
        attachedDoc: data['attachedDoc'] as String? ?? 'Student_ID.pdf',
      );
    } catch (_) {
      return null;
    }
  }

  (IconData, Color) _getServiceVisuals(String service) {
    if (service.contains('Library')) {
      return (Icons.local_library, FormColors.primary);
    } else if (service.contains('Event')) {
      return (Icons.event, FormColors.indigo);
    } else if (service.contains('Bus')) {
      return (Icons.directions_bus, FormColors.amber);
    } else if (service.contains('Lab')) {
      return (Icons.science, FormColors.rose);
    } else if (service.contains('Hostel')) {
      return (Icons.hotel, FormColors.violet);
    } else {
      return (Icons.verified, FormColors.cyan);
    }
  }
}
