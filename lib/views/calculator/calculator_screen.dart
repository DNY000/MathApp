// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:provider/provider.dart';

import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/ultis/colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int selectedNumber = 0;
  List<Multiplication> currentMultiplications = [];
  List<Division> currentDivison = [];

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final isMul = settingsProvider.settings.isMultiplication;
    final mul = Provider.of<MultiplicationProvider>(context, listen: false);
    final divison = Provider.of<DivisionProvider>(context, listen: false);

    if (isMul) {
      currentMultiplications = mul.dsnumber(selectedNumber);
    } else {
      currentDivison = divison.dsnumber(selectedNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMul =
        Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).settings.isMultiplication;
    Provider.of<SettingsProvider>(context);
    final mul = Provider.of<MultiplicationProvider>(context);
    final divison = Provider.of<DivisionProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: TColors.yellow1,
      appBar: TAppbar(name: 'Bảng Tính'.tr(), showBack: true),
      body: Padding(
        padding: EdgeInsets.only(left: 29.w, right: 29.w, top: 17.h),
        child: Column(
          children: [
            tableCalculator(),
            SizedBox(height: 50.h),
            CustomButtonNumber(
              onNumberSelected: (number) {
                setState(() {
                  selectedNumber = number;
                  if (isMul) {
                    currentMultiplications = mul.dsnumber(number);
                  } else {
                    currentDivison = divison.dsnumber(selectedNumber);
                  }
                });
              },
              selectedNumber: selectedNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget tableCalculator() {
    return Container(
      height: 430.h,
      width: 343.w,
      decoration: BoxDecoration(
        color: TColors.yellow2,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border(
          bottom: BorderSide(width: 1.w, color: TColors.borderbrown),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 30.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return CalculatorRow(number: selectedNumber, index: index);
                },
                separatorBuilder:
                    (BuildContext context, int index) => SizedBox(height: 18.h),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return CalculatorRow(
                    number: selectedNumber,
                    index: index + 5,
                  );
                },
                separatorBuilder:
                    (BuildContext context, int index) => SizedBox(height: 18.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButtonNumber extends StatelessWidget {
  final Function(int) onNumberSelected;
  final int selectedNumber;

  const CustomButtonNumber({
    super.key,
    required this.onNumberSelected,
    required this.selectedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        12,
        (index) => GestureDetector(
          onTap: () => onNumberSelected(index),
          child: ButtonNumber(number: index, selected: index == selectedNumber),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonNumber extends StatelessWidget {
  final bool selected;
  final int number;

  const ButtonNumber({super.key, this.selected = false, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      width: 46.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14.r)),
        border: Border(
          bottom: BorderSide(color: TColors.borderbrown, width: 3.w),
          left: BorderSide(color: TColors.borderbrown, width: 1.w),
          right: BorderSide(color: TColors.borderbrown, width: 1.w),
          top: BorderSide(color: TColors.borderbrown, width: 1.w),
        ),
        color: selected ? TColors.backgroundBrown : Colors.white,
      ),
      child: Center(
        child:
            number != 0
                ? Text('$number', style: TextStyle(fontSize: 16.sp))
                : null,
      ),
    );
  }
}

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar({super.key, this.count = 0}); // Mặc định 0 sao
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18.h,
      width: 98.w,
      child: Row(
        children: List.generate(5, (index) {
          return Icon(
            Icons.star,
            size: 18.sp,
            color: index < count ? Colors.amber : Colors.grey,
          );
        }),
      ),
    );
  }
}

// ignore: must_be_immutable
class CalculatorRow extends StatelessWidget {
  int number;
  int index;
  CalculatorRow({super.key, required this.number, required this.index});

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingsProvider>(context);
    final mulProvider = Provider.of<MultiplicationProvider>(context);
    final divisionProvider = Provider.of<DivisionProvider>(context);
    bool isMul = settingProvider.settings.isMultiplication;
    int number2 = index;
    int result = number * number2;

    // Tìm phép tính trong danh sách hiện tại
    final multiplication = mulProvider.currentMultiplications.firstWhere(
      (m) => m.number1 == number && m.number2 == number2,
      orElse:
          () => Multiplication(
            number1: number,
            number2: number2,
            result: result,
            star: 0,
          ),
    );
    final divison = divisionProvider.currentDivisions.firstWhere(
      (element) => element.number1 == number && element.number2 == number2,
      orElse:
          () => Division(
            number1: result,
            number2: number2,
            result: number,
            star: 0,
          ),
    );

    return Column(
      children: [
        CustomRatingBar(count: isMul ? multiplication.star : divison.star),
        SizedBox(height: 6.h),
        SizedBox(
          height: 21.h,
          width: 120.w,
          child:
              isMul
                  ? Text(
                    ' $number x $number2 = $result ',
                    style: TextStyle(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  )
                  : Text(
                    ' $result : $number = $number2 ',
                    style: TextStyle(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  ),
        ),
      ],
    );
  }
}
