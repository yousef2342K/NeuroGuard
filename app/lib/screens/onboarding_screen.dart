import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _idx = 0;
  final List<Map<String, String>> pages = [
    {
      'title': 'Monitor brain & heart signals',
      'subtitle': 'Continuous EEG, heart-rate and SpO₂ monitoring.'
    },
    {
      'title': 'Get seizure alerts in real-time',
      'subtitle': 'Instant notifications and escalation to caregivers.'
    },
    {
      'title': 'Share reports with doctors',
      'subtitle': 'Auto reports for clinician review and notes.'
    },
  ];

  void _skip() => widget.onFinish();
  void _next() {
    if (_idx == pages.length - 1)
      widget.onFinish();
    else
      _pc.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to NeuroGuard'),
        actions: [
          TextButton(
              onPressed: _skip,
              child: const Text('Skip', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pc,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (c, i) {
              final p = pages[i];
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.9),
                                color.withOpacity(0.5)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Icon(Icons.health_and_safety,
                            size: 96, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(p['title']!,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(p['subtitle']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                    ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
                children: List.generate(
                    pages.length,
                    (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _idx == i ? 26 : 10,
                        height: 8,
                        decoration: BoxDecoration(
                            color: _idx == i ? color : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(8))))),
            ElevatedButton(
                onPressed: _next,
                child: Text(_idx == pages.length - 1 ? 'Get Started' : 'Next')),
          ]),
        )
      ]),
    );
  }
}
