import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/escalation_mock.dart';
import 'add_note_dialog.dart';

class EventListTile extends StatelessWidget {
  final Map<String, dynamic> event;
  const EventListTile({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = event['status'] as String? ?? 'active';
    final color = status == 'active'
        ? Colors.red
        : (status == 'acknowledged' ? Colors.orange : Colors.grey);
    final conf = ((event['confidence'] ?? 0.0) as double).toStringAsFixed(2);
    final time = event['time']?.toString() ?? '';
    final vitals = event['vitals'] ?? {};
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(
                event['type'] == 'seizure'
                    ? Icons.health_and_safety
                    : Icons.info,
                color: Colors.white)),
        title: Text(
            '${(event['type'] ?? 'event').toString().toUpperCase()} — $conf'),
        subtitle: Text(
            'Time: $time\nHR: ${vitals['heartRate'] ?? '-'}  SpO₂: ${vitals['spo2'] ?? '-'}',
            maxLines: 3),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'ack') {
              await AppState.instance.acknowledgeEvent(event['id'] as String,
                  AppState.instance.currentUser.value?['name'] ?? 'user');
              EscalationMock.cancel(event['id'] as String);
              if (ScaffoldMessenger.maybeOf(context) != null)
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Acknowledged')));
            } else if (value == 'note') {
              showDialog(
                  context: context,
                  builder: (_) =>
                      AddNoteDialog(eventId: event['id'] as String));
            } else if (value == 'nav') {
              final loc = event['location'];
              if (loc != null) {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                            title: const Text('Open Maps (simulated)'),
                            content: Text('Open ${loc['lat']}, ${loc['lng']}'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'))
                            ]));
              } else {
                if (ScaffoldMessenger.maybeOf(context) != null)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No location data')));
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'ack', child: Text('Acknowledge')),
            PopupMenuItem(value: 'note', child: Text('Add note')),
            PopupMenuItem(value: 'nav', child: Text('Open in Maps')),
          ],
        ),
      ),
    );
  }
}
