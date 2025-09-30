import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/gradient_vital_card.dart';
import '../../widgets/mini_trends.dart';
import '../../widgets/event_list_tile.dart';

class PatientDashboardTab extends StatefulWidget {
  const PatientDashboardTab({Key? key}) : super(key: key);
  @override
  State<PatientDashboardTab> createState() => _PatientDashboardTabState();
}

class _PatientDashboardTabState extends State<PatientDashboardTab> {
  Map<String, dynamic> _v = {};

  @override
  void initState() {
    super.initState();
    _v = AppState.instance.vitals.value;
    AppState.instance.vitals.addListener(_onV);
  }

  void _onV() => setState(() => _v = AppState.instance.vitals.value);

  @override
  void dispose() {
    AppState.instance.vitals.removeListener(_onV);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hr = _v['heartRate']?.toString() ?? '--';
    final spo2 = _v['spo2']?.toString() ?? '--';
    final eeg = _v['eeg']?.toString() ?? 'unknown';
    final motion = _v['motion']?.toString() ?? 'stable';
    final score = (_v['score'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final lastUpdated = _v['lastUpdated'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: GradientVitalCard(
                  title: 'Heart Rate',
                  value: '$hr bpm',
                  subtitle: 'Real-time',
                  gradient: _greenGradient(context))),
          const SizedBox(width: 10),
          Expanded(
              child: GradientVitalCard(
                  title: 'SpO₂',
                  value: '$spo2 %',
                  subtitle: 'Oxygen saturation',
                  gradient: _blueGradient(context))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: GradientVitalCard(
                  title: 'EEG',
                  value: '$eeg',
                  subtitle: 'Brain activity',
                  gradient: eeg == 'abnormal'
                      ? _warningGradient(context)
                      : _greenGradient(context))),
          const SizedBox(width: 10),
          Expanded(
              child: GradientVitalCard(
                  title: 'Motion',
                  value: motion,
                  subtitle: 'Movement',
                  gradient: motion == 'fall'
                      ? _dangerGradient(context)
                      : _greenGradient(context))),
        ]),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Prediction score',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(score,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Last updated: $lastUpdated'),
                  ])),
              SizedBox(
                  width: 140,
                  child: MiniTrends(
                      hrSeries: List<int>.from(_v['history_hr'] ?? []),
                      spo2Series: List<int>.from(_v['history_spo2'] ?? []))),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Recent Events',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: AppState.instance.events,
          builder: (context, evts, _) {
            if (evts.isEmpty) return const Text('No events yet');
            return Column(
                children: evts.map((e) => EventListTile(event: e)).toList());
          },
        ),
      ]),
    );
  }

  LinearGradient _greenGradient(BuildContext c) => LinearGradient(colors: [
        Theme.of(c).colorScheme.primary,
        Theme.of(c).colorScheme.primary.withOpacity(0.7)
      ]);
  LinearGradient _blueGradient(BuildContext c) =>
      LinearGradient(colors: [Colors.blue.shade700, Colors.blueAccent]);
  LinearGradient _warningGradient(BuildContext c) =>
      LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
  LinearGradient _dangerGradient(BuildContext c) =>
      LinearGradient(colors: [Colors.red.shade700, Colors.redAccent]);
}
