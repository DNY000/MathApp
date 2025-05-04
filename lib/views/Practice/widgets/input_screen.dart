import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/division_provider.dart';
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
  late final Animation<double> _animation;
  bool isAnimating = false;
  int currentStars = 0; // Lưu số sao hiện tại trên UI

  void updateStars(int newStarCount) {
    // Sử dụng addPostFrameCallback để đảm bảo setState được gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          currentStars = newStarCount;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween(
      begin: 0.0,
      end: pi,
    ).animate(_controller); // Chỉ lật 180 độ
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
  void didUpdateWidget(Manhinhnhap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset currentStars khi phép tính thay đổi
    if (widget.firstNumber != oldWidget.firstNumber ||
        widget.secondNumber != oldWidget.secondNumber) {
      // Sử dụng addPostFrameCallback để đảm bảo setState được gọi sau khi build hoàn tất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            currentStars = 0;
          });
        }
      });
    }
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
        final angle = _animation.value;
        final transform =
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle); // Lật theo chiều ngang (trục Y)
        return Transform(
          transform: transform,
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
                  isMul
                      ? Consumer<MultiplicationProvider>(
                        builder: (context, provider, child) {
                          bool isSameOperation =
                              provider.currentMultiplication?.number1 ==
                                  widget.firstNumber &&
                              provider.currentMultiplication?.number2 ==
                                  widget.secondNumber;

                          int starCount =
                              (currentStars > 0 && isSameOperation)
                                  ? currentStars
                                  : provider.currentMultiplication?.star ?? 0;

                          return CustomRatingBar(count: starCount);
                        },
                      )
                      : Consumer<DivisionProvider>(
                        builder: (context, provider, child) {
                          bool isSameOperation =
                              provider.currentDivision?.number1 ==
                                  widget.firstNumber &&
                              provider.currentDivision?.number2 ==
                                  widget.secondNumber;

                          int starCount =
                              (currentStars > 0 && isSameOperation)
                                  ? currentStars
                                  : provider.currentDivision?.star ?? 0;

                          return CustomRatingBar(count: starCount);
                        },
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
