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
        final div = division.currentDivision;
        if (div == null) {
          return const Center(child: CircularProgressIndicator());
        }
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
  List<int> dsketqua = [];
  Set<int> wrongAnswers = {};
  int? selectedAnswer;
  bool? isCorrectAnswer;
  bool isProcessing = false;
  late Division currentDivision;

  @override
  void initState() {
    super.initState();
    currentDivision = widget.division;
    _generateAnswerOptions();
  }

  @override
  void didUpdateWidget(ChonKetquaChia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.division.number1 != widget.division.number1 ||
        oldWidget.division.number2 != widget.division.number2) {
      currentDivision = widget.division;
      _generateAnswerOptions();
      setState(() {
        selectedAnswer = null;
        isCorrectAnswer = null;
        wrongAnswers.clear();
        isProcessing = false;
      });
    }
  }

  void _generateAnswerOptions() {
    dsketqua.clear();
    dsketqua.add(currentDivision.result);

    final random = Random();
    final int correctResult = currentDivision.result;
    final int minRange = max(1, (correctResult * 0.8).toInt());
    final int maxRange = max(minRange + 10, (correctResult * 1.2).toInt());

    while (dsketqua.length < 4) {
      int wrongAnswer = minRange + random.nextInt(maxRange - minRange);
      if (wrongAnswer != correctResult && !dsketqua.contains(wrongAnswer)) {
        dsketqua.add(wrongAnswer);
      }
    }

    dsketqua.shuffle();
  }

  Future<void> _handleAnswerSelection(int selected) async {
    if (isProcessing) return;

    final bool isCorrect = selected == currentDivision.result;
    final provider = context.read<DivisionProvider>();

    setState(() {
      isProcessing = true;
      selectedAnswer = selected;
      isCorrectAnswer = isCorrect;
      if (!isCorrect) {
        wrongAnswers.add(selected);
      }
    });

    await provider.recordAnswer(selected);

    if (isCorrect) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (provider.isPracticeComplete) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: provider.correctAnswersCount,
                  wrongAnswers: provider.wrongAnswersCount,
                  totalQuestions: DivisionProvider.PRACTICE_SET_SIZE,

                  stars:
                      provider.correctAnswersCount >= 8
                          ? 3
                          : provider.correctAnswersCount >= 5
                          ? 2
                          : 1,
                ),
          ),
        );
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          selectedAnswer = null;
          isCorrectAnswer = null;
          isProcessing = false;
        });
      }
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
            dsketqua.map((answer) {
              final bool isWrong = wrongAnswers.contains(answer);
              final bool isSelected = selectedAnswer == answer;
              final bool isCorrect = answer == currentDivision.result;

              Color backgroundColor = Colors.white;
              if (isSelected) {
                backgroundColor = isCorrect ? Colors.green : Colors.red;
              }

              return GestureDetector(
                onTap:
                    (!isWrong && !isProcessing)
                        ? () => _handleAnswerSelection(answer)
                        : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: TColors.borderbrown, width: 2),
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
