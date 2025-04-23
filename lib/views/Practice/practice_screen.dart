// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/views/Practice/division_screen.dart';
import 'package:math_app/views/Practice/multiplicationo_screen.dart';
import 'package:math_app/views/calculator/calculator_screen.dart';
import 'package:provider/provider.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  void initState() {
    super.initState();

    // Dùng Future đơn giản, không lồng nhau
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      try {
        final multiplicationProvider = Provider.of<MultiplicationProvider>(
          context,
          listen: false,
        );

        // Gọi trực tiếp không dùng Future lồng nhau
        multiplicationProvider.onSettingsChanged();
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final bool isMul = settingsProvider.settings.isMultiplication;
        return Scaffold(
          appBar: TAppbar(
            name: 'Bài học ',
            showBack: true,
            showProcess: true,
            processing: 1,
          ),
          body: isMul ? MultiplicationScreen() : DivisionScreen(),
        );
      },
    );
  }
}

class Manhinhnhap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    bool isMul = settingsProvider.settings.isMultiplication;

    return Container(
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
            CustomRatingBar(),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isMul
                    ? Text(
                      '$firstNumber x $secondNumber = ',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : Text(
                      '$firstNumber : $secondNumber = ',
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
                  ),
                  child: Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerPractice<T> extends StatelessWidget {
  final T operation;

  const ContainerPractice({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final bool isMultiplication = operation is Multiplication;
    final int firstNumber =
        isMultiplication
            ? (operation as Multiplication).number1
            : (operation as Division).number1;
    final int secondNumber =
        isMultiplication
            ? (operation as Multiplication).number2
            : (operation as Division).number2;

    return Container(
      width: 343.w,
      height: 108.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TColors.yellow,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child:
          isMultiplication
              ? secondNumber > 10 || firstNumber > 10
                  ? Center(
                    child: Text(
                      'Bảng cửu chương',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: List.generate(
                      secondNumber,
                      (index) => DotContainer(dotCount: secondNumber),
                    ),
                  )
              : secondNumber > 10 || firstNumber / secondNumber > 10
              ? Center(
                child: Text(
                  'Bảng cửu chương',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(
                  firstNumber ~/ secondNumber,
                  (index) => DotContainer(dotCount: secondNumber),
                ),
              ),
    );
  }
}

class DotContainer extends StatelessWidget {
  final int dotCount;

  const DotContainer({super.key, required this.dotCount});

  @override
  Widget build(BuildContext context) {
    final int columns = dotCount % 2 == 0 ? 2 : 3;
    final int rows = (dotCount / columns).ceil();

    return Container(
      height: 41.h,
      width: 41.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(rows, (rowIndex) {
            final int dotsInThisRow =
                rowIndex == rows - 1
                    ? dotCount - (rowIndex * columns)
                    : columns;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                dotsInThisRow,
                (colIndex) => Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ChonKetqua extends StatefulWidget {
  final Multiplication? currentMultiplication;
  final Function onShowNextMultiplication;

  const ChonKetqua({
    super.key,
    required this.currentMultiplication,
    required this.onShowNextMultiplication,
  });

  @override
  State<ChonKetqua> createState() => _ChonKetquaState();
}

class _ChonKetquaState extends State<ChonKetqua> {
  List<int> dsketqua = [];
  Set<int> wrongAnswers = {};
  int? selectedAnswer;
  bool? isCorrectAnswer;

  // Create a random number generator
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateAnswerOptions();
  }

  @override
  void didUpdateWidget(ChonKetqua oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMultiplication != oldWidget.currentMultiplication) {
      _generateAnswerOptions();
    }
  }

  void _generateAnswerOptions() {
    if (widget.currentMultiplication == null) return;

    // Clear previous answers
    dsketqua.clear();

    // Add the correct answer
    dsketqua.add(widget.currentMultiplication!.result);

    // Generate 3 unique wrong answers
    while (dsketqua.length < 4) {
      // Generate a random number within 20% of the correct answer
      int minRange = (widget.currentMultiplication!.result * 0.8).toInt();
      int maxRange = (widget.currentMultiplication!.result * 1.2).toInt();

      // Ensure positive values
      minRange = max(1, minRange);
      maxRange = max(minRange + 10, maxRange);

      int wrongAnswer = minRange + random.nextInt(maxRange - minRange);

      if (wrongAnswer != widget.currentMultiplication!.result &&
          !dsketqua.contains(wrongAnswer)) {
        dsketqua.add(wrongAnswer);
      }
    }

    // Shuffle the answers
    dsketqua.shuffle();
  }

  void _handleAnswerSelection(int selected) async {
    if (widget.currentMultiplication == null) return;

    final bool isCorrect = selected == widget.currentMultiplication!.result;

    setState(() {
      selectedAnswer = selected;
      isCorrectAnswer = isCorrect;
      if (!isCorrect) {
        wrongAnswers.add(selected);
      }
    });

    final multiplicationProvider = Provider.of<MultiplicationProvider>(
      context,
      listen: false,
    );

    if (isCorrect) {
      // Record the answer and update stars
      multiplicationProvider.recordAnswer(true, selected);
      multiplicationProvider.updateStar(true);

      // Wait a moment to show the green color
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if we've completed 10 questions
      if (multiplicationProvider.isPracticeComplete) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: multiplicationProvider.correctAnswers,
                  wrongAnswers: multiplicationProvider.wrongAnswers,
                  totalQuestions: MultiplicationProvider.PRACTICE_SET_SIZE,
                  stars:
                      multiplicationProvider.correctAnswers >= 8
                          ? 3
                          : multiplicationProvider.correctAnswers >= 5
                          ? 2
                          : 1,
                ),
          ),
        );
      } else {
        // Reset state and show next multiplication
        setState(() {
          selectedAnswer = null;
          isCorrectAnswer = null;
          wrongAnswers.clear();
        });
        widget.onShowNextMultiplication();
      }
    } else {
      // Record wrong answer
      multiplicationProvider.recordAnswer(false, selected);
      multiplicationProvider.updateStar(false);

      // Allow user to try again immediately
      setState(() {
        selectedAnswer = null;
        isCorrectAnswer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.5,
            children:
                dsketqua.map((answer) {
                  final bool isWrong = wrongAnswers.contains(answer);
                  final bool isSelected = selectedAnswer == answer;
                  final bool isCorrect =
                      answer == widget.currentMultiplication?.result;

                  Color backgroundColor = Colors.white;
                  Color borderColor = TColors.borderbrown;

                  if (isSelected && isCorrect) {
                    backgroundColor = Colors.green;
                    borderColor = TColors.borderbrown;
                  } else if (isWrong) {
                    backgroundColor = Colors.red;
                    borderColor = TColors.borderbrown;
                  }

                  return GestureDetector(
                    onTap:
                        (!isWrong && selectedAnswer == null)
                            ? () => _handleAnswerSelection(answer)
                            : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B4513),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          answer.toString(),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: TColors.textBack,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class AnswerContainer extends StatelessWidget {
  final int number;
  final bool isCorrect;
  final bool selected;

  const AnswerContainer({
    super.key,
    required this.number,
    required this.isCorrect,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 119.h,
      width: 160.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: TColors.borderbrown,
            blurRadius: 2,
            offset: const Offset(0.5, 3),
          ),
        ],
        border: Border.all(color: TColors.borderbrown, width: 2.w),
        color:
            selected ? (isCorrect ? Colors.green : Colors.red) : Colors.white,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 26.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
