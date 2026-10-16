import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}