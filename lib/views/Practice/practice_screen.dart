import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:provider/provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(
        name: 'Bài học 67',
        showBack: true,
        showProcess: true,
        processing: 1,
      ),
      body: Consumer<MultiplicationProvider>(
        builder: (context, multiplication, child) {
          Random random = Random();
          final multi = multiplication.multiplications;
          Multiplication mul = multi[random.nextInt(multi.length)];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                ContainerPractice(multiplication: mul),
                SizedBox(height: 8.h),
                Manhinhnhap(
                  firstNumber: mul.number1,
                  secondNumber: mul.number2,
                ),
                SizedBox(height: 84.h),
                ChonKetqua(multiplication: mul), // Chọn kết quả
              ],
            ),
          );
        },
      ),
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

class ContainerPractice extends StatelessWidget {
  final Multiplication multiplication;
  ContainerPractice({super.key, required this.multiplication});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343.w,
      height: 108.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TColors.yellow,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child:
          multiplication.number2 > 10
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
                  multiplication.number2,
                  (index) => DotContainer(dotCount: multiplication.number2),
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
  final Multiplication multiplication;
  const ChonKetqua({super.key, required this.multiplication});

  @override
  State<ChonKetqua> createState() => _ChonKetquaState();
}

class _ChonKetquaState extends State<ChonKetqua> {
  List<bool> selectedAnswers = [false, false, false, false];
  List<bool> isAnswerCorrect = [false, false, false, false];
  late List<int> options;

  late Multiplication currentMultiplication;

  @override
  void initState() {
    super.initState();
    currentMultiplication = widget.multiplication;
    options = _generateAnswerOptions(currentMultiplication.result);
  }

  List<int> _generateAnswerOptions(int correctAnswer) {
    final List<int> options = [correctAnswer];
    while (options.length < 4) {
      final int randomOffset = [-6, -7, 6, 5][options.length - 1];
      final int option = correctAnswer + randomOffset;
      if (option > 0 && !options.contains(option)) {
        options.add(option);
      }
    }
    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.w,
      runSpacing: 18.h,
      children:
          options.asMap().entries.map((entry) {
            int index = entry.key;
            int number = entry.value;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAnswers[index] = true;
                  isAnswerCorrect[index] =
                      number == currentMultiplication.result;
                });

                if (isAnswerCorrect[index]) {
                  Random random = Random();
                  final multi =
                      context.read<MultiplicationProvider>().multiplications;
                  Multiplication newMul = multi[random.nextInt(multi.length)];

                  context
                      .read<MultiplicationProvider>()
                      .updateCurrentMultiplication(newMul);

                  setState(() {
                    selectedAnswers = [false, false, false, false];
                    isAnswerCorrect = [false, false, false, false];
                    options = _generateAnswerOptions(newMul.result);
                    currentMultiplication = newMul;
                  });
                }
              },
              child: AnswerContainer(
                number: number,
                selected: selectedAnswers[index],
                isCorrect: isAnswerCorrect[index],
              ),
            );
          }).toList(),
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
