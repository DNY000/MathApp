import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/screens/calculator/calculator_screen.dart';
import 'package:math_app/ultis/colors.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(
        name: 'Bài học',
        showBack: true,
        showProcess: true,
        processing: 1,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            ContainerPractice(number: 10),
            SizedBox(height: 8.h),
            Manhinhnhap(),
            SizedBox(height: 84.h),
            ChonKetqua(),
          ],
        ),
      ),
    );
  }
}

class Manhinhnhap extends StatelessWidget {
  bool showRatingBar;
  Manhinhnhap({super.key, this.showRatingBar = true});

  @override
  Widget build(BuildContext context) {
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
            if (showRatingBar) CustomRatingBar(count: 3),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('1 x 5 = ', style: TextStyle(fontSize: 18.sp)),
                Container(
                  height: 40.h,
                  width: 86.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 18.sp),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
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
  final int number;

  const ContainerPractice({super.key, this.number = 1});

  @override
  Widget build(BuildContext context) {
    bool check() => number <= 9; // Kiểm tra điều kiện

    return Container(
      height: 106.h,
      width: 343.w,
      decoration: BoxDecoration(
        color: TColors.button,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child:
          check()
              ? Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(
                  number,
                  (index) => xucsac(number), // Gọi hàm xucsac
                ),
              )
              : Center(
                child: Text(
                  'Bảng tính cửu chương',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
    );
  }

  Widget xucsac(int number) {
    return Container(
      height: 37.h,
      width: 37.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      child: Wrap(
        spacing: 5.w,
        runSpacing: 5.h,
        children: List.generate(
          number,
          (index) =>
              Text('.', style: TextStyle(fontSize: 18.sp, color: Colors.black)),
        ),
      ),
    );
  }
}

class ChonKetqua extends StatelessWidget {
  const ChonKetqua({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.w,
      runSpacing: 18.h,
      children: List.generate(
        4,
        (index) => customContainer(correct: true, selected: false, number: 5),
      ),
    );
  }

  Widget customContainer({
    required bool correct,
    required bool selected,
    required int number,
  }) {
    return Container(
      height: 119.h,
      width: 160.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.sp)),
        boxShadow: [
          BoxShadow(
            color: TColors.borderbrown,
            blurRadius: 2,
            offset: Offset(0.5, 3),
          ),
        ],
        border: Border.all(color: TColors.borderbrown, width: 2.w),
        color: selected ? (correct ? Colors.green : Colors.red) : Colors.white,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 26.sp,
            color: selected ? TColors.textBack : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
