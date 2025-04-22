import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/views/testing/test_screen.dart';
import 'package:math_app/ultis/colors.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  String userAnswer = '';
  final int firstNumber = 7;
  final int secondNumber = 4;
  bool isCorrect = false;
  bool showResult = false;

  void onNumberPress(int number) {
    if (userAnswer.length < 3) {
      setState(() {
        userAnswer += number.toString();
      });
    }
  }

  void onCancelPress() {
    setState(() {
      if (userAnswer.isNotEmpty) {
        userAnswer = userAnswer.substring(0, userAnswer.length - 1);
      }
    });
  }

  void onCheckPress() {
    if (userAnswer.isNotEmpty) {
      setState(() {
        isCorrect = int.parse(userAnswer) == firstNumber * secondNumber;
        showResult = true;
      });

      // Hiển thị kết quả trong 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showResult = false;
            if (isCorrect) {
              userAnswer = '';
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(name: 'Kiểm tra', showBack: true),
      body: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 46.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 127.h,
              width: 343.w,
              decoration: BoxDecoration(
                color: TColors.yellow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$firstNumber x $secondNumber = ',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          height: 40.h,
                          width: 86.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border:
                                showResult
                                    ? Border.all(
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                      width: 2.w,
                                    )
                                    : null,
                          ),
                          child: Center(
                            child: Text(
                              userAnswer.isEmpty ? '?' : userAnswer,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    showResult
                                        ? (isCorrect
                                            ? Colors.green
                                            : Colors.red)
                                        : Colors.black,
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
            SizedBox(height: 104.h),
            BanPhim(
              onNumberPress: onNumberPress,
              onCancelPress: onCancelPress,
              onCheckPress: onCheckPress,
            ),
          ],
        ),
      ),
    );
  }
}
