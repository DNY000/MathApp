import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(name: "Remove ads", showBack: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 32.h),
            child: Center(
              child: SizedBox(
                height: 70.h,
                width: 70.w,
                child: Image.asset(TImage.ads1, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Text(
              'Select a plan that’s right for you',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(height: 41.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 211.h,
              width: 343.w,
              decoration: BoxDecoration(
                boxShadow: [],
                border: Border.all(width: 1.5.w, color: TColors.borderbrown),
                borderRadius: BorderRadius.all(Radius.circular(16.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: TColors.backgroundBrown,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24.w),
                        Image.asset(TImage.vuongmien),
                        SizedBox(width: 12.w),
                        Text(
                          'Once and for all',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      r'5$',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w700,
                        color: TColors.textBack,
                      ),
                    ),
                  ),
                  SizedBox(height: 11.h),
                  Center(
                    child: SizedBox(
                      height: 40.h,
                      width: 135.w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFFE1FFEC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(19.r),
                            ),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Most popular',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF73C08F),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Center(
                    child: Text(
                      'Pay once to remove ads forever',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 124.h,
              width: 343.w,
              decoration: BoxDecoration(
                boxShadow: [],
                border: Border.all(width: 1.5.w, color: TColors.borderbrown),
                borderRadius: BorderRadius.all(Radius.circular(16.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24.w),
                        Image.asset(TImage.video),
                        SizedBox(width: 12.w),
                        Text(
                          'Daily',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: TColors.borderbrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'You watch an ad to disable all ads on one day',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: TColors.textBack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
