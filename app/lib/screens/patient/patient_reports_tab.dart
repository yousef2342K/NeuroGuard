import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class PatientReportsTab extends StatelessWidget {
  const PatientReportsTab({Key? key}) : super(key: key);

  void _generate(BuildContext context) {
    final r = AppState.instance.generateReportForPatient();
    if (ScaffoldMessenger.maybeOf(context) != null)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report generated: ${r['title']}')));
  }

  @override
  Widget build(BuildContext context) {
    final reps = AppState.instance.reports;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Reports', style: Theme.of(context).textTheme.headlineSmall),
          ElevatedButton.icon(
              onPressed: () => _generate(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate')),
        ]),
        const SizedBox(height: 12),
        Expanded(
            child: reps.isEmpty
                ? const Center(child: Text('No reports'))
                : ListView.builder(
                    itemCount: reps.length,
                    itemBuilder: (c, i) {
                      final r = reps[i];
                      return Card(
                          child: ListTile(
                              title: Text(r['title'] ?? ''),
                              subtitle: Text(r['date'] ?? ''),
                              trailing: IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text('Share simulated'))))));
                    })),
      ]),
    );
  }
}
