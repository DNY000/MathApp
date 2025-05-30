import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/views/Practice/practice_screen.dart';
import 'package:provider/provider.dart';

class MultiplicationScreen extends StatelessWidget {
  const MultiplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplicationProvider>(
      builder: (context, multiplication, child) {
        final mul = multiplication.currentMultiplication;
        if (mul == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              ContainerPractice<Multiplication>(operation: mul),
              SizedBox(height: 8.h),
              ChonKetqua(
                currentMultiplication: mul,
                onShowNextMultiplication: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
