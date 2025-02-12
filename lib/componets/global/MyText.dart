// ignore_for_file: file_names, non_constant_identifier_names, constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import '/manager/MyTheme.dart';
import 'package:text_scroll/text_scroll.dart';

import 'MyBtn.dart';
import 'MyScrollView.dart';

enum MyTextShadowStyle_e {
  None, // 无
  BlackShadow, // 黑色阴影
  BlackShimmer,
  LightShadow,
  LightShimmer, // 亮色微光
}

class MyTextShadowStyle_c {
  static int myTextShadowStyleToInt(MyTextShadowStyle_e style) {
    switch (style) {
      case MyTextShadowStyle_e.None:
        return 1;
      case MyTextShadowStyle_e.BlackShadow:
        return 10;
      case MyTextShadowStyle_e.BlackShimmer:
        return 11;
      case MyTextShadowStyle_e.LightShimmer:
        return 20;
      case MyTextShadowStyle_e.LightShadow:
        return 21;
    }
  }

  static MyTextShadowStyle_e? intToMyTextShadowStyle(int? style) {
    switch (style) {
      case 1:
        return MyTextShadowStyle_e.None;
      case 10:
        return MyTextShadowStyle_e.BlackShadow;
      case 11:
        return MyTextShadowStyle_e.BlackShimmer;
      case 20:
        return MyTextShadowStyle_e.LightShimmer;
      case 21:
        return MyTextShadowStyle_e.LightShadow;
    }
    return null;
  }

  static Widget buildSetTextShadowStyle(
    MyTextShadowStyle_e textShadowStyle,
    void Function(MyTextShadowStyle_e) onSet, {
    bool isInContent = false,
  }) {
    const spaceWidth = MySizedBox(width: 30);
    return MyScrollView(
      children: [
        spaceWidth,
        MyBtn(
          onTap: () {
            onSet(MyTextShadowStyle_e.None);
          },
          text: " 无 ",
          isInContentBlock: isInContent,
          selected: MyTextShadowStyle_e.None == textShadowStyle,
        ),
        spaceWidth,
        MyBtn(
          onTap: () {
            onSet(MyTextShadowStyle_e.BlackShadow);
          },
          text: "暗色阴影",
          isInContentBlock: isInContent,
          selected: textShadowStyle == MyTextShadowStyle_e.BlackShadow,
        ),
        spaceWidth,
        MyBtn(
          onTap: () {
            onSet(MyTextShadowStyle_e.BlackShimmer);
          },
          text: "暗色微光",
          isInContentBlock: isInContent,
          selected: textShadowStyle == MyTextShadowStyle_e.BlackShimmer,
        ),
        spaceWidth,
        MyBtn(
          onTap: () {
            onSet(MyTextShadowStyle_e.LightShadow);
          },
          text: "亮色阴影",
          isInContentBlock: isInContent,
          selected: textShadowStyle == MyTextShadowStyle_e.LightShadow,
        ),
        spaceWidth,
        MyBtn(
          onTap: () {
            onSet(MyTextShadowStyle_e.LightShimmer);
          },
          text: "亮色微光",
          isInContentBlock: isInContent,
          selected: textShadowStyle == MyTextShadowStyle_e.LightShimmer,
        ),
        spaceWidth,
      ],
    );
  }

  static List<Shadow>? getTextShadow(MyTextShadowStyle_e style) {
    switch (style) {
      case MyTextShadowStyle_e.None:
        return null;
      case MyTextShadowStyle_e.BlackShadow:
        return MyTextMain.defTextShadowItem_blackShadow;
      case MyTextShadowStyle_e.BlackShimmer:
        return MyTextMain.defTextShadowItem_blackShimmer;
      case MyTextShadowStyle_e.LightShadow:
        return MyTextMain.defTextShadowItem_lightShadow;
      case MyTextShadowStyle_e.LightShimmer:
        return MyTextMain.defTextShadowItem_lightShimmer;
    }
  }
}

class MyTextStyle extends TextStyle {
  final int? rFontSize;

  const MyTextStyle({
    this.rFontSize,
    super.fontSize,
    super.shadows,
    super.color,
    super.fontWeight,
  });

  @override
  double? get fontSize => super.fontSize ?? rFontSize?.sp;

  @override
  String? get fontFamily => MyGlobalStoreBase.theme_s.defFontFamily;
}

class MyTextMainStyle extends MyTextStyle {
  const MyTextMainStyle({
    super.rFontSize,
    super.fontSize,
    super.shadows,
    super.color,
    super.fontWeight,
  });

  @override
  Color? get color =>
      super.color ?? MyGlobalStoreBase.theme_s.mytheme.textMainColor;

  @override
  double? get fontSize => super.fontSize ?? MyTextMain.defFontSize;

  @override
  FontWeight? get fontWeight => super.fontWeight ?? MyTextMain.defFontWeight;
}

