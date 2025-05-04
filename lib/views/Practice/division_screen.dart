import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/views/Practice/practice_screen.dart';
import 'package:math_app/views/Practice/widgets/input_screen.dart';
import 'package:provider/provider.dart';

class DivisionScreen extends StatefulWidget {
  const DivisionScreen({super.key});

  @override
  State<DivisionScreen> createState() => _DivisionScreenState();
}

class _DivisionScreenState extends State<DivisionScreen> {
  @override
  void initState() {
    super.initState();

    // Khởi tạo dữ liệu ngay sau khi widget được tạo, không phải trong build
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      final divisionProvider = Provider.of<DivisionProvider>(
        context,
        listen: false,
      );
      if (divisionProvider.practiceSet.isEmpty ||
          divisionProvider.correctAnswersCount >=
              DivisionProvider.PRACTICE_SET_SIZE) {
        divisionProvider.startPracticeSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DivisionProvider>(
      builder: (context, division, child) {
        final div = division.currentDivision;
        if (div == null) {
          // Không gọi startPracticeSession() ở đây
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              ContainerPractice<Division>(operation: div),
              SizedBox(height: 8.h),
              ChonKetquaChia(division: div, onShowNextDivision: () {}),
            ],
          ),
        );
      },
    );
  }
}

class ChonKetquaChia extends StatefulWidget {
  final Division? division;
  final VoidCallback onShowNextDivision;
  const ChonKetquaChia({
    super.key,
    required this.division,
    required this.onShowNextDivision,
  });

  @override
  State<ChonKetquaChia> createState() => _ChonKetquaChiaState();
}

class _ChonKetquaChiaState extends State<ChonKetquaChia>
    with SingleTickerProviderStateMixin {
  List<int> dsketqua = [];
  Set<int> wrongAnswers = {};
  int? selectedAnswer;
  bool? isCorrectAnswer;
  bool isProcessing = false;
  final GlobalKey<ManhinhnhapState> manhinhnhapKey =
      GlobalKey<ManhinhnhapState>();

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateAnswerOptions();
  }

  @override
  void didUpdateWidget(ChonKetquaChia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.division != oldWidget.division) {
      setState(() {
        selectedAnswer = null;
        isCorrectAnswer = null;
        wrongAnswers.clear();
        isProcessing = false;
      });

      // Sử dụng addPostFrameCallback để đảm bảo setState được gọi sau khi build hoàn tất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && manhinhnhapKey.currentState != null) {
          manhinhnhapKey.currentState!.updateStars(0);
        }
      });

      _generateAnswerOptions();
    }
  }

  void _generateAnswerOptions() {
    if (widget.division == null) return;

    dsketqua.clear();
    dsketqua.add(widget.division!.result);

    final int correctResult = widget.division!.result;
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
    setState(() {
      isProcessing = true;
      selectedAnswer = selected;
    });

    final bool isCorrect = selected == widget.division!.result;
    final provider = context.read<DivisionProvider>();

    setState(() {
      isCorrectAnswer = isCorrect;
      if (!isCorrect) {
        wrongAnswers.add(selected);
      }
    });

    if (isCorrect) {
      // Animation và cập nhật sao - sử dụng addPostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && manhinhnhapKey.currentState != null) {
          // Reset số sao hiện tại trước
          manhinhnhapKey.currentState!.updateStars(0);

          // Tính toán số sao mới
          int currentStar = provider.currentDivision!.star;
          int newStar = currentStar < 5 ? currentStar + 1 : currentStar;

          // Cập nhật UI với số sao mới
          manhinhnhapKey.currentState!.updateStars(newStar);
          manhinhnhapKey.currentState!.startRotationAnimation();
        }
      });

      await Future.delayed(const Duration(seconds: 1));
      await provider.recordAnswer(selected);

      if (!mounted) return;

      // kiểm tra xem đã trả lời đúng 10 câu chưa
      if (provider.correctAnswersCount >= DivisionProvider.PRACTICE_SET_SIZE) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final progress = (provider.sumStar(provider.divisions) * 100 ~/ 144);
        settings.settings.sumCount++;
        settings.updateProcessing(false, progress);

        int wrongAnswersCount = provider.wrongAnswersCount;
        int correctAnswersCount = provider.correctAnswersCount;

        final currentHistory = List<AnswerRecord>.from(provider.answerHistory);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: correctAnswersCount,
                  wrongAnswers: wrongAnswersCount,
                  totalQuestions: DivisionProvider.PRACTICE_SET_SIZE,
                  answerHistory: currentHistory,
                  isTesting: true,
                ),
          ),
        );
      }

      // Chỉ reset trạng thái khi trả lời đúng và đã hoàn thành quá trình
      if (mounted) {
        setState(() {
          selectedAnswer = null;
          isCorrectAnswer = null;
          isProcessing = false;
        });
      }
    } else {
      // Cập nhật sao khi trả lời sai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && manhinhnhapKey.currentState != null) {
          // Tính toán số sao mới khi trả lời sai (giảm 1 sao)
          int currentStar = provider.currentDivision!.star;
          int newStar = currentStar > 0 ? currentStar - 1 : 0;

          // Cập nhật UI với số sao mới
          manhinhnhapKey.currentState!.updateStars(newStar);
        }
      });

      // For wrong answers, record immediately
      await provider.recordAnswer(selected);
      await Future.delayed(const Duration(milliseconds: 500));

      // Chỉ reset trạng thái isProcessing để cho phép tiếp tục chọn,
      // nhưng giữ nguyên selectedAnswer và isCorrectAnswer để giữ hiển thị màu đỏ
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Manhinhnhap(
            key: manhinhnhapKey,
            firstNumber: widget.division?.number1 ?? 0,
            secondNumber: widget.division?.number2 ?? 0,
          ),
          SizedBox(height: 63.h),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24.h,
            crossAxisSpacing: 18.w,
            childAspectRatio: 1.5,
            children:
                dsketqua.map((answer) {
                  final bool isWrong = wrongAnswers.contains(answer);
                  final bool isSelected = selectedAnswer == answer;
                  final bool isCorrect = answer == widget.division?.result;

                  Color backgroundColor = TColors.yellow2;
                  if (isWrong) {
                    backgroundColor = Colors.red;
                  } else if (isSelected) {
                    backgroundColor = isCorrect ? Colors.green : Colors.red;
                  }

                  return GestureDetector(
                    onTapDown: (_) {
                      if (!isWrong && !isProcessing) {
                        setState(() => selectedAnswer = answer);
                      }
                    },
                    onTapUp: (_) {
                      if (!isWrong && !isProcessing) {
                        _handleAnswerSelection(answer);
                      }
                    },
                    onTapCancel: () {
                      if (!isWrong && !isProcessing) {
                        setState(() => selectedAnswer = null);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      transform:
                          selectedAnswer == answer
                              ? Matrix4.translationValues(0, 2, 0)
                              : Matrix4.identity(),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: TColors.borderbrown,
                          width: 2,
                        ),
                        boxShadow:
                            selectedAnswer == answer
                                ? []
                                : [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
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
