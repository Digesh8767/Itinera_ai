import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double borderRadius;

  GradientBorderPainter({
    required this.gradient,
    this.strokeWidth = 2.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, 
                     size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
