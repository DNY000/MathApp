import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/testing/test_screen.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/ultis/colors.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  String userAnswer = '';
  int firstNumber = 7;
  int secondNumber = 4;
  bool isCorrect = false;
  bool showResult = false;

  // Thêm biến đếm và lưu kết quả
  int questionCount = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  List<Map<String, dynamic>> answerHistory = [];

  // Tạo câu hỏi mới
  void generateNewQuestion() {
    setState(() {
      firstNumber = 1 + (DateTime.now().millisecondsSinceEpoch % 9);
      secondNumber = 1 + (DateTime.now().microsecondsSinceEpoch % 9);
      userAnswer = '';
      showResult = false;
    });
  }

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
      final int correctResult = firstNumber * secondNumber;
      final int userResult = int.parse(userAnswer);

      setState(() {
        isCorrect = userResult == correctResult;
        showResult = true;
        questionCount++;

        // Cập nhật số câu đúng/sai
        if (isCorrect) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }

        // Lưu lịch sử câu trả lời
        answerHistory.add({
          'question': '$firstNumber x $secondNumber = ',
          'correctAnswer': correctResult,
          'userAnswer': userResult,
          'isCorrect': isCorrect,
        });
      });

      // Hiển thị kết quả trong 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          if (questionCount >= 10) {
            // Chuyển đến màn hình complete khi đủ 10 câu
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CompleteScreen(
                      correctAnswers: correctAnswers,
                      wrongAnswers: wrongAnswers,
                      totalQuestions: 10,
                      stars:
                          (correctAnswers * 3) ~/
                          10, // Tính số sao dựa vào số câu đúng
                    ),
              ),
            );
          } else {
            // Tạo câu hỏi mới
            generateNewQuestion();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = SettingsProvider();
    bool isMul = settings.settings.isMultiplication;
    return Scaffold(
      appBar: TAppbar(
        name: 'Kiểm tra (${questionCount + 1}/10)',
        showBack: true,
      ),
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
