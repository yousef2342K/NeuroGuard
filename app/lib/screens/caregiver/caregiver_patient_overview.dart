import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../services/escalation_mock.dart';
import '../../services/sms_call_mock.dart';
import '../../widgets/event_list_tile.dart';

class CaregiverPatientOverview extends StatelessWidget {
  final String patientId;
  const CaregiverPatientOverview({Key? key, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patient = AppState.instance.users[patientId]!;
    final vit = AppState.instance.vitals.value;
    return Scaffold(
      appBar: AppBar(title: Text('Overview — ${patient['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  subtitle: Text(patient['email']))),
          const SizedBox(height: 8),
          Card(
              child: ListTile(
                  title: const Text('Latest Vitals'),
                  subtitle: Text(
                      'HR: ${vit['heartRate'] ?? '-'} • SpO₂: ${vit['spo2'] ?? '-'} • EEG: ${vit['eeg'] ?? '-'}'))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () async {
                      final events = AppState.instance.events.value;
                      if (events.isNotEmpty) {
                        final id = events.first['id'] as String;
                        await AppState.instance.acknowledgeEvent(
                            id,
                            AppState.instance.currentUser.value?['name'] ??
                                'Caregiver');
                        EscalationMock.cancel(id);
                      }
                      if (ScaffoldMessenger.maybeOf(context) != null)
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Notified others: I\'m on my way (simulated)')));
                    },
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('I\'m on my way'))),
            const SizedBox(width: 8),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () async {
                      await SmsCallMock.call('+201000000000');
                      if (ScaffoldMessenger.maybeOf(context) != null)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Calling patient (simulated)')));
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call Patient'))),
          ]),
          const SizedBox(height: 12),
          const Text('Event history',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: AppState.instance.events,
            builder: (c, evts, _) {
              if (evts.isEmpty) return const Text('No events');
              return ListView.builder(
                  itemCount: evts.length,
                  itemBuilder: (ctx, i) => EventListTile(event: evts[i]));
            },
          )),
        ]),
      ),
    );
  }
}
