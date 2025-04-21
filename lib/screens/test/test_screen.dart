import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/screens/test/testing_screen.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TAppbar(name: 'Kiểm tra', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 47.h, left: 64.w, right: 64.w),
            child: Column(
              children: [
                SizedBox(
                  height: 273.h,
                  width: 344.w,
                  child: Image.asset(TImage.image1, fit: BoxFit.cover),
                ),
                SizedBox(height: 44.h),
                SizedBox(
                  height: 56.h,
                  width: 271.w,
                  child: Center(
                    child: Text(
                      'Bài kiểm tra gồm 10 câu hỏi, có giới hạn thời gian mỗi câu',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: TColors.textBack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: Center(
              child: Text(
                'Chúc bạn may mắn!!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: TColors.textBack,
                ),
              ),
            ),
          ),
          SizedBox(height: 44.h),
          SizedBox(
            height: 60.h,
            width: 343.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: TColors.button,
                backgroundColor: TColors.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.sp)),
                  side: BorderSide(width: 1.w, color: TColors.borderbrown),
                ),
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestingScreen()),
                  ),
              child: Text(
                'Sẵn sàng',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: TColors.textBack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BanPhim extends StatelessWidget {
  const BanPhim({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 308.h,
      width: 344.w,
      child: Wrap(
        spacing: 33.w,
        runSpacing: 12.h,

        children: [
          nutBam(number: 1, cancel: false, result: false, onPress: () {}),
          nutBam(number: 2, cancel: false, result: false, onPress: () {}),
          nutBam(number: 3, cancel: false, result: false, onPress: () {}),
          nutBam(number: 4, cancel: false, result: false, onPress: () {}),
          nutBam(number: 5, cancel: false, result: false, onPress: () {}),
          nutBam(number: 6, cancel: false, result: false, onPress: () {}),
          nutBam(number: 7, cancel: false, result: false, onPress: () {}),
          nutBam(number: 8, cancel: false, result: false, onPress: () {}),
          nutBam(number: 9, cancel: false, result: false, onPress: () {}),
          nutBam(number: 0, cancel: true, result: false, onPress: () {}),
          nutBam(number: 0, cancel: false, result: false, onPress: () {}),
          nutBam(number: 0, cancel: false, result: true, onPress: () {}),
        ],
      ),
    );
  }

  Widget nutBam({
    required int number,
    required bool cancel,
    required bool result,
    required VoidCallback onPress,
  }) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 68.h,
        width: 92.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: cancel ? Colors.red : TColors.borderbrown,
            width: 1.w,
          ),
          color:
              cancel
                  ? Colors.white
                  : (result ? Colors.green[400] : TColors.button),
          borderRadius: BorderRadius.all(Radius.circular(34.r)),
        ),
        child: Center(
          child:
              cancel
                  ? Image.asset(TImage.daux)
                  : result
                  ? Image.asset(TImage.dauv)
                  : Text(
                    '$number',
                    style: TextStyle(
                      color: TColors.textBack,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }
}
