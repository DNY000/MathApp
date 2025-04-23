import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/views/Practice/practice_screen.dart';
import 'package:provider/provider.dart';

class DivisionScreen extends StatelessWidget {
  const DivisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DivisionProvider>(
      builder: (context, division, child) {
        final div = division.currentDivision!;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              ContainerPractice<Division>(operation: div),
              SizedBox(height: 8.h),
              Manhinhnhap(firstNumber: div.number1, secondNumber: div.number2),
              SizedBox(height: 84.h),
              ChonKetquaChia(division: div),
            ],
          ),
        );
      },
    );
  }
}

class ChonKetquaChia extends StatefulWidget {
  final Division division;
  const ChonKetquaChia({super.key, required this.division});

  @override
  State<ChonKetquaChia> createState() => _ChonKetquaChiaState();
}

class _ChonKetquaChiaState extends State<ChonKetquaChia> {
  Set<int> wrongAnswers = {};
  int? selectedAnswer;
  bool? isCorrectAnswer;
  late List<int> options;
  late Division currentDivision;

  @override
  void initState() {
    super.initState();
    currentDivision = widget.division;
    options = _generateAnswerOptions(currentDivision.result);
  }

  @override
  void didUpdateWidget(ChonKetquaChia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.division != widget.division) {
      currentDivision = widget.division;
      options = _generateAnswerOptions(currentDivision.result);
      selectedAnswer = null;
      isCorrectAnswer = null;
      wrongAnswers.clear();
    }
  }

  List<int> _generateAnswerOptions(int correctAnswer) {
    final List<int> options = [correctAnswer];
    final random = Random();

    while (options.length < 4) {
      // Generate wrong answers that make sense for division
      int wrongAnswer;
      if (random.nextBool()) {
        wrongAnswer = correctAnswer + random.nextInt(3) + 1;
      } else {
        wrongAnswer = correctAnswer - random.nextInt(3) - 1;
      }

      if (wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    options.shuffle();
    return options;
  }

  void _handleAnswerSelection(int selected) async {
    if (!mounted) return;

    final bool isCorrect = selected == currentDivision.result;

    setState(() {
      selectedAnswer = selected;
      isCorrectAnswer = isCorrect;
      if (!isCorrect) {
        wrongAnswers.add(selected);
      }
    });

    try {
      final provider = context.read<DivisionProvider>();

      // Record the answer
      provider.recordAnswer(isCorrect, selected);

      if (isCorrect) {
        // Update star count
        provider.updateStar(1);

        // Wait a moment to show the green color
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if we've completed 10 questions
        if (provider.correctAnswers + provider.wrongAnswers >= 10) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => CompleteScreen(
                    correctAnswers: provider.correctAnswers,
                    wrongAnswers: provider.wrongAnswers,
                    totalQuestions: 10,
                    stars:
                        provider.correctAnswers >= 8
                            ? 3
                            : provider.correctAnswers >= 5
                            ? 2
                            : 1,
                  ),
            ),
          );
          return;
        }

        // Get next question
        await provider.updateCurrentDivision(currentDivision);

        if (mounted) {
          setState(() {
            currentDivision = provider.currentDivision!;
            options = _generateAnswerOptions(currentDivision.result);
            selectedAnswer = null;
            isCorrectAnswer = null;
            wrongAnswers.clear();
          });
        }
      } else {
        // For wrong answer, just update the star count
        provider.updateStar(0);

        // Reset selection to allow another try
        setState(() {
          selectedAnswer = null;
          isCorrectAnswer = null;
        });

        // Check if we've completed 10 questions
        if (provider.correctAnswers + provider.wrongAnswers >= 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => CompleteScreen(
                    correctAnswers: provider.correctAnswers,
                    wrongAnswers: provider.wrongAnswers,
                    totalQuestions: 10,
                    stars:
                        provider.correctAnswers >= 8
                            ? 3
                            : provider.correctAnswers >= 5
                            ? 2
                            : 1,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 1.5,
        children:
            options.map((answer) {
              final bool isWrong = wrongAnswers.contains(answer);
              final bool isSelected = selectedAnswer == answer;
              final bool isCorrect = answer == currentDivision.result;

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
                        color: TColors.borderbrown,
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
    );
  }
}
