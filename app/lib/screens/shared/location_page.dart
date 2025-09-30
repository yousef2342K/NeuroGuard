import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final loc = {
      'lat': 30.0444,
      'lng': 31.2357,
      'ts': DateTime.now().toIso8601String()
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Location (simulated)')),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text('Last updated: ${loc['ts']}'),
            const SizedBox(height: 8),
            Text('Lat: ${loc['lat']}  Lng: ${loc['lng']}'),
            const SizedBox(height: 12),
            Container(
                height: 220,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200),
                alignment: Alignment.center,
                child: const Text(
                    'Map placeholder — replace with google_maps_flutter for real maps')),
            const SizedBox(height: 12),
            ElevatedButton.icon(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                            title: const Text('Open Maps (simulated)'),
                            content: Text(
                                'Open maps at ${loc['lat']},${loc['lng']}'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'))
                            ])),
                icon: const Icon(Icons.map),
                label: const Text('Open in Google Maps (simulated)')),
          ])),
    );
  }
}
