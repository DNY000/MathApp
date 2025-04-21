import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  bool checkVN = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(name: 'Ngôn ngữ'.tr(), showBack: true),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  checkVN = !checkVN;
                });
                await context.setLocale(const Locale('en', 'US'));
              },

              child: Container(
                height: 100.h,
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  color: checkVN ? Colors.white : TColors.backgroundBrown,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      color: TColors.backgroundBrown,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(TImage.coanh),
                    SizedBox(height: 8.h),
                    Text(
                      'Tiếng anh'.tr(),
                      style: TextStyle(fontSize: 14, color: TColors.textBack),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  checkVN = !checkVN;
                });
                await context.setLocale(const Locale('vi', 'VN'));
              },

              child: Container(
                height: 100.h,
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  color: checkVN ? TColors.backgroundBrown : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      color: TColors.backgroundBrown,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(TImage.covietnam),
                    SizedBox(height: 8.h),
                    Text(
                      'Tiếng Việt'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: TColors.textBack,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
