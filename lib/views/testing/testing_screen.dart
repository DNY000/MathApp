import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/countdown_progress.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/views/testing/test_screen.dart';
import 'package:provider/provider.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  String userAnswer = '';
  List<dynamic> questionsMixed = [];
  int currentQuestionIndex = 0;
  List<AnswerRecord> answerHistory = [];
  bool isProcessing = false;
  bool isTimeUp = false;

  final GlobalKey<CountdownProgressState> _countdownKey = GlobalKey();
  static const int maxAnswerLength = 4;
  static const int totalQuestions = 10;
  int counter = 1;
  @override
  void initState() {
    super.initState();
    _initQuestions();
  }

  void _initQuestions() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final isMul = settingsProvider.settings.isMultiplication;

    setState(() {
      if (isMul) {
        final provider = Provider.of<MultiplicationProvider>(
          context,
          listen: false,
        );
        questionsMixed = provider.get10Answer();
      } else {
        final provider = Provider.of<DivisionProvider>(context, listen: false);
        questionsMixed = provider.get10AnswerDivison();
      }
    });
  }

  void onTimeUp() {
    if (!mounted || isProcessing) return;
    handleAnswer(userAnswer.isEmpty ? '?' : userAnswer);
  }

  void onNumberPress(int number) {
    if (userAnswer.length < maxAnswerLength && !isProcessing && !isTimeUp) {
      setState(() {
        userAnswer += number.toString();
      });
    }
  }

  void onCheckPress() {
    handleAnswer(userAnswer);
    counter++;
  }

  bool isValidQuestionIndex() {
    return currentQuestionIndex >= 0 &&
        currentQuestionIndex < questionsMixed.length;
  }

  void handleAnswer(String answer) {
    if (questionsMixed.isEmpty || !isValidQuestionIndex() || isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    final currentQuestion = questionsMixed[currentQuestionIndex];
    final int userResult = int.tryParse(answer) ?? 0;
    late int correctResult;
    late int number1;
    late int number2;

    if (currentQuestion is Multiplication) {
      correctResult = currentQuestion.result;
      number1 = currentQuestion.number1;
      number2 = currentQuestion.number2;
    } else if (currentQuestion is Division) {
      correctResult = currentQuestion.result;
      number1 = currentQuestion.number1;
      number2 = currentQuestion.number2;
    } else {
      return;
    }

    final bool isCorrect = userResult == correctResult;

    answerHistory.add(
      AnswerRecord(
        number1: number1,
        number2: number2,
        result: correctResult,
        selectedAnswer: userResult,
        isCorrect: isCorrect,
        start: 0,
      ),
    );
    // final currentHistory = List<AnswerRecord>.from(answerHistory);
    //currentQuestionIndex >= totalQuestions
    if (counter >= 9) {
      final correctCount = answerHistory.where((a) => a.isCorrect).length;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CompleteScreen(
                correctAnswers: correctCount,
                wrongAnswers: totalQuestions - correctCount,
                totalQuestions: totalQuestions,
                answerHistory: answerHistory,
                isTesting: true,
              ),
        ),
      );
    } else {
      setState(() {
        currentQuestionIndex++;
        userAnswer = '';
        isProcessing = false;
        isTimeUp = false;
      });
      _countdownKey.currentState?.resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool checkResult = settingsProvider.settings.resultRange.end > 100;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        print('danh sách phép chia : ${questionsMixed}');
        if (questionsMixed.isEmpty || !isValidQuestionIndex()) {
          return Scaffold(body: Center(child: Text('Không có câu hỏi')));
        }

        final currentQuestion = questionsMixed[currentQuestionIndex];

        String questionText;
        if (currentQuestion is Multiplication) {
          questionText =
              '${currentQuestion.number1} × ${currentQuestion.number2} = ';
        } else if (currentQuestion is Division) {
          questionText =
              '${currentQuestion.number1} ÷ ${currentQuestion.number2} = ';
        } else {
          questionText = '?';
        }

        return Scaffold(
          appBar: TAppbar(
            name: 'Kiểm tra (${currentQuestionIndex + 1}/$totalQuestions)',
            showBack: true,
          ),
          body: Column(
            children: [
              CountdownProgress(
                key: _countdownKey,
                durationInSeconds: 15,
                height: 8.h,
                onComplete: onTimeUp,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  children: [
                    Container(
                      height: 127.h,
                      width: 343.w,
                      decoration: BoxDecoration(
                        color: TColors.yellow,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              questionText,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 46.h,
                              width: checkResult ? 68.w : 46.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: TColors.borderbrown),
                              ),
                              child: Center(
                                child: Text(
                                  userAnswer.isEmpty ? '?' : userAnswer,
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
                      ),
                    ),
                    SizedBox(height: 104.h),
                    BanPhim(
                      onNumberPress: onNumberPress,
                      onCancelPress: () {
                        if (!isProcessing && userAnswer.isNotEmpty) {
                          setState(() {
                            userAnswer = userAnswer.substring(
                              0,
                              userAnswer.length - 1,
                            );
                          });
                        }
                      },
                      onCheckPress: onCheckPress,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
