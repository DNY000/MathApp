import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class AnswerList extends StatelessWidget {
  const AnswerList({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final bool isMul = settingsProvider.settings.isMultiplication;

    return Scaffold(
      backgroundColor: TColors.yellow2,
      appBar: TAppbar(name: 'Danh sách câu trả lời'.tr(), showBack: true),
      body: isMul ? _buildMultiplicationList() : _buildDivisionList(),
    );
  }

  Widget _buildMultiplicationList() {
    return Consumer<MultiplicationProvider>(
      builder: (context, provider, child) {
        return _buildAnswerList(
          provider.answerHistory,
          isMultiplication: true,
          context: context,
        );
      },
    );
  }

  Widget _buildDivisionList() {
    return Consumer<DivisionProvider>(
      builder: (context, provider, child) {
        return _buildAnswerList(
          provider.answerHistory,
          isMultiplication: false,
          context: context,
        );
      },
    );
  }

  Widget _buildAnswerList(
    List<AnswerRecord> answers, {
    required bool isMultiplication,
    required BuildContext context,
  }) {
    if (answers.isEmpty) {
      return Center(
        child: Text(
          'Chưa có câu trả lời nào'.tr(),
          style: TextStyle(fontSize: 18.sp, color: TColors.textBack),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 18.h,
        bottom: 60.h,
        left: 30.w,
        right: 30.w,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: TColors.yellow2,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: Border(bottom: BorderSide(color: TColors.yellow, width: 3.w)),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: answers.length,
          itemBuilder: (context, index) {
            final answer = answers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.r),

              child: Row(
                children: [
                  SizedBox(
                    width: 24.w,
                    child: Icon(
                      answer.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: answer.isCorrect ? Colors.green : Colors.red,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120.w,
                          child: Text(
                            isMultiplication
                                ? '${answer.number1} × ${answer.number2}'
                                : '${answer.number1} ÷ ${answer.number2}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          ' = ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            '${answer.selectedAnswer}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  answer.isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
