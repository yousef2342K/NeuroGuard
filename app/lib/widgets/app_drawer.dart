import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../screens/auth_screen.dart';
import '../screens/patient/patient_home.dart';
import '../screens/caregiver/caregiver_home.dart';
import '../screens/clinician/clinician_home.dart';
import '../screens/admin/admin_home.dart';
import '../screens/shared/alerts_standalone.dart';
import '../screens/shared/reports_standalone.dart';
import '../screens/shared/location_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser.value;
    final role = user?['role'] ?? 'guest';
    return Drawer(
      child: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            child: Row(children: [
              CircleAvatar(
                  radius: 28,
                  child: Text(user?['name']
                          ?.toString()
                          .split(' ')
                          .map((s) => s.isNotEmpty ? s[0] : '')
                          .take(2)
                          .join() ??
                      'U')),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(user?['name'] ?? 'Guest',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(user?['email'] ?? '',
                        style: const TextStyle(color: Colors.white70)),
                    Text('Role: $role',
                        style: const TextStyle(color: Colors.white70)),
                  ])),
            ]),
          ),
          ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  final role = AppState.instance.currentUser.value?['role'];
                  if (role == 'patient') return const PatientHome();
                  if (role == 'clinician') return const ClinicianHome();
                  if (role == 'caregiver') return const CaregiverHome();
                  return const AdminHome();
                }));
              }),
          ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alerts'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsStandalone()))),
          ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Reports'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReportsStandalone()))),
          ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Location (simulated)'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LocationPage()))),
          const Spacer(),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                AppState.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) =>
                            const AuthScreen(onToggleTheme: _nullToggle)),
                    (r) => false);
              }),
        ]),
      ),
    );
  }
}

void _nullToggle() {}
