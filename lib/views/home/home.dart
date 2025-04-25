import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:math_app/views/Practice/practice_screen.dart';
import 'package:math_app/views/ads/ads_screen.dart';
import 'package:math_app/views/calculator/calculator_screen.dart';
import 'package:math_app/views/change_language/change_language_screen.dart';
import 'package:math_app/common/widgets/button.dart';
import 'package:math_app/common/widgets/circle_button.dart';
import 'package:math_app/views/settings/settings.dart';
import 'package:math_app/views/testing/test_screen.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';
import 'package:math_app/ultis/t_sizes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> shareApp(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await Share.share(
        'Ứng dụng Math tốt cho trẻ https://play.google.com/store/apps/details?id=vn.techlead.app.mathapp'
            .tr(),
        subject: 'Ứng dụng Math'.tr(),
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Chia sẻ thành công'.tr())),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Lỗi chia sẻ ứng dụng:'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool isMultiplication = settingsProvider.settings.isMultiplication;
    final int processingMul = settingsProvider.settings.processingMul;
    final int processingDivison = settingsProvider.settings.processingDivison;
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
                      height: 44, // không cần .h vì đã làm ở cirlebutton
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
                    'Bảng tính'.tr(),
                    style: TextStyle(
                      fontSize: TSizes.s32.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'cửu chương'.tr(),
                    style: TextStyle(
                      fontSize: TSizes.s32.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: TSizes.pd50.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BuidlCircleButon(
                          isSelected: isMultiplication,
                          operation: 'A x B',
                          name: '$processingMul%',
                          value: 0.2,
                        ),
                        SizedBox(width: 23.w),
                        BuidlCircleButon(
                          value: 0,
                          isSelected: !isMultiplication,
                          operation: 'A : B',
                          name: '$processingDivison%',
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
                          onPressed: () => shareApp(context),
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

// ignore: must_be_immutable
class BuidlCircleButon extends StatelessWidget {
  bool isSelected;
  String operation;
  String name;
  double value;
  BuidlCircleButon({
    super.key,
    required this.isSelected,
    required this.operation,
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    bool isMultiplication = settingsProvider.settings.isMultiplication;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 126.h,
          width: 126.h,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2,
            backgroundColor: isSelected ? Colors.green[50] : TColors.yellow,
            color: isSelected ? TColors.innerGreen : TColors.yellow1,
          ),
        ),
        GestureDetector(
          onTap: () {
            settingsProvider.updateMode(!isMultiplication);
          },
          child: Container(
            height: 100.h,
            width: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? TColors.innerGreen : Colors.white,
              border: Border(
                bottom: BorderSide(color: TColors.backgroundBrown, width: 2.w),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  operation,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 22.sp,
                  ),
                ),
                Text(
                  isSelected ? name : "",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
