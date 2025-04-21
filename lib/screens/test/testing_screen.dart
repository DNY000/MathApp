import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/screens/Practice/practice_screen.dart';
import 'package:math_app/screens/test/test_screen.dart';
import 'package:math_app/ultis/colors.dart';

class TestingScreen extends StatelessWidget {
  const TestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(name: 'Kiểm tra', showBack: true),
      body: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 46.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Manhinhnhap(showRatingBar: false),
            SizedBox(height: 104.h),
            BanPhim(),
          ],
        ),
      ),
    );
  }
}
