import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/app_drawer.dart';
import '../../services/escalation_mock.dart';
import 'caregiver_patient_overview.dart';

class CaregiverHome extends StatefulWidget {
  const CaregiverHome({Key? key}) : super(key: key);
  @override
  State<CaregiverHome> createState() => _CaregiverHomeState();
}

class _CaregiverHomeState extends State<CaregiverHome> {
  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser.value;
    final patients =
        (user?['patients'] as List<dynamic>?)?.cast<String>() ?? ['pt_sara'];
    final patient = AppState.instance.users['pt_sara']!;
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Following', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
              child: ListTile(
            leading: CircleAvatar(
                child: Text(patient['name']
                    .toString()
                    .split(' ')
                    .map((s) => s.isNotEmpty ? s[0] : '')
                    .take(2)
                    .join())),
            title: Text(patient['name']),
            subtitle: const Text('Tap to view latest alerts'),
            trailing: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CaregiverPatientOverview(patientId: 'pt_sara'))),
                child: const Text('Open')),
          )),
          const SizedBox(height: 12),
          const Text('Active Alerts',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: AppState.instance.events,
            builder: (c, evts, _) {
              final active =
                  evts.where((e) => e['status'] == 'active').toList();
              if (active.isEmpty)
                return const Center(child: Text('No active alerts'));
              return ListView.builder(
                  itemCount: active.length,
                  itemBuilder: (ctx, i) {
                    final e = active[i];
                    return Card(
                        child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                          '${e['type']} • ${((e['confidence'] ?? 0.0) as double).toStringAsFixed(2)}'),
                      subtitle: Text(
                          'Time: ${e['time']}\nHR:${e['vitals']?['heartRate'] ?? '-'} SpO₂:${e['vitals']?['spo2'] ?? '-'}'),
                      trailing: ElevatedButton(
                          onPressed: () async {
                            await AppState.instance.acknowledgeEvent(
                                e['id'] as String,
                                user?['name'] ?? 'Caregiver');
                            EscalationMock.cancel(e['id'] as String);
                            if (ScaffoldMessenger.maybeOf(context) != null)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Acknowledged')));
                          },
                          child: const Text('Acknowledge')),
                    ));
                  });
            },
          )),
        ]),
      ),
    );
  }
}
