import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_mock.dart';
import '../services/escalation_mock.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_management_service.dart';

class AppState {
  AppState._internal();
  static final AppState instance = AppState._internal();

  final ValueNotifier<Map<String, dynamic>?> currentUser =
      ValueNotifier<Map<String, dynamic>?>(null);

  final ValueNotifier<Map<String, dynamic>> vitals =
      ValueNotifier<Map<String, dynamic>>({});

  final ValueNotifier<List<Map<String, dynamic>>> events =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final List<Map<String, dynamic>> reports = [];

  final Map<String, Map<String, dynamic>> users = {};

  final Random _rnd = Random();
  Timer? _telemetryTimer;

  // Firebase services
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserManagementService _userService = UserManagementService();
  
  // Auth state stream subscription
  StreamSubscription<User?>? _authSubscription;

  void initialize() {
    // Initialize demo users for testing
    users['pt_sara'] = {
      'uid': 'pt_sara',
      'name': 'Sara Abdallah',
      'email': 'sara@example.com',
      'role': 'patient'
    };
    users['cg_mona'] = {
      'uid': 'cg_mona',
      'name': 'Mona Ahmed',
      'email': 'mona@example.com',
      'role': 'caregiver',
      'patients': ['pt_sara']
    };
    users['cl_ali'] = {
      'uid': 'cl_ali',
      'name': 'Dr. Ali Hassan',
      'email': 'dr.ali@clinic.com',
      'role': 'clinician',
      'patients': ['pt_sara']
    };
    users['ad_admin'] = {
      'uid': 'ad_admin',
      'name': 'Admin',
      'email': 'admin@neuroguard.com',
      'role': 'admin'
    };

    // Listen to Firebase auth state changes
    _authSubscription = _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Get user data from Firestore
        try {
          final userData = await _authService.getUserData(user.uid);
          if (userData != null) {
            currentUser.value = userData;
          }
        } catch (e) {
          print('Error getting user data: $e');
          currentUser.value = null;
        }
      } else {
        currentUser.value = null;
      }
    });

    vitals.value = {
      'eeg': 'normal',
      'heartRate': 74,
      'spo2': 97,
      'motion': 'stable',
      'score': 0.03,
      'history_hr': List.generate(30, (_) => 60 + _rnd.nextInt(50)),
      'history_spo2': List.generate(30, (_) => 90 + _rnd.nextInt(8)),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    events.value = [
      {
        'id': 'evt_seed_1',
        'type': 'seizure',
        'time':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'vitals': {'heartRate': 118, 'spo2': 88, 'eeg': 'abnormal'},
        'status': 'resolved',
        'confidence': 0.95,
        'location': {'lat': 30.0444, 'lng': 31.2357},
        'notes': [
          {
            'by': 'Dr. Ali',
            'text': 'Confirmed seizure',
            'ts': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String()
          }
        ],
      }
    ];

    reports.add({
      'id': 'rep_1',
      'title': 'Weekly Summary - Sara',
      'date': DateTime.now().toIso8601String(),
      'summary': '1 seizure in last week. Avg HR: 90, Avg SpO₂: 95',
    });

    _telemetryTimer?.cancel();
    _telemetryTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _emitTelemetry());
  }

  void dispose() {
    _telemetryTimer?.cancel();
    _authSubscription?.cancel();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final userData = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userData != null) {
        currentUser.value = userData;
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> signUp(
      String name, String email, String password, String role) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        throw Exception('يرجى إدخال الاسم الكامل');
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        throw Exception('يرجى إدخال بريد إلكتروني صحيح');
      }
      if (password.length < 6) {
        throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }
      
      final userData = await _authService.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      
      if (userData != null) {
        currentUser.value = userData;
        
        // Initialize patient data if role is patient
        if (role == 'patient') {
          vitals.value = {
            'eeg': 'normal',
            'heartRate': 72,
            'spo2': 97,
            'motion': 'stable',
            'score': 0.02,
            'history_hr': List.generate(30, (_) => 60 + _rnd.nextInt(40)),
            'history_spo2': List.generate(30, (_) => 90 + _rnd.nextInt(6)),
            'lastUpdated': DateTime.now().toIso8601String(),
          };
          events.value = [];
        }
        
        return userData;
      }
      throw Exception('فشل في إنشاء الحساب');
    } catch (e) {
      print('Sign up error: $e');
      // Return a more user-friendly error message
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('هذا البريد الإلكتروني مستخدم بالفعل');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('كلمة المرور ضعيفة جداً');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('البريد الإلكتروني غير صحيح');
      } else {
        throw Exception('حدث خطأ في إنشاء الحساب: ${e.toString()}');
      }
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase first
      await _authService.signOut();
      
      // Clear user data
      currentUser.value = null;
      
      // Reset vitals to default
      vitals.value = {
        'eeg': 'normal',
        'heartRate': 74,
        'spo2': 97,
        'motion': 'stable',
        'score': 0.03,
        'history_hr': List.generate(30, (_) => 60 + _rnd.nextInt(50)),
        'history_spo2': List.generate(30, (_) => 90 + _rnd.nextInt(8)),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Clear events
      events.value = [];
      
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      // Force clear user data even if Firebase signout fails
      currentUser.value = null;
      vitals.value = {
        'eeg': 'normal',
        'heartRate': 74,
        'spo2': 97,
        'motion': 'stable',
        'score': 0.03,
        'history_hr': List.generate(30, (_) => 60 + _rnd.nextInt(50)),
        'history_spo2': List.generate(30, (_) => 90 + _rnd.nextInt(8)),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      events.value = [];
    }
  }

  Future<void> pushEvent(Map<String, dynamic> event) async {
    final list = [event, ...events.value];
    events.value = list;
  }

  Future<void> acknowledgeEvent(String id, String by) async {
    final updated = events.value.map((e) {
      if (e['id'] == id) {
        final copy = Map<String, dynamic>.from(e);
        copy['status'] = 'acknowledged';
        copy['ackBy'] = by;
        return copy;
      }
      return e;
    }).toList();
    events.value = updated;
  }

  void addNoteToEvent(String eventId, String doctorName, String note) {
    final updated = events.value.map((e) {
      if (e['id'] == eventId) {
        final copy = Map<String, dynamic>.from(e);
        final notes = List<Map<String, dynamic>>.from(copy['notes'] ?? []);
        notes.add({
          'by': doctorName,
          'text': note,
          'ts': DateTime.now().toIso8601String()
        });
        copy['notes'] = notes;
        return copy;
      }
      return e;
    }).toList();
    events.value = updated;
  }

  Map<String, dynamic> generateReportForPatient() {
    final now = DateTime.now();
    final r = {
      'id': 'rep_${now.millisecondsSinceEpoch}',
      'title': 'Auto Report ${now.toIso8601String().split("T").first}',
      'date': now.toIso8601String(),
      'summary': 'Auto-generated report for demo patient (Sara).',
      'data': {
        'hr': List<int>.from(vitals.value['history_hr'] ??
            List<int>.generate(20, (i) => 60 + _rnd.nextInt(40))),
        'spo2': List<int>.from(vitals.value['history_spo2'] ??
            List<int>.generate(20, (i) => 90 + _rnd.nextInt(6))),
      }
    };
    reports.insert(0, r);
    return r;
  }

  void _emitTelemetry() {
    final cur = Map<String, dynamic>.from(vitals.value);
    cur['heartRate'] = max(45, (cur['heartRate'] as int) + _rnd.nextInt(7) - 3);
    cur['spo2'] = max(80, (cur['spo2'] as int) + _rnd.nextInt(3) - 1);
    if (_rnd.nextDouble() > 0.992) cur['eeg'] = 'abnormal';
    final hrHistory = List<int>.from(cur['history_hr'] ?? []);
    hrHistory.add(cur['heartRate'] as int);
    if (hrHistory.length > 60) hrHistory.removeAt(0);
    cur['history_hr'] = hrHistory;
    final spo2History = List<int>.from(cur['history_spo2'] ?? []);
    spo2History.add(cur['spo2'] as int);
    if (spo2History.length > 60) spo2History.removeAt(0);
    cur['history_spo2'] = spo2History;
    cur['score'] = double.parse((_rnd.nextDouble() * 0.4).toStringAsFixed(2));
    cur['lastUpdated'] = DateTime.now().toIso8601String();
    vitals.value = cur;

    if (cur['eeg'] == 'abnormal') {
      final conf = _rnd.nextDouble();
      if (conf > 0.9) {
        final ev = {
          'id': 'evt_${DateTime.now().millisecondsSinceEpoch}',
          'type': 'seizure',
          'time': DateTime.now().toIso8601String(),
          'vitals': {
            'heartRate': cur['heartRate'],
            'spo2': cur['spo2'],
            'eeg': cur['eeg']
          },
          'status': 'active',
          'confidence': conf,
          'location': {
            'lat': 30.0444 + _rnd.nextDouble() * 0.01,
            'lng': 31.2357 + _rnd.nextDouble() * 0.01
          },
          'notes': [],
        };
        pushEvent(ev);
        NotificationMock.show(
            'NeuroGuard', 'Seizure suspected for Sara (simulated)');
        EscalationMock.schedule(ev, timeoutSeconds: 60);
      }
    }
  }
}