class MyTextMain extends StatelessWidget {
  static const defFontWeight = FontWeight.w700;
  static const defRFontSize = 50;
  static double get defFontSize => defRFontSize.sp;

  static const defTextShadowItem_blackShadow = [
    MyShadow(
      color: MyColors_e.black,
      blurRadius: 10,
      offset: MyOffset(4, 4),
    ),
  ];
  static const defTextShadowItem_blackShimmer = [
    MyShadow(
      color: MyColors_e.black,
      blurRadius: 6,
    ),
  ];
  static const defTextShadowItem_lightShadow = [
    MyShadow(
      color: MyColors_e.write,
      blurRadius: 10,
      offset: MyOffset(4, 4),
    ),
  ];
  static const defTextShadowItem_lightShimmer = [
    MyShadow(
      color: MyColors_e.write,
      blurRadius: 6,
    ),
  ];

  final String data;
  final int? maxLine;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  final TextStyle? style;

  const MyTextMain(
    this.data, {
    super.key,
    this.maxLine = 1,
    this.textAlign = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
    this.style,
  });

  const MyTextMain.thin(
    this.data, {
    super.key,
    this.maxLine = 1,
    this.textAlign = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
  }) : style = const MyTextMainStyle(
          fontWeight: MyTextCross.defFontWeight,
        );

  const MyTextMain.multiLine(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
    this.style,
  })  : overflow = TextOverflow.visible,
        maxLine = null;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLine,
      textAlign: textAlign,
      overflow: overflow,
      style: style ?? const MyTextMainStyle(),
    );
  }
}

class MyTextCrossStyle extends MyTextStyle {
  const MyTextCrossStyle({
    super.rFontSize,
    super.fontSize,
    super.shadows,
    super.color,
    super.fontWeight,
  });

  const MyTextCrossStyle.mainSize({
    super.shadows,
    super.color,
    super.fontWeight,
  }) : super(rFontSize: MyTextMain.defRFontSize);

  @override
  Color? get color =>
      super.color ?? MyGlobalStoreBase.theme_s.mytheme.textCrossColor;

  @override
  double? get fontSize => super.fontSize ?? MyTextCross.defFontSize;

  @override
  FontWeight? get fontWeight => super.fontWeight ?? MyTextCross.defFontWeight;
}

class MyTextCross extends StatelessWidget {
  static const defFontWeight = FontWeight.w400;
  static const int defRFontSize = 42;
  static double get defFontSize => defRFontSize.sp;

  final String data;
  final int? maxLine;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextStyle? style;

  const MyTextCross(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
    this.maxLine = 1,
    this.overflow = TextOverflow.ellipsis,
    this.style,
  });

  const MyTextCross.multiLine(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
    this.style,
  })  : overflow = TextOverflow.visible,
        maxLine = null;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLine,
      textAlign: textAlign,
      overflow: overflow,
      style: style ?? const MyTextCrossStyle(),
    );
  }

  static Widget buildDefEmpty() {
    return const MySizedBox(
      height: 400,
      child: Center(
        child: MyTextCross(
          "『空空如也』",
        ),
      ),
    );
  }
}

/// 文字跑马灯
/// * 当文字太长时以跑马灯方式展示
class MyTextMarquee extends StatelessWidget {
  static final defVelocityFast = Velocity(pixelsPerSecond: Offset(150.r, 0));
  static final defVelocityMiddle = Velocity(pixelsPerSecond: Offset(100.r, 0));
  static final defVelocitySlow = Velocity(pixelsPerSecond: Offset(50.r, 0));

  final String data;
  final TextAlign textAlign;
  final Velocity? velocity;
  final TextStyle? style;

  const MyTextMarquee(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
    this.velocity,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final widget = TextScroll(
      data,
      intervalSpaces: 10,
      velocity: velocity ?? MyTextMarquee.defVelocityMiddle,
      textAlign: textAlign,
      delayBefore: const Duration(seconds: 1),
      pauseBetween: const Duration(seconds: 3),
      fadedBorder: true,
      fadedBorderWidth: 0.05,
      style: style ?? const MyTextCrossStyle(),
    );
    if (textAlign == TextAlign.center) {
      return Center(
        child: widget,
      );
    } else {
      return widget;
    }
  }

  static CrossAxisAlignment? textAlignToCrossAxisAlignment(
      TextAlign? textAlign) {
    if (null != textAlign) {
      switch (textAlign) {
        case TextAlign.left:
          return CrossAxisAlignment.start;
        case TextAlign.right:
          return CrossAxisAlignment.end;
        case TextAlign.center:
          return CrossAxisAlignment.center;
        case TextAlign.start:
          return CrossAxisAlignment.start;
        case TextAlign.end:
          return CrossAxisAlignment.end;
        default:
          break;
      }
    }
    return null;
  }
}
