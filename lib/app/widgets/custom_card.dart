import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable card widget with subtle fintech border and soft shadow.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = BorderRadius.circular(borderRadius ?? AppTheme.radiusLg);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: cardBorderRadius,
        border: border ?? Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}
