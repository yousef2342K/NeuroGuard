import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/event_list_tile.dart';

class PatientAlertsTab extends StatelessWidget {
  const PatientAlertsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AppState.instance.events,
      builder: (c, evts, _) {
        if (evts.isEmpty) return const Center(child: Text('No alerts'));
        return ListView.builder(
            itemCount: evts.length,
            itemBuilder: (context, i) => EventListTile(event: evts[i]));
      },
    );
  }
}
