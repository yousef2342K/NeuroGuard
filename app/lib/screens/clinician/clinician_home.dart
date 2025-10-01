import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/app_drawer.dart';
import 'clinician_patient_view.dart';

class ClinicianHome extends StatefulWidget {
  const ClinicianHome({Key? key}) : super(key: key);
  @override
  State<ClinicianHome> createState() => _ClinicianHomeState();
}

class _ClinicianHomeState extends State<ClinicianHome> {
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _patients = AppState.instance.users.values
        .where((u) => u['role'] == 'patient')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinician Dashboard')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text('Assigned Patients',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Expanded(
              child: _patients.isEmpty
                  ? const Center(child: Text('No patients'))
                  : ListView.builder(
                      itemCount: _patients.length,
                      itemBuilder: (c, i) {
                        final p = _patients[i];
                        return Card(
                            child: ListTile(
                          leading: CircleAvatar(
                              child: Text(p['name']
                                  .toString()
                                  .split(' ')
                                  .map((s) => s.isNotEmpty ? s[0] : '')
                                  .take(2)
                                  .join())),
                          title: Text(p['name']),
                          subtitle: Text(p['email']),
                          trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ClinicianPatientView(patient: p)))),
                        ));
                      })),
        ]),
      ),
    );
  }
}
