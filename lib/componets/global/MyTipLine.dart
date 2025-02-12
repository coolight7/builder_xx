// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:refreshed/refreshed.dart';
import 'MyScreenUtil.dart';
import 'MySvg.dart';
import 'MyText.dart';
import '/manager/MyTheme.dart';

class MyTipLine extends StatelessWidget {
  /// 显示文本内容
  final String text;

  /// 开头图标名称
  final String? leaderSvgName;

  /// 显示时长
  final Duration? duration;

  /// 点击事件
  final List<Widget>? actions;

  final RxBool? isShow;

  const MyTipLine({
    super.key,
    required this.text,
    this.leaderSvgName,
    this.duration,
    this.actions,
    this.isShow,
  });

  @override
  Widget build(BuildContext context) {
    final reWidget = Container(
      height: 100.r,
      padding: const MyEdgeInsets.only(left: 30, right: 30),
      decoration: BoxDecoration(
        border: Border.all(
          color: MyColors_e.blue_tianyi,
          width: 1,
        ),
        borderRadius: const MyBorderRadius(MyRadius(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (null != leaderSvgName)
            MySvg(
              svgName: leaderSvgName!,
              size: 70.r,
            ),
          MyTextMain(
            text,
            style: const MyTextMainStyle(
              rFontSize: 42,
            ),
          ),
          if (null != actions) ...actions!,
        ],
      ),
    );
    if (null != isShow) {
      return Obx(() => (isShow!.value) ? reWidget : const SizedBox());
    } else {
      return reWidget;
    }
  }
}
