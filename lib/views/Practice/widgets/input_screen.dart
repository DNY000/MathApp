import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/calculator/calculator_screen.dart';
import 'package:provider/provider.dart';

class Manhinhnhap extends StatefulWidget {
  final bool showRatingBar;
  final int firstNumber;
  final int secondNumber;

  const Manhinhnhap({
    super.key,
    this.showRatingBar = true,
    required this.firstNumber,
    required this.secondNumber,
  });

  @override
  State<Manhinhnhap> createState() => ManhinhnhapState();
}

class ManhinhnhapState extends State<Manhinhnhap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        setState(() {
          isAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startRotationAnimation() {
    setState(() {
      isAnimating = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    bool isMul = settingsProvider.settings.isMultiplication;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * pi,
          alignment: Alignment.center,
          child: Container(
            height: 127.h,
            width: 343.w,
            decoration: BoxDecoration(
              color: TColors.yellow,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Selector<MultiplicationProvider, int>(
                    builder:
                        (context, value, child) =>
                            CustomRatingBar(count: value),
                    selector: (p0, p1) => p1.currentMultiplication!.star,
                    shouldRebuild: (previous, next) => true,
                    // luôn cập nhật khi có thay đổi
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isMul
                          ? Text(
                            '${widget.firstNumber} x ${widget.secondNumber} = ',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : Text(
                            '${widget.firstNumber} : ${widget.secondNumber} = ',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: TColors.borderbrown),
                        ),
                        child: Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: TColors.borderbrown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
