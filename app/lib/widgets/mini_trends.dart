import 'dart:math';
import 'package:flutter/material.dart';

class MiniTrends extends StatelessWidget {
  final List<int> hrSeries;
  final List<int> spo2Series;
  const MiniTrends({Key? key, required this.hrSeries, required this.spo2Series})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 60,
          child: Padding(
              padding: const EdgeInsets.all(6),
              child: Sparkline(values: hrSeries, strokeWidth: 2))),
      SizedBox(
          height: 60,
          child: Padding(
              padding: const EdgeInsets.all(6),
              child: Sparkline(
                  values: spo2Series,
                  color: Colors.yellow.shade700,
                  strokeWidth: 2))),
    ]);
  }
}

class Sparkline extends StatelessWidget {
  final List<int> values;
  final Color? color;
  final double strokeWidth;
  const Sparkline(
      {Key? key, required this.values, this.color, this.strokeWidth = 2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: Size.infinite,
        painter: SparklinePainter(
            values: values,
            color: color ?? Theme.of(context).colorScheme.onPrimary,
            strokeWidth: strokeWidth));
  }
}

class SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;
  final double strokeWidth;
  SparklinePainter(
      {required this.values, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (values.isEmpty) return;
    final minVal = values.reduce(min).toDouble();
    final maxVal = values.reduce(max).toDouble();
    final span = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final step = size.width / (values.length - 1).clamp(1, double.infinity);
    Path p = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - ((values[i] - minVal) / span) * size.height;
      if (i == 0)
        p.moveTo(x, y);
      else
        p.lineTo(x, y);
    }
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter old) =>
      old.values != values || old.color != color;
}
