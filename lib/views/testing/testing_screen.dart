import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/countdown_progress.dart';
import 'package:math_app/common/widgets/t_appbar.dart';

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
  List<Map<String, dynamic>> _questions = [];
  int currentQuestionIndex = 0;
  List<AnswerRecord> answerHistory = [];
  bool isProcessing = false;
  bool showResult = false;
  bool isTimeUp = false;
  bool isLoading = true;
  final GlobalKey<CountdownProgressState> _countdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initQuestions();
    });
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
        final allQuestions = List.from(provider.multiplications);
        allQuestions.shuffle();
        _questions =
            allQuestions
                .take(10)
                .map(
                  (m) => {
                    'number1': m.number1,
                    'number2': m.number2,
                    'result': m.result,
                    'type': 'multiplication',
                  },
                )
                .toList();
      } else {
        final provider = Provider.of<DivisionProvider>(context, listen: false);
        final allQuestions = List.from(provider.divisions);
        allQuestions.shuffle();
        _questions =
            allQuestions
                .take(10)
                .map(
                  (d) => {
                    'number1': d.number1,
                    'number2': d.number2,
                    'result': d.result,
                    'type': 'division',
                  },
                )
                .toList();
      }
      isLoading = false;
    });
  }

  void onTimeUp() {
    if (!mounted || isProcessing) return;
    handleAnswer(userAnswer.isEmpty ? '?' : userAnswer);
  }

  void onNumberPress(int number) {
    if (userAnswer.length < 3 && !isProcessing && !isTimeUp) {
      setState(() {
        userAnswer += number.toString();
      });
    }
  }

  void onCheckPress() {
    handleAnswer(userAnswer);
  }

  void handleAnswer(String answer) {
    if (_questions.isEmpty) return;

    final currentQuestion = _questions[currentQuestionIndex];
    final int userResult = int.tryParse(answer) ?? 0;
    final int correctResult = currentQuestion['result'] as int;
    final bool isCorrect = userResult == correctResult;

    setState(() {
      isProcessing = true;
      showResult = true;

      answerHistory.add(
        AnswerRecord(
          number1: currentQuestion['number1'] as int,
          number2: currentQuestion['number2'] as int,
          result: correctResult,
          selectedAnswer: userResult,
          isCorrect: isCorrect,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (currentQuestionIndex >= 9) {
        final correctCount = answerHistory.where((a) => a.isCorrect).length;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: correctCount,
                  wrongAnswers: 10 - correctCount,
                  totalQuestions: 10,
                  stars: (correctCount * 3) ~/ 10,
                  answerHistory: answerHistory,
                  isTesting: true,
                ),
          ),
        );
      } else {
        setState(() {
          currentQuestionIndex++;
          userAnswer = '';
          showResult = false;
          isProcessing = false;
          isTimeUp = false;
        });
        _countdownKey.currentState?.resetTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    final bool checkResult = setting.settings.resultRange.end > 100;
    if (isLoading) {
      return Scaffold(
        backgroundColor: TColors.yellow2,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: TColors.borderbrown,
                strokeWidth: 3.w,
              ),
              SizedBox(height: 16.h),
              Text(
                'Đang tải...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: TColors.borderbrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Không có câu hỏi')));
    }

    final currentQuestion = _questions[currentQuestionIndex];
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMul = settingsProvider.settings.isMultiplication;

    return Scaffold(
      appBar: TAppbar(
        name: 'Kiểm tra (${currentQuestionIndex + 1}/10)',
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
                          '${currentQuestion['number1']} ${isMul ? '×' : '÷'} ${currentQuestion['number2']} = ',
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
                                color:
                                    showResult
                                        ? (answerHistory.last.isCorrect
                                            ? Colors.green
                                            : Colors.red)
                                        : Colors.black,
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
  }
}
