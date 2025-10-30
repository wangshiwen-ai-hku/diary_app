import 'package:flutter/material.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 20,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGlowColor = glowColor ?? theme.colorScheme.primary;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.15),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: effectiveBorderRadius,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
