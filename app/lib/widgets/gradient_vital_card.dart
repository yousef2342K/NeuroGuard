import 'package:flutter/material.dart';

class GradientVitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final LinearGradient gradient;
  const GradientVitalCard(
      {Key? key,
      required this.title,
      required this.value,
      required this.subtitle,
      required this.gradient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: gradient.colors.last.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }
}
