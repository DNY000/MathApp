import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_sizes.dart';

class ButtonMath extends StatelessWidget {
  final Color colors;

  final VoidCallback onPressed;
  final String name;
  final double elevation;
  final double height;
  final double width;
  const ButtonMath({
    super.key,
    this.colors = TColors.button,

    required this.onPressed,
    required this.name,
    this.elevation = 0,
    this.height = 56,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: colors,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(TSizes.borderRadius16),
            ),
          ),
          side: BorderSide(color: TColors.borderbrown, width: 1.w),
        ),
        onPressed: onPressed,
        child: Text(
          name,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: TColors.textBack,
          ),
        ),
      ),
    );
  }
}
