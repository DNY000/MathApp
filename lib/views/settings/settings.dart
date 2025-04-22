import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/t_appbar.dart';
import 'package:math_app/views/settings/container_setting.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF3),
      appBar: TAppbar(name: 'Cài đặt'.tr(), showBack: true),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chế độ
                  ContainerSetting(
                    height: 80.h,
                    padding: EdgeInsets.only(left: 17.w),
                    radius: 14.r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Chế độ'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 16.w),

                        _modeButton(
                          'A x B = ?',
                          isActive: settings.isMultiplication,
                          onTap: () => settingsProvider.updateMode(true),
                        ),
                        SizedBox(width: 21.w),
                        _modeButton(
                          'A : B = ?',
                          isActive: !settings.isMultiplication,
                          onTap: () => settingsProvider.updateMode(false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  //Khoảng kết quả
                  ContainerSetting(
                    height: 116.h,
                    padding: EdgeInsets.only(top: 12.h, left: 16.w),
                    radius: 12.r,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 17.h),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Khoảng kết quả'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            _customCheckbox(
                              settings.checkNumberRange,
                              onChanged:
                                  (value) => settingsProvider
                                      .updateCheckNumberRange(value),
                            ),
                            Text('Từ'.tr(), style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 25.w),
                            _inputBox(
                              enable: settings.checkNumberRange,
                              settings.resultRange.start.toInt().toString(),
                              onChanged: (value) {
                                final start = int.tryParse(value) ?? 1;
                                settingsProvider.updateResultRange(
                                  RangeValues(
                                    start.toDouble(),
                                    settings.resultRange.end,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 17.w),
                            Text('Đến'.tr(), style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 11.w),
                            _inputBox(
                              enable: settings.checkNumberRange,
                              settings.resultRange.end.toInt().toString(),
                              onChanged: (value) {
                                final end = int.tryParse(value) ?? 90;
                                settingsProvider.updateResultRange(
                                  RangeValues(
                                    settings.resultRange.start,
                                    end.toDouble(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  //Khoảng số
                  ContainerSetting(
                    height: 116.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    radius: 14.r,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 19.h),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Khoảng số'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Từ'.tr(), style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 11.w),
                            _inputBox(
                              settings.numberRange.start.toInt().toString(),
                              onChanged: (value) {
                                final start = int.tryParse(value) ?? 1;
                                settingsProvider.updateNumberRange(
                                  RangeValues(
                                    start.toDouble(),
                                    settings.numberRange.end,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 17.w),
                            Text('đến'.tr(), style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 11.w),
                            _inputBox(
                              settings.numberRange.end.toInt().toString(),
                              onChanged: (value) {
                                final end = int.tryParse(value) ?? 90;
                                settingsProvider.updateNumberRange(
                                  RangeValues(
                                    settings.numberRange.start,
                                    end.toDouble(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // gõ câu trả lời
                  ContainerSetting(
                    height: 108.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    radius: 14.r,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Gõ câu trả lời'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _customCheckbox(
                              settings.checkAnswer,
                              onChanged:
                                  (value) =>
                                      settingsProvider.updateCheckAnswer(value),
                            ),
                            Text(
                              'Kiểm tra'.tr(),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(width: 21.w),
                            Text(
                              'Bắt đầu từ'.tr(),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(width: 8.w),

                            Container(
                              width: 86.w,
                              height: 40.h,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: TColors.borderbrown),
                              ),
                              child: Center(child: Text('20 %')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // hiện khối trong học tập
                  ContainerSetting(
                    height: 130.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    radius: 14.r,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hiện khối trong khi học tập:'.tr(),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            const Spacer(),
                            _customCheckbox(
                              settings.showBlocks,
                              onChanged:
                                  (value) =>
                                      settingsProvider.updateShowBlocks(value),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Text(
                              'Thời gian trả lời (kiểm tra):'.tr(),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(width: 8.w),
                            _inputBox(
                              settings.answerTimeSeconds.toString(),
                              onChanged: (value) {
                                final seconds = int.tryParse(value) ?? 15;
                                settingsProvider.updateAnswerTime(seconds);
                              },
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Giây'.tr(),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: TColors.backgroundBrown,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextButton.icon(
                          onPressed:
                              () => showAlertDialog(context, () {
                                settingsProvider.resetSettings();
                                Navigator.pop(context);
                              }),
                          icon: const Icon(Icons.delete, color: Colors.black),
                          label: Text(
                            'Xóa tiến trình'.tr(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Bạn đã bấm vào đây')),
                          );
                        },
                        child: Text(
                          'Chính sách bảo mật'.tr(),
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showAlertDialog(BuildContext context, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TColors.yellow2,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 24.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: TColors.button,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          title: Text(
            'Bạn có chắc chắn muốn xóa dữ liệu học tập của bạn?',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
            maxLines: 2,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Đóng dialog
                  },
                  child: Container(
                    height: 56.h,
                    width: 125.w,
                    decoration: BoxDecoration(
                      color: TColors.yellow1,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      border: Border.all(
                        color: TColors.borderbrown,
                        width: 0.5.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Hủy bỏ',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    height: 56.h,
                    width: 130.w,
                    decoration: BoxDecoration(
                      color: TColors.backgroundBrown,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      border: Border.all(
                        color: TColors.borderbrown,
                        width: 0.5.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Được chứ',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _modeButton(
    String text, {
    bool isActive = false,
    VoidCallback? onTap,
    final double height = 40,
    final double width = 100,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: width.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? TColors.backgroundBrown : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFFFD24C)),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                  : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _inputBox(
    String value, {
    String? suffix,
    ValueChanged<String>? onChanged,
    bool? enable,
  }) {
    return Container(
      width: 86.w,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TColors.borderbrown),
      ),
      child: Center(
        child: TextFormField(
          enabled: enable,
          initialValue: value,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true, // thu gọn các thành phân  bên trong
            suffixText: suffix,
            suffixStyle: TextStyle(fontSize: 14.sp),
          ),

          textAlignVertical: TextAlignVertical.center,

          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _customCheckbox(bool isChecked, {ValueChanged<bool>? onChanged}) {
    return GestureDetector(
      onTap: () => onChanged?.call(!isChecked),
      child: Container(
        width: 24.w,
        height: 24.h,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: isChecked ? TColors.backgroundBrown : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFFFFD24C), width: 2),
        ),
        child:
            isChecked
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
      ),
    );
  }
}

class CustomFormField extends StatelessWidget {
  const CustomFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
