import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/common/widgets/circle_button.dart';
import 'package:math_app/common/widgets/countdown_progress.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:math_app/ultis/t_image.dart';

class TAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final int processing;
  final bool showProcess;
  final bool showBack;
  final bool showAction;
  final String? actionText;
  const TAppbar({
    super.key,
    required this.name,
    this.processing = 0,
    this.showProcess = false,
    required this.showBack,
    this.showAction = false,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        name,
        style: TextStyle(fontSize: 18.sp, color: TColors.textBack),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1,
      leading:
          showBack
              ? Padding(
                padding: EdgeInsets.all(12.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 36.h, maxWidth: 36.w),
                  child: CircleButton(
                    backgroundColor: TColors.button,
                    height: 36,
                    width: 36,
                    image: TImage.back,

                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
              : null,
      actions: [
        if (showAction)
          Text(actionText ?? '', style: TextStyle(fontSize: 18.sp)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
