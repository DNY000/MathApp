import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';

class AnswerListTesting extends StatelessWidget {
  final List<AnswerRecord> list;
  const AnswerListTesting({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.yellow2,
      appBar: TAppbar(name: 'Danh sách câu trả lời', showBack: true),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: ListView.builder(
            primary: true,
            padding: EdgeInsets.all(16.w),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final answer = list[index];
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Phép tính và câu trả lời của người dùng
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '${answer.number1} × ${answer.number2} = ',
                          ),
                          TextSpan(
                            text: '${answer.selectedAnswer}',
                            style: TextStyle(
                              color:
                                  answer.isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kết quả đúng/sai
                    Row(
                      children: [
                        if (!answer.isCorrect)
                          Text(
                            '(${answer.result})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        SizedBox(width: 8.w),
                        Icon(
                          answer.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: answer.isCorrect ? Colors.green : Colors.red,
                          size: 20.w,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
