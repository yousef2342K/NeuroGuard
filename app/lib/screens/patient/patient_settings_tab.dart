import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class PatientSettingsTab extends StatelessWidget {
  const PatientSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser.value;
    return ListView(padding: const EdgeInsets.all(12), children: [
      ListTile(
          leading: const Icon(Icons.person),
          title: Text(user?['name'] ?? 'Patient'),
          subtitle: Text(user?['email'] ?? '')),
      const Divider(),
      ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Device: NeuroGuard Headband'),
          subtitle: const Text('Device ID: DEV-4321')),
      SwitchListTile(
          title: const Text('Share location with caregiver'),
          value: true,
          onChanged: (_) {}),
      const SizedBox(height: 8),
      ElevatedButton.icon(
          onPressed: () {
            AppState.instance.signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Log out')),
    ]);
  }
}
