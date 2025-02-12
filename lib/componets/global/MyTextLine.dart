// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import '/manager/MyTheme.dart';
import 'MyContentBlock.dart';
import 'MyGestureDetector.dart';
import 'MyScrollView.dart';
import 'MySvg.dart';
import 'MyText.dart';

class MySelectTextLine extends StatelessWidget {
  final String? svgName;
  final void Function()? onTap;
  final String text; // 文本内容
  final bool selected; // 是否选中

  const MySelectTextLine(
    this.text, {
    super.key,
    this.selected = false,
    this.svgName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentWidget = Padding(
      padding: const MyEdgeInsets.only(left: 25, right: 25),
      child: MySizedBox(
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MySizedBox(
              height: 70,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (null != svgName)
                    Padding(
                      padding: const MyEdgeInsets.only(right: 25),
                      child: MySvg(
                        svgName: svgName!,
                        size: 60.r,
                        color: (selected)
                            ? MyGlobalStoreBase.theme_s.mytheme.primaryColor
                            : MyGlobalStoreBase.theme_s.mytheme.textCrossColor,
                      ),
                    ),
                  (selected)
                      ? MyTextMain(
                          text,
                          style: const MyTextMainStyle(
                            rFontSize: 45,
                          ),
                        )
                      : MyTextCross(text)
                ],
              ),
            ),
            Padding(
              padding: const MyEdgeInsets.only(top: 10),
              child: MySizedBox(
                height: 12,
                width: 100,
                child: selected
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: MyGlobalStoreBase.theme_s.mytheme.primaryColor,
                          borderRadius: const MyBorderRadius(MyRadius(6)),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
    if (null != onTap) {
      return MyGestureDetector(
        onTap: onTap,
        child: contentWidget,
      );
    } else {
      return contentWidget;
    }
  }
}

class MySelectTextLineList<T> extends StatelessWidget {
  final List<T> list;
  final T? selectValue;
  final String Function(T data) toName;
  final void Function(T data) onTap;

  late final List<MySelectTextLine> textLineList;

  MySelectTextLineList({
    super.key,
    required this.list,
    required this.toName,
    required this.onTap,
    required this.selectValue,
  }) {
    textLineList = List.generate(
      list.length,
      (index) {
        final item = list[index];
        return MySelectTextLine(
          toName(item),
          selected: (selectValue == item),
          onTap: () => onTap(item),
        );
      },
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MySizedBox(
      height: 100,
      width: double.infinity,
      child: MyScrollView(
        children: textLineList,
      ),
    );
  }
}

class MySelectTextItem extends StatelessWidget {
  final double width;
  final String text;
  final bool selected;
  final void Function()? onTap;
  final bool isInContent;

  const MySelectTextItem({
    super.key,
    required this.width,
    required this.text,
    this.onTap,
    this.selected = false,
    this.isInContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = 150.r;
    return MyGestureDetector(
      onTap: onTap,
      child: selected
          ? MySettingContentBlock(
              height: height,
              width: width,
              backgroundColor: isInContent
                  ? MyGlobalStoreBase.theme_s.mytheme.backgroundColor
                  : null,
              margin: const MyEdgeInsets.only(top: 15, bottom: 15),
              padding: const MyEdgeInsets.only(left: 15, right: 15),
              borderRadius: MyBorderRadius.circularRInt(20),
              child: Row(
                children: [
                  Container(
                    height: height / 2,
                    width: 16.r,
                    margin: const MyEdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: MyColors_e.blue_tianyi,
                      borderRadius: MyBorderRadius.circularRInt(10),
                    ),
                  ),
                  Expanded(
                    child: MyTextMain(
                      text,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: height,
              width: width,
              child: Row(
                children: [
                  const MySizedBox(width: 46),
                  MyTextCross(
                    text,
                    textAlign: TextAlign.left,
                    style: const MyTextCrossStyle(
                      rFontSize: 45,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class MyAdaptSelectText<T> extends StatelessWidget {
  final List<T> list;
  final T? selectValue;
  final bool isColumn;
  final bool isInContent;
  final String Function(T data) toName;
  final void Function(T data) onTap;
  final double itemWidth;

  late final List<MySelectTextLine> textLineList;
  late final List<MySelectTextItem> textItemList;

  MyAdaptSelectText({
    super.key,
    required this.list,
    required this.toName,
    required this.onTap,
    required this.isColumn,
    required this.itemWidth,
    required this.selectValue,
    this.isInContent = false,
  }) {
    if (isColumn) {
      textLineList = List.generate(
        list.length,
        (index) {
          final item = list[index];
          return MySelectTextLine(
            toName(item),
            selected: (selectValue == item),
            onTap: () => onTap(item),
          );
        },
        growable: false,
      );
    } else {
      textItemList = List.generate(
        list.length,
        (index) {
          final item = list[index];
          return MySelectTextItem(
            text: toName(item),
            isInContent: isInContent,
            selected: (selectValue == item),
            onTap: () => onTap(item),
            width: itemWidth,
          );
        },
        growable: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isColumn) {
      return MySizedBox(
        height: 100,
        width: double.infinity,
        child: MyScrollView(
          children: textLineList,
        ),
      );
    } else {
      return MyScrollView(
        scrollDirection: Axis.vertical,
        center: false,
        padding: EdgeInsets.zero,
        children: textItemList,
      );
    }
  }
}

class MyTextInnerLineStyle extends MyTextStyle {
  const MyTextInnerLineStyle({
    super.rFontSize,
    super.fontSize,
    super.shadows,
    super.color,
    super.fontWeight,
  });

  @override
  Color? get color =>
      super.color ?? MyGlobalStoreBase.theme_s.mytheme.textTitleColor;

  @override
  double? get fontSize => super.fontSize ?? MyTextInnerLine.defFontSize;

  @override
  FontWeight? get fontWeight =>
      super.fontWeight ?? MyTextInnerLine.defFontWeight;
}

class MyTextInnerLine extends StatelessWidget {
  static const defFontWeight = MyTextCross.defFontWeight;
  static const defRFontSize = 60;
  static double get defFontSize => defRFontSize.sp;

  final TextStyle? style;
  final int appendLineRWidth;
  // 文本内容
  final String text;
  final TextAlign textAlign;
  final String? svgName;
  final String? svgImg;

  const MyTextInnerLine(
    this.text, {
    super.key,
    this.svgImg,
    this.svgName,
    this.appendLineRWidth = 0,
    this.textAlign = TextAlign.left,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Padding(
      padding: EdgeInsets.only(
        left: appendLineRWidth.r / 2,
        right: appendLineRWidth.r / 2,
      ),
      child: MyTextMain(
        text,
        style: style ?? const MyTextInnerLineStyle(),
        textAlign: textAlign,
      ),
    );
    final reWidget = CustomPaint(
      painter: const _LinePainter(),
      child: (null != svgName)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MySvg(
                  svgName: svgName!,
                  color: MyGlobalStoreBase.theme_s.mytheme.textMainColor,
                  size: 70.r,
                ),
                textWidget,
              ],
            )
          : (null != svgImg)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MySvgImage(
                      svgName: svgImg!,
                      size: 70.r,
                    ),
                    textWidget,
                  ],
                )
              : textWidget,
    );
    if (textAlign == TextAlign.left) {
      return Align(
        alignment: Alignment.centerLeft,
        child: reWidget,
      );
    }
    return reWidget;
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MyGlobalStoreBase.theme_s.mytheme.textTitleBackgroundColor
      ..strokeWidth = 40.r
      ..strokeCap = StrokeCap.round; // 笔触设置为圆角
    canvas.drawLine(
      Offset(0, size.height - 16.r),
      Offset(size.width, size.height - 16.r),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
