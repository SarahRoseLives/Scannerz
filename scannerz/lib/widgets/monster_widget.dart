import 'package:flutter/material.dart';
import '../models/monster_dna.dart';
import 'dart:math';

class MonsterWidget extends StatelessWidget {
  final MonsterDNA dna;
  final double size;

  const MonsterWidget({
    Key? key,
    required this.dna,
    this.size = 150,
  }) : super(key: key);

  Color getBodyColor() {
    final hex = dna.color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MonsterPainter(dna, getBodyColor()),
    );
  }
}

class _MonsterPainter extends CustomPainter {
  final MonsterDNA dna;
  final Color bodyColor;

  _MonsterPainter(this.dna, this.bodyColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);
    final bodyPaint = Paint()..color = bodyColor;

    // Draw body
    switch (dna.bodyType) {
      case 'tall':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: size.width*0.5, height: size.height*0.8),
              Radius.circular(size.width*0.25)),
          bodyPaint);
        break;
      case 'square':
        canvas.drawRect(
          Rect.fromCenter(center: center, width: size.width*0.7, height: size.height*0.7),
          bodyPaint);
        break;
      case 'blob':
        canvas.drawOval(
          Rect.fromCenter(center: center, width: size.width*0.7, height: size.height*0.6),
          bodyPaint);
        break;
      case 'round':
      default:
        canvas.drawCircle(center, size.width*0.35, bodyPaint);
    }

    // Draw eyes
    double eyeY = size.height * 0.45;
    int eyeCount = dna.eyes.clamp(1, 4);
    for (int i = 0; i < eyeCount; i++) {
      double frac = (eyeCount == 1) ? 0.5 : i / (eyeCount - 1);
      double eyeX = size.width * 0.28 + frac * size.width * 0.44;
      canvas.drawCircle(
        Offset(eyeX, eyeY),
        size.width * 0.06,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(eyeX, eyeY),
        size.width * 0.025,
        Paint()..color = Colors.black,
      );
    }

    // Draw mouth
    switch (dna.mouthType) {
      case 'grin':
        canvas.drawArc(
          Rect.fromCenter(center: Offset(size.width/2, size.height*0.65), width: size.width*0.25, height: size.height*0.10),
          0, pi, false, Paint()..color=Colors.black..strokeWidth=3..style=PaintingStyle.stroke);
        break;
      case 'smile':
        canvas.drawArc(
          Rect.fromCenter(center: Offset(size.width/2, size.height*0.62), width: size.width*0.22, height: size.height*0.13),
          0, pi, false, Paint()..color=Colors.black..strokeWidth=2..style=PaintingStyle.stroke);
        break;
      case 'frown':
        canvas.drawArc(
          Rect.fromCenter(center: Offset(size.width/2, size.height*0.68), width: size.width*0.22, height: size.height*0.13),
          pi, pi, false, Paint()..color=Colors.black..strokeWidth=2..style=PaintingStyle.stroke);
        break;
      case 'o':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width/2, size.height*0.65), width: size.width*0.06, height: size.height*0.07),
          Paint()..color=Colors.black,
        );
        break;
    }

    // Draw decorations
    for (String deco in dna.decorations) {
      if (deco == 'horns') {
        // Two horns above body
        final hornPaint = Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(size.width * 0.35, size.height * 0.27),
          Offset(size.width * 0.27, size.height * 0.10),
          hornPaint,
        );
        canvas.drawLine(
          Offset(size.width * 0.65, size.height * 0.27),
          Offset(size.width * 0.73, size.height * 0.10),
          hornPaint,
        );
      }
      if (deco == 'antenna') {
        final antPaint = Paint()
          ..color = Colors.pink
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(size.width * 0.50, size.height * 0.27),
          Offset(size.width * 0.50, size.height * 0.06),
          antPaint,
        );
        canvas.drawCircle(
          Offset(size.width * 0.50, size.height * 0.03),
          size.width * 0.025,
          Paint()..color=Colors.yellow
        );
      }
      if (deco == 'spikes') {
        final spikePaint = Paint()
          ..color = Colors.deepPurple
          ..strokeWidth = 4;
        for (double i = 0.30; i <= 0.70; i += 0.13) {
          canvas.drawLine(
            Offset(size.width * i, size.height * 0.83),
            Offset(size.width * i, size.height * 0.95),
            spikePaint,
          );
        }
      }
      if (deco == 'frill') {
        final frillPaint = Paint()
          ..color = Colors.orange
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(size.width/2, size.height*0.82), width: size.width*0.42, height: size.height*0.17),
          pi, pi, false, frillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}