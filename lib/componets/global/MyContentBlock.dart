// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyScreenUtil.dart';
import 'MyText.dart';
import 'MyTextLine.dart';

/// 较大范围的按钮
class MyContentButton extends StatelessWidget {
  final Widget? child;
  final double? height, width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;

  const MyContentButton({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.padding,
    this.margin,
    this.alignment,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    var color = MyGlobalStoreBase
        .theme_s.mytheme.contentDecoration.contentButtonBackgroundColor;
    if (null != color && (false == MyGlobalStoreBase.theme_s.useNormalStyle)) {
      color = color.withOpacity(0.7);
    }
    return Container(
      width: width,
      height: height,
      margin: margin ?? const MyEdgeInsets.all(50),
      padding: padding ?? const MyEdgeInsets.all(50),
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const MyBorderRadius(MyRadius(50)),
        color: color,
      ),
      child: child,
    );
  }
}

class MySettingContentBlock extends StatelessWidget {
  final Widget? child;
  final double? height, width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const MySettingContentBlock({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.padding,
    this.margin,
    this.alignment,
    this.child,
    this.backgroundColor,
    this.boxShadow,
  });

  MySettingContentBlock.inContent({
    super.key,
    this.height,
    this.width = double.infinity,
    this.alignment,
    this.child,
    this.boxShadow,
    this.margin,
    this.padding,
    this.borderRadius,
  }) : backgroundColor = MyGlobalStoreBase.theme_s.mytheme.backgroundColor;

  const MySettingContentBlock.miniMargin({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.padding,
    this.alignment,
    this.child,
    this.backgroundColor,
    this.boxShadow,
  }) : margin = const MyEdgeInsets.all(30);

  const MySettingContentBlock.miniPadding({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.margin,
    this.alignment,
    this.child,
    this.backgroundColor,
    this.boxShadow,
  }) : padding = const MyEdgeInsets.all(30);

  const MySettingContentBlock.miniExtend({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.alignment,
    this.child,
    this.backgroundColor,
    this.boxShadow,
  })  : padding = const MyEdgeInsets.all(30),
        margin = const MyEdgeInsets.all(30);

  MySettingContentBlock.btnInContent({
    super.key,
    this.height,
    this.width = double.infinity,
    this.alignment,
    this.child,
    this.boxShadow,
    this.margin = const MyEdgeInsets.only(right: 15),
    this.padding = const MyEdgeInsets.all(15),
    this.borderRadius = const MyBorderRadius(MyRadius(30)),
  }) : backgroundColor = MyGlobalStoreBase.theme_s.mytheme.backgroundColor;

  @override
  Widget build(BuildContext context) {
    var useBackgroundColor = backgroundColor;
    if (null == useBackgroundColor) {
      useBackgroundColor = MyGlobalStoreBase
          .theme_s.mytheme.contentDecoration.contentBlockSettingColor;
      if (null != useBackgroundColor &&
          (false == MyGlobalStoreBase.theme_s.useNormalStyle)) {
        useBackgroundColor = useBackgroundColor.withOpacity(0.7);
      }
    }
    return Container(
      width: width,
      height: height,
      margin: margin ?? const MyEdgeInsets.all(50),
      padding: padding ?? const MyEdgeInsets.all(50),
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const MyBorderRadius(MyRadius(50)),
        color: useBackgroundColor,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

class MySettingTitleContentBlock extends StatelessWidget {
  static const defMargin = MyEdgeInsets.only(
    left: 50,
    right: 50,
    top: 20,
    bottom: 20,
  );
  final String title;
  final String? depict;
  final Widget child;
  final Widget? space;
  final double? height, width;
  final int? appendLineRWidth;
  final EdgeInsetsGeometry? padding, margin;
  final Color? backgroundColor;
  final String? svgName;
  final String? svgImg;

  const MySettingTitleContentBlock({
    required this.title,
    required this.child,
    super.key,
    this.svgName,
    this.svgImg,
    this.space,
    this.height,
    this.width,
    this.appendLineRWidth,
    this.padding,
    this.margin,
    this.depict,
    this.backgroundColor,
  });

  const MySettingTitleContentBlock.miniMargin({
    required this.title,
    required this.child,
    super.key,
    this.svgName,
    this.svgImg,
    this.space,
    this.height,
    this.width,
    this.appendLineRWidth,
    this.padding,
    this.depict,
    this.backgroundColor,
  }) : margin = const MyEdgeInsets.only(
          left: 30,
          right: 30,
          top: 20,
          bottom: 20,
        );

  const MySettingTitleContentBlock.miniPadding({
    required this.title,
    required this.child,
    super.key,
    this.svgName,
    this.svgImg,
    this.space,
    this.height,
    this.width,
    this.appendLineRWidth,
    this.margin,
    this.depict,
    this.backgroundColor,
  }) : padding = const MyEdgeInsets.all(30);

  const MySettingTitleContentBlock.miniExtend({
    required this.title,
    required this.child,
    super.key,
    this.svgName,
    this.svgImg,
    this.height,
    this.width,
    this.appendLineRWidth,
    this.depict,
    this.backgroundColor,
  })  : space = const MySizedBox(height: 30),
        padding = const MyEdgeInsets.all(30),
        margin = const MyEdgeInsets.only(
          left: 30,
          right: 30,
          top: 20,
          bottom: 20,
        );

  @override
  Widget build(BuildContext context) {
    var color = MyGlobalStoreBase
        .theme_s.mytheme.contentDecoration.contentBlockSettingColor;
    if (null == backgroundColor &&
        null != color &&
        (false == MyGlobalStoreBase.theme_s.useNormalStyle)) {
      color = color.withOpacity(0.7);
    }
    final space = this.space ?? const MySizedBox(height: 50);
    final showDepict = (null != depict && depict!.isNotEmpty);
    return Container(
      width: width,
      height: height,
      margin: margin ?? MySettingTitleContentBlock.defMargin,
      padding: padding ?? const MyEdgeInsets.all(50),
      decoration: BoxDecoration(
        borderRadius: const MyBorderRadius(MyRadius(50)),
        color: backgroundColor ?? color,
      ),
      child: Column(
        mainAxisSize: (null == height) ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const MyEdgeInsets.only(left: 20, right: 20),
            child: MyTextInnerLine(
              title,
              svgName: svgName,
              svgImg: svgImg,
              appendLineRWidth: appendLineRWidth ?? 20,
            ),
          ),
          if (showDepict) space,
          if (showDepict)
            MyTextCross.multiLine(
              depict!,
              textAlign: TextAlign.left,
            ),
          space,
          child,
        ],
      ),
    );
  }
}
