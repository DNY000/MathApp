import 'package:easy_localization/easy_localization.dart';
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
      appBar: TAppbar(
        name: "Loại bỏ quảng cáo".tr(),
        showBack: true,
        showProcess: false,
        showAction: true,
        actionText: 'khôi phục'.tr(),
      ),
      body: Column(
        children: [
          // CountdownProgress(durationInSeconds: 10, onComplete: () {}),
          // CustomAppBar(title: 'Remove ads', showBack: true, showProcess: false),
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
              'Chọn một kết hoạch phù hợp cho bạn'.tr(),
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
                          'Một lần và mãi mãi'.tr(),
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
                          'Phổ biến'.tr(),
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
                      "Thanh toán một lần để loại bỏ quảng cao mãi mãi".tr(),
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
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 124.h,
              width: 343.w,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 0.5.w,
                    color: TColors.backgroundBrown,
                  ),
                  right: BorderSide(
                    width: 0.5.w,
                    color: TColors.backgroundBrown,
                  ),
                  top: BorderSide(width: 0.5.w, color: TColors.backgroundBrown),
                  bottom: BorderSide(
                    width: 3.5.w,
                    color: TColors.backgroundBrown,
                  ),
                ),
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
                        Image.asset(TImage.video, color: TColors.borderbrown),
                        SizedBox(width: 12.w),
                        Text(
                          'Hằng ngày'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: TColors.borderbrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: TColors.backgroundBrown, thickness: 0.5),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Bạn xem một quảng cáo để tắt tất cả quảng cáo trong một ngày'
                            .tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: TColors.textBack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 60.h),
          SizedBox(
            height: 60.h,
            width: 343.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.backgroundBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Tiếp tục'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: TColors.textBack,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
