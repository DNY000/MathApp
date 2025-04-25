import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/core/shared_preferences/shared_prefs.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  late bool checkVN;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    checkVN = locale.languageCode == 'vi';
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _changeLanguage(Locale locale, String code) async {
    await context.setLocale(locale);
    await SharedPrefs.instance.save<String>('app_language', code);
    setState(() {
      checkVN = (locale.languageCode == 'vi');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(name: 'Ngôn ngữ'.tr(), showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: () => _changeLanguage(const Locale('en', 'US'), 'en-US'),
              child: _buildLanguageOption(
                isSelected: !checkVN,
                image: TImage.coanh,
                text: 'Tiếng anh'.tr(),
              ),
            ),
            GestureDetector(
              onTap: () => _changeLanguage(const Locale('vi', 'VN'), 'vi-VN'),
              child: _buildLanguageOption(
                isSelected: checkVN,
                image: TImage.covietnam,
                text: 'Tiếng Việt'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required bool isSelected,
    required String image,
    required String text,
  }) {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isSelected ? TColors.button : Colors.white,
        boxShadow: [
          BoxShadow(offset: Offset(0, 3), color: TColors.backgroundBrown),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image),
          SizedBox(height: 8.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: TColors.textBack,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
