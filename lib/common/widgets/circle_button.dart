import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/ultis/colors.dart';

class CircleButton extends StatelessWidget {
  final double height;
  final double width;
  final String image;
  final Color backgroundColor;
  final VoidCallback onPressed;
  const CircleButton({
    super.key,
    required this.height,
    required this.width,
    required this.image,
    required this.onPressed,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height.h,
        width: width.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: TColors.borderbrown),
        ),
        child: Center(child: Image.asset(image, fit: BoxFit.cover)),
      ),
    );
  }
}
