import 'package:flutter/material.dart';
import 'package:math_app/ultis/colors.dart';

class ContainerSetting extends StatelessWidget {
  final Widget child;
  final double height;
  final double radius;
  final EdgeInsets padding;
  const ContainerSetting({
    super.key,
    required this.child,
    required this.height,
    required this.radius,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: TColors.button,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
