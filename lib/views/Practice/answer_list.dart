import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/division_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:provider/provider.dart';

class AnswerList extends StatelessWidget {
  const AnswerList({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final bool isMul = settingsProvider.settings.isMultiplication;

    return Scaffold(
      backgroundColor: TColors.yellow2,
      appBar: TAppbar(name: 'Danh sách câu trả lời', showBack: true),
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
          'Chưa có câu trả lời nào',
          style: TextStyle(fontSize: 18.sp, color: Colors.black54),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        border: Border(bottom: BorderSide(color: TColors.yellow1, width: 3.w)),
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
                            color: answer.isCorrect ? Colors.green : Colors.red,
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
    );
  }
}

void _showAnswerHistory(BuildContext context) {
  final provider = context.read<MultiplicationProvider>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: TColors.backgroundBrown,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Lịch sử làm bài',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: provider.answerHistory.length,
                  itemBuilder: (context, index) {
                    final answer = provider.answerHistory[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color:
                            answer.isCorrect
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: answer.isCorrect ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            answer.isCorrect
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: answer.isCorrect ? Colors.green : Colors.red,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '${answer.number1} × ${answer.number2} = ${answer.result}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
  );
}
