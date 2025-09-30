import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/app_drawer.dart';
import '../../services/notification_mock.dart';
import '../../services/escalation_mock.dart';
import 'patient_dashboard_tab.dart';
import 'patient_alerts_tab.dart';
import 'patient_reports_tab.dart';
import 'patient_settings_tab.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    AppState.instance.currentUser.addListener(_onUserChanged);
  }

  void _onUserChanged() => setState(() {});

  @override
  void dispose() {
    AppState.instance.currentUser.removeListener(_onUserChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PatientDashboardTab(),
      const PatientAlertsTab(),
      const PatientReportsTab(),
      const PatientSettingsTab(),
    ];
    final user = AppState.instance.currentUser.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('NeuroGuard — ${user?['name'] ?? 'Patient'}'),
      ),
      drawer: const AppDrawer(),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _triggerEmergency,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.warning),
        label: const Text('Emergency'),
      ),
    );
  }

  void _triggerEmergency() async {
    final ev = {
      'id': 'evt_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'seizure',
      'time': DateTime.now().toIso8601String(),
      'vitals': Map<String, dynamic>.from(AppState.instance.vitals.value),
      'status': 'active',
      'confidence': 0.96,
      'location': {'lat': 30.05, 'lng': 31.23},
      'notes': [],
    };
    await AppState.instance.pushEvent(ev);
    NotificationMock.show(
        'NeuroGuard', 'Emergency triggered by patient (Sara)');
    EscalationMock.schedule(ev, timeoutSeconds: 60);
    if (ScaffoldMessenger.maybeOf(context) != null)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Emergency simulated')));
  }
}
