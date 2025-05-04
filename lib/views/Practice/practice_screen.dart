// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/views/Practice/complete_srceen.dart';
import 'package:math_app/views/Practice/division_screen.dart';
import 'package:math_app/views/Practice/multiplicationo_screen.dart';
import 'package:math_app/views/Practice/widgets/input_screen.dart';
import 'package:provider/provider.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  void initState() {
    super.initState();

    // Start a new practice session instead of calling onSettingsChanged
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      try {
        final multiplicationProvider = Provider.of<MultiplicationProvider>(
          context,
          listen: false,
        );
        if (multiplicationProvider.practiceSet.isEmpty) {
          multiplicationProvider.startPracticeSession();
        }
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
        final int currentValue =
            Provider.of<MultiplicationProvider>(
              context,
              listen: true,
            ).correctAnswersCount +
            1;
        final int currentValueDivis =
            Provider.of<DivisionProvider>(
              context,
              listen: true,
            ).correctAnswersCount +
            1;
        final int totalLeson = settingsProvider.settings.sumCount + 1;
        // Bạn có thể thay đổi giá trị này từ provider
        return Scaffold(
          appBar: TAppbar(
            name: '${'Bài học'.tr()} $totalLeson',
            showBack: true,
            showProcess: true,
            processing: 1,
            showAction: true,
            actionText: isMul ? '$currentValue/10' : '$currentValueDivis/10',
          ),

          body: isMul ? MultiplicationScreen() : DivisionScreen(),
        );
      },
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
                      'Bảng cửu chương'.tr(),
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
                      firstNumber,
                      (index) => DotContainer(dotCount: secondNumber),
                    ),
                  )
              : secondNumber > 9 || firstNumber ~/ secondNumber > 9
              ? Center(
                child: Text(
                  'Bảng cửu chương'.tr(),
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
    // required this.onShowNextMultiplication,
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
  final GlobalKey<ManhinhnhapState> manhinhnhapKey =
      GlobalKey<ManhinhnhapState>();

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
        manhinhnhapKey.currentState?.updateStars(0);
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
    setState(() {
      isProcessing = true;
      selectedAnswer = selected;
    });

    final bool isCorrect = selected == widget.currentMultiplication!.result;
    final multiplicationProvider = context.read<MultiplicationProvider>();

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
          int currentStar = multiplicationProvider.currentMultiplication!.star;
          int newStar = currentStar < 5 ? currentStar + 1 : currentStar;

          // Cập nhật UI với số sao mới
          manhinhnhapKey.currentState!.updateStars(newStar);
          manhinhnhapKey.currentState!.startRotationAnimation();
        }
      });

      await Future.delayed(const Duration(seconds: 1));
      await multiplicationProvider.recordAnswer(selected);

      if (!mounted) return;

      // kiểm tra xem đã trả lời đúng 10 câu chưa
      if (multiplicationProvider.correctAnswersCount >=
          MultiplicationProvider.PRACTICE_SET_SIZE) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        settings.settings.sumCount++;
        final progress =
            (multiplicationProvider.sumStar(
                  multiplicationProvider.multiplications,
                ) *
                100 ~/
                144);

        settings.updateProcessing(true, progress);

        int wrongAnswersCount = multiplicationProvider.wrongAnswersCount;
        int correctAnswersCount = multiplicationProvider.correctAnswersCount;

        final currentHistory = List<AnswerRecord>.from(
          multiplicationProvider.answerHistory,
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CompleteScreen(
                  correctAnswers: correctAnswersCount,
                  wrongAnswers: wrongAnswersCount,
                  totalQuestions: MultiplicationProvider.PRACTICE_SET_SIZE,
                  answerHistory: currentHistory,
                  isTesting: false,
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
          int currentStar = multiplicationProvider.currentMultiplication!.star;
          int newStar = currentStar > 0 ? currentStar - 1 : 0;

          // Cập nhật UI với số sao mới
          manhinhnhapKey.currentState!.updateStars(newStar);
        }
      });

      // For wrong answers, record immediately
      await multiplicationProvider.recordAnswer(selected);
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
    return Column(
      children: [
        Manhinhnhap(
          key: manhinhnhapKey,
          firstNumber: widget.currentMultiplication?.number1 ?? 0,
          secondNumber: widget.currentMultiplication?.number2 ?? 0,
        ),
        SizedBox(height: 63.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 24.h,
            crossAxisSpacing: 18.w,
            childAspectRatio: 1.5,
            children:
                dsketqua.map((answer) {
                  final bool isWrong = wrongAnswers.contains(answer);
                  final bool isSelected = selectedAnswer == answer;
                  final bool isCorrect =
                      answer == widget.currentMultiplication?.result;

                  Color backgroundColor = TColors.yellow2;
                  if (isWrong) {
                    backgroundColor = Colors.red;
                  } else if (isSelected) {
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
        ),
      ],
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
      width: 159.w,
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
