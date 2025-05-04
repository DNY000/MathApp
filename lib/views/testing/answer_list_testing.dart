import 'package:easy_localization/easy_localization.dart';
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
      appBar: TAppbar(name: 'Danh sách câu trả lời'.tr(), showBack: true),
      body: Padding(
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
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: TColors.yellow, width: 3.w),
            ),
          ),

          margin: EdgeInsets.all(12.r),
          child: ListView.builder(
            primary: true,
            padding: EdgeInsets.all(16.r),

            itemCount: list.length,
            itemBuilder: (context, index) {
              final answer = list[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    answer.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: answer.isCorrect ? Colors.green : Colors.red,
                    size: 20.w,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: '${answer.number1} : ${answer.number2} = ',
                        ),
                        TextSpan(
                          text: '${answer.selectedAnswer}',
                          style: TextStyle(
                            color: answer.isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.w),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
