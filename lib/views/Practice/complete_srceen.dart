import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/views/Practice/answer_list.dart';

class CompleteScreen extends StatelessWidget {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int stars;

  const CompleteScreen({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.totalQuestions = 10,
    this.stars = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercentage =
        (correctAnswers / (correctAnswers + wrongAnswers)) * 100;

    return Scaffold(
      appBar: TAppbar(name: 'Kết quả', showBack: false),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              'Tiến trình học\ntập của bạn',
              style: TextStyle(
                fontSize: 20.sp,
                color: const Color(0xFF8B4513),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(24.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '${progressPercentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultBox(
                  correctAnswers.toString(),
                  'Chính xác',
                  Colors.green,
                ),
                _buildResultBox(wrongAnswers.toString(), 'Sai', Colors.red),
              ],
            ),
            SizedBox(height: 32.h),
            // Display stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40.w,
                );
              }),
            ),
            SizedBox(height: 32.h),
            _buildActionButton(
              'Danh sách câu hỏi',
              Icons.list_alt,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnswerList()),
                  ),
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              'Chơi lại',
              Icons.refresh,
              onTap: () {},
              backgroundColor: TColors.backgroundBrown,
            ),
            SizedBox(height: 16.h),
            _buildActionButton(
              'Menu',
              Icons.arrow_back,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              borderColor: Colors.black12,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(String number, String label, Color color) {
    return Container(
      width: 150.w,
      height: 150.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 40.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
    Color backgroundColor = const Color(0xFFFFE0B2),
    Color textColor = Colors.black,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
