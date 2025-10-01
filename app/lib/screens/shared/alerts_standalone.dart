import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/event_list_tile.dart';

class AlertsStandalone extends StatelessWidget {
  const AlertsStandalone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Alerts')), body: const AlertsList());
  }
}

class AlertsList extends StatelessWidget {
  const AlertsList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AppState.instance.events,
      builder: (context, evts, _) {
        if (evts.isEmpty) return const Center(child: Text('No alerts'));
        return ListView.builder(
            itemCount: evts.length,
            itemBuilder: (c, i) => EventListTile(event: evts[i]));
      },
    );
  }
}
