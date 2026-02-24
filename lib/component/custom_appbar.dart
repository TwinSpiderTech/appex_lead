import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:appex_lead/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading, trailing, bottom;
  final bool canNavigate;
  final Color? bgColor, titleColor;
  final VoidCallback? onNavigateBack;
  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.onNavigateBack,
    this.bgColor,
    this.canNavigate = true,
    this.bottom,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: AppBar(
        actionsPadding: EdgeInsetsDirectional.all(0),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: (leading != null)
            ? leading
            : canNavigate
            ? IconButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Get.back();
                  onNavigateBack?.call();
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 32,
                  color: colorManager.primaryColor,
                ),
              )
            : SizedBox(),
        backgroundColor: bgColor ?? colorManager.accentColor,
        title: title != null
            ? Text(
                title!,
                style: primaryTextStyle.copyWith(
                  color: titleColor ?? colorManager.whiteColor,
                ),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: preferredSize,
          child: bottom ?? SizedBox(),
        ),

        actions: [trailing ?? SizedBox()],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}
