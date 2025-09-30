import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/add_note_dialog.dart';

class ClinicianPatientView extends StatefulWidget {
  final Map<String, dynamic> patient;
  const ClinicianPatientView({Key? key, required this.patient})
      : super(key: key);
  @override
  State<ClinicianPatientView> createState() => _ClinicianPatientViewState();
}

class _ClinicianPatientViewState extends State<ClinicianPatientView> {
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic> _vitals = {};

  @override
  void initState() {
    super.initState();
    _events = AppState.instance.events.value;
    _vitals = AppState.instance.vitals.value;
    AppState.instance.events.addListener(_ev);
    AppState.instance.vitals.addListener(_vt);
  }

  void _ev() => setState(() => _events = AppState.instance.events.value);
  void _vt() => setState(() => _vitals = AppState.instance.vitals.value);

  @override
  void dispose() {
    AppState.instance.events.removeListener(_ev);
    AppState.instance.vitals.removeListener(_vt);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.patient['name'] ?? 'Patient';
    return Scaffold(
      appBar: AppBar(title: Text('Patient: $name')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Card(
              child: ListTile(
                  title: const Text('Live Vitals'),
                  subtitle: Text(
                      'HR: ${_vitals['heartRate'] ?? '-'} • SpO₂: ${_vitals['spo2'] ?? '-'} • EEG: ${_vitals['eeg'] ?? '-'}'))),
          const SizedBox(height: 8),
          Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text('No events'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (c, i) {
                        final e = _events[i];
                        return Card(
                            child: ListTile(
                          title: Text(
                              '${e['type']} — ${((e['confidence'] ?? 0.0) as double).toStringAsFixed(2)}'),
                          subtitle: Text(
                              'Time: ${e['time']}\nHR:${e['vitals']?['heartRate'] ?? '-'} SpO₂:${e['vitals']?['spo2'] ?? '-'}'),
                          trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'tp') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Marked as True Positive (simulated)')));
                                } else if (v == 'fp') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Marked as False Positive (simulated)')));
                                } else if (v == 'note') {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AddNoteDialog(
                                          eventId: e['id'] as String));
                                }
                              },
                              itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'tp',
                                        child: Text('True Positive')),
                                    PopupMenuItem(
                                        value: 'fp',
                                        child: Text('False Positive')),
                                    PopupMenuItem(
                                        value: 'note', child: Text('Add note')),
                                  ]),
                        ));
                      })),
        ]),
      ),
    );
  }
}
