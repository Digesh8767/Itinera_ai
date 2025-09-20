import 'package:flutter/material.dart';

class GradientBorder extends StatelessWidget {
  final Widget child;
  final double width;
  final Gradient gradient;
  final double borderRadius;

  const GradientBorder({
    super.key,
    required this.child,
    this.width = 2.0,
    required this.gradient,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(width),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius - width),
        ),
        child: child,
      ),
    );
  }
}
