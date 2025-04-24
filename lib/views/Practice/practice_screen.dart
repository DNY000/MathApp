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
            Selector<MultiplicationProvider, int>(
              builder: (context, value, child) => CustomRatingBar(count: value),
              selector: (p0, p1) => p1.currentMultiplication!.star,
            ),

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
              ? secondNumber > 9 || firstNumber > 9
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
    final int columns =
        (dotCount == 8 || dotCount == 10)
            ? 3
            : dotCount % 2 == 0
            ? 2
            : 3;
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
  bool isProcessing = false;

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
      setState(() {
        selectedAnswer = null;
        isCorrectAnswer = null;
        wrongAnswers.clear();
        isProcessing = false;
      });
      _generateAnswerOptions();
    }
  }

  // tạo kết quả sai
  void _generateAnswerOptions() {
    if (widget.currentMultiplication == null) return;

    dsketqua.clear();
    dsketqua.add(widget.currentMultiplication!.result);

    final int correctResult = widget.currentMultiplication!.result;
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
    if (widget.currentMultiplication == null || isProcessing) return;

    setState(() {
      isProcessing = true;
      selectedAnswer = selected;
    });

    final bool isCorrect = selected == widget.currentMultiplication!.result;
    final multiplicationProvider = Provider.of<MultiplicationProvider>(
      context,
      listen: false,
    );

    setState(() {
      isCorrectAnswer = isCorrect;
      if (!isCorrect) {
        wrongAnswers.add(selected);
      }
    });

    await multiplicationProvider.recordAnswer(selected);

    if (isCorrect) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (multiplicationProvider.isPracticeComplete) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        settings.updateProcessing(
          true,
          (multiplicationProvider.sumStar(
                multiplicationProvider.multiplications,
              ) ~/
              144 *
              100),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: multiplicationProvider.correctAnswersCount,
                  wrongAnswers: multiplicationProvider.wrongAnswersCount,
                  totalQuestions: MultiplicationProvider.PRACTICE_SET_SIZE,
                  stars:
                      multiplicationProvider.correctAnswersCount >= 8
                          ? 3
                          : multiplicationProvider.correctAnswersCount >= 5
                          ? 2
                          : 1,
                ),
          ),
        );
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        selectedAnswer = null;
        isCorrectAnswer = null;
        isProcessing = false;
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

                  Color backgroundColor = TColors.yellow2;
                  if (isSelected) {
                    backgroundColor = isCorrect ? Colors.green : Colors.red;
                  }

                  return GestureDetector(
                    onTapDown: (_) {
                      if (!isWrong && !isProcessing) {
                        setState(() => selectedAnswer = answer); // bắt đầu nhấn
                      }
                    },
                    onTapUp: (_) {
                      if (!isWrong && !isProcessing) {
                        _handleAnswerSelection(answer); // xử lý chọn
                      }
                    },
                    onTapCancel: () {
                      if (!isWrong && !isProcessing) {
                        setState(
                          () => selectedAnswer = null,
                        ); // nếu nhả ra ngoài
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
                                ? [] // không shadow khi nhấn
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
