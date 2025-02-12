// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyScreenUtil.dart';
import 'MySvg.dart';
import 'MyText.dart';
import '/manager/MyTheme.dart';

class MyTag extends StatelessWidget {
  final double? height, width;
  final Widget? leading;
  final String text;
  final Color? textColor, backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final int? rFontSize;

  const MyTag(
    this.text, {
    super.key,
    this.height,
    this.width,
    this.leading,
    this.textColor,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.rFontSize,
  });

  const MyTag.large(
    this.text, {
    super.key,
    this.height,
    this.width,
    this.leading,
    this.textColor,
    this.backgroundColor,
    this.rFontSize,
    this.margin = EdgeInsets.zero,
  }) : padding = const MyEdgeInsets.all(10);

  MyTag.leadSvg(
    String svgName,
    this.text, {
    super.key,
    this.height,
    this.width,
    this.padding,
    this.textColor,
    this.backgroundColor,
    this.rFontSize,
    this.margin,
  }) : leading = Padding(
          padding: (text.isNotEmpty)
              ? const MyEdgeInsets.only(right: 7)
              : EdgeInsets.zero,
          child: MySvg(
            svgName: svgName,
            size: 30.r,
            color: textColor ?? MyColors_e.write,
          ),
        );

  @override
  Widget build(BuildContext context) {
    final textWidget = MyTextCross(
      text,
      textAlign: TextAlign.center,
      style: MyTextCrossStyle(
        color: textColor ?? MyColors_e.write,
        rFontSize: rFontSize ?? 34,
      ),
    );
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: const MyBorderRadius(MyRadius(12)),
        color: backgroundColor ?? MyColors_e.blue_tianyi,
      ),
      padding: padding ??
          const MyEdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 10,
            right: 10,
          ),
      margin: margin ?? const MyEdgeInsets.only(right: 7),
      child: (null != leading)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (null != leading) leading!,
                textWidget,
              ],
            )
          : textWidget,
    );
  }
}

class MyTagContent extends StatelessWidget {
  final Widget? leading;
  final String text;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final int? rFontSize;
  final double? width;

  const MyTagContent(
    this.text, {
    super.key,
    this.leading,
    this.color,
    this.width,
    this.padding,
    this.margin,
    this.rFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.backgroundColorCross,
        borderRadius: const MyBorderRadius(MyRadius(15)),
      ),
      padding: padding ??
          const MyEdgeInsets.only(
            top: 7,
            bottom: 7,
            left: 15,
            right: 15,
          ),
      margin: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (null != leading) leading!,
          MyTextMain(
            text,
            style: MyTextMainStyle(
              color: color,
              rFontSize: rFontSize ?? 36,
            ),
          )
        ],
      ),
    );
  }
}
