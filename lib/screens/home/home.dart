import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/screens/Practice/practice_screen.dart';
import 'package:math_app/screens/ads/ads_screen.dart';
import 'package:math_app/screens/calculator/calculator_screen.dart';
import 'package:math_app/screens/change_language/change_language_screen.dart';
import 'package:math_app/common/widgets/button.dart';
import 'package:math_app/common/widgets/circle_button.dart';
import 'package:math_app/core/setting/settings.dart';
import 'package:math_app/screens/test/test_screen.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';
import 'package:math_app/ultis/t_sizes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 62.h, left: 16.w, right: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleButton(
                      height: 44,
                      width: 44,
                      image: TImage.caidat,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(),
                            ),
                          ),
                    ),
                    CircleButton(
                      height: 44,
                      width: 44,
                      image: TImage.vietnam,
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeLanguageScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bảng tính cửu chương'.tr(),
                    style: TextStyle(
                      fontSize: TSizes.s32.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   'cửu chương'.tr(),
                  //   style: TextStyle(
                  //     fontSize: TSizes.s32.h,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 25.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: TSizes.pd50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 96.h,
                          width: 96.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TColors.innerGreen,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'A x B',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                '20%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 23.w),
                        Container(
                          height: 96.h,
                          width: 96.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'A : B',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.sp,
                                  ),
                                ),
                                Text(
                                  '20%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 64.h),
                    ButtonMath(
                      name: 'Bảng Tính'.tr(),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalculatorScreen(),
                            ),
                          ),
                      colors: TColors.button,
                      height: 56,
                    ),
                    SizedBox(height: 20.h),
                    ButtonMath(
                      name: 'Luyện tập'.tr(),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PracticeScreen(),
                            ),
                          ),
                      colors: TColors.button,
                      height: 56,
                    ),
                    SizedBox(height: 20.h),
                    ButtonMath(
                      name: 'Kiểm tra'.tr(),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestScreen(),
                            ),
                          ),
                      colors: TColors.button,
                      height: 56,
                    ),
                    SizedBox(height: 20.h),
                    ButtonMath(
                      name: 'Trò chơi rèn luyện'.tr(),
                      onPressed: () {},
                      colors: TColors.button,
                      height: 56,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        CircleButton(
                          height: 44,
                          width: 44,
                          image: TImage.ads,
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdsScreen(),
                                ),
                              ),
                        ),
                        Spacer(),
                        CircleButton(
                          height: 44,
                          width: 44,
                          image: TImage.dauhoi,
                          onPressed: () {},
                        ),
                        Spacer(),
                        CircleButton(
                          height: 44,
                          width: 44,
                          image: TImage.xucsac,
                          onPressed: () {},
                        ),
                        Spacer(),
                        CircleButton(
                          height: 44,
                          width: 44,
                          image: TImage.chiase,
                          onPressed: () {},
                        ),
                        Spacer(),
                        CircleButton(
                          height: 44,
                          width: 44,
                          image: TImage.like,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
