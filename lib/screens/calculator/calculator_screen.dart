import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int selectedNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.yellow1,
      appBar: TAppbar(name: 'Bảng Tính', showBack: true),
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
                  return calculatorRow(
                    selectedNumber,
                    index,
                  ); // Hiển thị kết quả
                },
                separatorBuilder:
                    (BuildContext context, int index) => SizedBox(height: 18.h),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return calculatorRow(
                    selectedNumber,
                    index + 5,
                  ); // Hiển thị kết quả
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

  Widget calculatorRow(int number, int index) {
    int number1 = index * number; // Tính number1
    int number2 = index; // Tính number2

    return Column(
      children: [
        CustomRatingBar(count: 2),
        SizedBox(height: 6.h),
        SizedBox(
          height: 21.h,
          width: 120.w, // Điều chỉnh chiều rộng để hiển thị đầy đủ
          child: Text(
            ' $number2 x $number = $number1 ', // Hiển thị kết quả
            style: TextStyle(fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
        border: Border.all(color: TColors.borderbrown, width: 1.w),
        color: selected ? TColors.backgroundBrown : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0.5, 2),
            color: TColors.backgroundBrown,
            spreadRadius: 1,
          ),
        ],
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

// ignore: must_be_immutable
class CustomRatingBar extends StatelessWidget {
  int count;
  CustomRatingBar({super.key, this.count = 1});

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
