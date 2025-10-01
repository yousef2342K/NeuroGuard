import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class ReportsStandalone extends StatelessWidget {
  const ReportsStandalone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final reps = AppState.instance.reports;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: reps.isEmpty
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
              }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            final r = AppState.instance.generateReportForPatient();
            if (ScaffoldMessenger.maybeOf(context) != null)
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Generated: ${r['title']}')));
          },
          child: const Icon(Icons.add)),
    );
  }
}
