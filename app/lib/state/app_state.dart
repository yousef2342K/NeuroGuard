import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/notification_mock.dart';
import '../services/escalation_mock.dart';

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

  void initialize() {
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
  }

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final user = users.values.firstWhere(
          (u) => (u['email'] as String).toLowerCase() == email.toLowerCase());
      currentUser.value = Map<String, dynamic>.from(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> signUp(
      String name, String email, String password, String role) async {
    final uid = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final user = {'uid': uid, 'name': name, 'email': email, 'role': role};
    users[uid] = user;
    currentUser.value = Map<String, dynamic>.from(user);
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
    await Future.delayed(const Duration(milliseconds: 200));
    return user;
  }

  void signOut() {
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
