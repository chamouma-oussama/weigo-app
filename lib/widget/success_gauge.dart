import 'package:flutter/material.dart';
import 'dart:math';

class SuccessGauge extends StatelessWidget {
  final double percent; // النسبة من 0 إلى 100

  const SuccessGauge({required this.percent});

  @override
  Widget build(BuildContext context) {
    // la couleur cadepand le percentage
    Color progressColor = percent >= 75
        ? Colors.green
        : (percent >= 50 ? Colors.orange : Colors.red);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: GaugePainter(
                  percent: percent,
                  color: progressColor,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  "${percent.toInt()}%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  "Chance of success",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// le code qui respo pour designe la curcuilre
class GaugePainter extends CustomPainter {
  final double percent;
  final Color color;

  GaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

// Dessinez le cercle de fond gris
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Tracer un arc de progression coloré
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double arcAngle = 2 * pi * (percent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // البدء من الأعلى
      arcAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
