import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/Practice/answer_list.dart';
import 'package:math_app/views/testing/answer_list_testing.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class CompleteScreen extends StatelessWidget {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;

  final bool isTesting;
  final List<AnswerRecord> answerHistory;

  const CompleteScreen({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.totalQuestions = 10,

    required this.answerHistory,
    this.isTesting = false,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final isMul = settingsProvider.settings.isMultiplication;
    final mul = Provider.of<MultiplicationProvider>(context);
    final int process = isTesting ? 0 : mul.sumStar(mul.multiplications);
    return Scaffold(
      appBar: TAppbar(name: 'Kết quả'.tr(), showBack: false),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTesting) ...[
              SizedBox(height: 24.h),
              Transform.rotate(
                angle: 7.26 * 3.14159 / 180,
                child: Text(
                  'Tiến trình học\ntập của bạn'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: TColors.borderbrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 113.w),
                child: SizedBox(
                  height: 15.5.h,
                  width: 7.58.w,
                  child: Image.asset(
                    'assets/images/icons/muiten.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 7.5.h),
              Container(
                width: 343.w,
                height: 40.h,
                alignment: Alignment.center,
                child: LinearProgressIndicator(
                  backgroundColor: TColors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    TColors.borderbrown,
                  ),
                  value: isMul ? process / 144 : 0.0,
                ),
              ),
            ],

            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultBox(
                  correctAnswers.toString(),
                  'Chính xác'.tr(),
                  Colors.green,
                ),
                _buildResultBox(
                  wrongAnswers.toString(),
                  'Sai'.tr(),
                  Colors.red,
                ),
              ],
            ),
            SizedBox(height: 32.h),

            _buildActionButton(
              'Danh sách câu hỏi'.tr(),
              borderColor: TColors.backgroundBrown,
              Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            isTesting
                                ? AnswerListTesting(list: answerHistory)
                                : AnswerList(list: answerHistory),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),
            _buildActionButton(
              'Chơi lại'.tr(),
              Icons.refresh,
              onTap: () {
                if (!isTesting) {
                  if (isMul) {
                    Provider.of<MultiplicationProvider>(
                      context,
                      listen: false,
                    ).retryCorrectAnswers();
                  } else {
                    Provider.of<DivisionProvider>(
                      context,
                      listen: false,
                    ).retryCorrectAnswers();
                  }
                }
                Navigator.pop(context);
              },
              backgroundColor: TColors.backgroundBrown,
            ),

            SizedBox(height: 16.h),
            _buildActionButton(
              'Menu'.tr(),
              Icons.arrow_back,
              backgroundColor: TColors.yellow2,
              textColor: Colors.black,
              borderColor: Colors.black12,
              onTap: () {
                Provider.of<DivisionProvider>(
                  context,
                  listen: false,
                ).resetPractice();
                Provider.of<MultiplicationProvider>(
                  context,
                  listen: false,
                ).resetPractice();
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
    Color backgroundColor = TColors.backgroundBrown,
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
          borderRadius: BorderRadius.circular(12.r),
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
