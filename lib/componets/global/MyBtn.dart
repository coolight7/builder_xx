// ignore_for_file: file_names, camel_case_types, constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';
import 'package:util_xx/util_xx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:refreshed/refreshed.dart';
import 'MyAnimated.dart';
import 'MyScrollView.dart';
import 'MyText.dart';
import '/manager/MyTheme.dart';
import 'MyGestureDetector.dart';
import 'MyScreenUtil.dart';
import 'MySvg.dart';

/// 按钮
class MyBtn extends StatelessWidget {
  // 相对比例大小
  static const int defRelativeSize = 128;
  static const int defRelativeSimpleSize = 72;
  static const int defRelativeFullSize = 144;

  /// 运行时计算大小
  static double get defSize => defRelativeSize.r;
  static double get defSimpleSize => defRelativeSimpleSize.r;
  static double get defFullSize => defRelativeFullSize.r;

  final BoxShape shape;
  final bool isInContentBlock;
  final double? size; //大小
  final String? svgName, svgImg; //图标名称
  final String? text; //文本
  final bool selected, shadow;
  final void Function()? onTap; // 点击事件
  final Future<void> Function()? onAsyncTap;
  final MyRxObj_c<bool>? isLoading;
  final Color? color;
  final bool showDisableColor;
  final MyAnimatedLevel_e switchAnimateLevel;

  const MyBtn({
    super.key,
    this.size,
    this.svgName,
    this.svgImg,
    this.onTap,
    this.text,
    this.color,
    this.shadow = true,
    this.selected = false,
    this.shape = BoxShape.rectangle,
    this.isInContentBlock = false,
    this.onAsyncTap,
    this.isLoading,
    this.showDisableColor = true,
    this.switchAnimateLevel = MyAnimatedLevel_e.Medium,
  }) : assert((null == onAsyncTap || null != isLoading));

  /// 简单按钮
  const MyBtn.simple({
    super.key,
    this.size,
    this.svgName,
    this.svgImg,
    this.isInContentBlock = false,
    this.text,
    this.color,
    this.onTap,
    this.onAsyncTap,
    this.isLoading,
    this.showDisableColor = true,
    this.switchAnimateLevel = MyAnimatedLevel_e.Medium,
  })  : assert((null == onAsyncTap || null != isLoading)),
        selected = false,
        shadow = false,
        shape = BoxShape.rectangle;

  // 如果 [onAsyncTap] 非空，将自动生成 [isLoading]
  MyBtn.loading({
    super.key,
    this.size,
    this.svgName,
    this.svgImg,
    this.onTap,
    this.text,
    this.color,
    this.selected = false,
    this.shadow = true,
    this.shape = BoxShape.rectangle,
    this.isInContentBlock = false,
    this.onAsyncTap,
    this.showDisableColor = true,
    MyRxObj_c<bool>? isLoading,
    this.switchAnimateLevel = MyAnimatedLevel_e.Medium,
  }) : isLoading =
            isLoading ?? ((null != onAsyncTap) ? MyRxObj_c(false) : null);

  TextStyle defTextStyle(Color? color) {
    return MyTextCrossStyle(
      color: color,
      rFontSize: 45,
    );
  }

  Future<void> onAsyncDo() async {
    if (false == isLoading!.value) {
      isLoading!.value = true;
      await onAsyncTap!();
      isLoading!.value = false;
    }
  }

  Widget buildDetail(
    double width,
    double height,
    BoxDecoration? boxDecoration,
    Widget child,
  ) {
    if (null != boxDecoration) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: boxDecoration,
          child: child,
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: child,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? MyBtn.defSize;
    final onTapDo = (null != onAsyncTap) ? onAsyncDo : onTap;
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    List<Widget> childs = [];
    Color? color_use = color; //图标/文本颜色
    if (null == color) {
      if (selected) {
        // 选中状态按钮
        color_use = theme.btnSelectContentColor;
      } else if (shadow) {
        // 普通按钮
        color_use = theme.btnContentColor;
      } else {
        // 简单按钮
        color_use = theme.btnSimpleContentColor;
      }
      if (showDisableColor && null == onTapDo) {
        // 判断是否禁用
        color_use = theme.btnDisableContentColor;
      }
    }

    double width = 0;
    if (null != svgName || null != svgImg) {
      //添加图标
      if (null != svgName) {
        childs.add(
          SizedBox(
            width: size / 2,
            child: MySvg(
              svgName: svgName!,
              size: size / 2,
              color: color_use,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (null != svgImg) {
        childs.add(
          SizedBox(
            width: size / 2,
            child: MySvgImage(
              svgName: svgImg!,
              size: size / 2,
            ),
          ),
        );
      }
      if (shadow) {
        width = size;
      } else {
        width = size / 2 + 20.r;
      }
    }
    if (null != text) {
      //添加文本
      if (childs.isNotEmpty) {
        childs.add(const MySizedBox(width: 20));
      }
      childs.add(
        Text(
          text!,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: defTextStyle(color_use!),
        ),
      );
      width += text!.length * size / 2;
    }
    BoxDecoration? boxDecoration;
    if (selected) {
      // 选中状态按钮
      boxDecoration = theme.btnSelectDecoration?.call(
        size,
        width,
        shape,
        isInContentBlock,
      );
    } else if (shadow) {
      // 普通按钮
      boxDecoration = theme.btnDecoration?.call(
        size,
        width,
        shape,
        isInContentBlock,
      );
    } else {
      // 简单按钮
      boxDecoration = theme.btnSimpleDecoration?.call(
        size,
        width,
        shape,
        isInContentBlock,
      );
    }
    assert(childs.isNotEmpty);
    // 根据[childs]数量构建
    final Widget f_contentWidget;
    if (childs.length > 1) {
      f_contentWidget = Row(
        key: const ValueKey("btnContentRow"),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: childs,
      );
    } else {
      f_contentWidget = Center(
        key: const ValueKey("btnContentItem"),
        child: childs[0],
      );
    }
    // 根据是否有 [isLoading] 决定是否构建动画
    late final Widget reAnimateWidget;
    if (null != isLoading) {
      // 包含加载动画
      final content = Obx(() => MyAnimatedBuilder<bool>(
            bindValue: isLoading!.value,
            level: switchAnimateLevel,
            childBuilder: (enable, value) {
              return (true == value)
                  ? Center(
                      child: (null != text)
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              color: color_use ?? MyColors_e.blue_tianyi,
                              size: size,
                            )
                          : LoadingAnimationWidget.fourRotatingDots(
                              color: color_use ?? MyColors_e.blue_tianyi,
                              size: size,
                            ),
                    )
                  : f_contentWidget;
            },
            animatedDetialBuilder: (builder, enable, value) {
              return AnimatedSwitcher(
                key: const ValueKey("loading"), // 修复动画期间被update导致异常的问题
                duration: const Duration(milliseconds: 300),
                child: builder(enable, value),
              );
            },
          ));
      if (Platformxx_c.isLinux) {
        reAnimateWidget = content;
      } else {
        reAnimateWidget = RepaintBoundary(child: content);
      }
    } else {
      // 正常按钮
      reAnimateWidget = f_contentWidget;
    }

    // 构建外框样式
    final Widget detailWidget = buildDetail(
      width,
      size,
      boxDecoration,
      reAnimateWidget,
    );
    // 构建点击事件
    if (null != onTapDo) {
      return MyGestureDetector(
        onTap: onTapDo,
        child: detailWidget,
      );
    } else {
      return detailWidget;
    }
  }

  static Widget build_help({
    required String path,
    bool isInContentBlock = false,
  }) {
    return MyBtn(
      svgName: MySvgNames_e.help,
      text: "使用帮助",
      isInContentBlock: isInContentBlock,
      onTap: () {
        launchUrl(
          Uri.parse(path),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      },
    );
  }
}

class MyFullBtn extends MyBtn {
  static const defPopupBtnMargin = MyEdgeInsets.only(
    top: 30,
    bottom: 30,
    left: 50,
    right: 50,
  );
  final int rLetterSpacing;
  final EdgeInsetsGeometry margin;

  MyFullBtn({
    super.key,
    super.svgName,
    super.svgImg,
    super.onTap,
    super.text,
    super.shadow = true,
    super.selected = true,
    super.shape,
    super.isInContentBlock,
    super.onAsyncTap,
    super.isLoading,
    this.rLetterSpacing = 10,
    this.margin = const MyEdgeInsets.only(
      top: 50,
      bottom: 50,
      left: 30,
      right: 30,
    ),
  }) : super(size: MyBtn.defFullSize);

  MyFullBtn.inContent({
    super.key,
    super.svgName,
    super.svgImg,
    super.onTap,
    super.text,
    super.shadow = true,
    super.selected = true,
    super.shape,
    super.onAsyncTap,
    super.isLoading,
    this.rLetterSpacing = 10,
  })  : margin = EdgeInsets.zero,
        super(
          size: MyBtn.defFullSize,
          isInContentBlock: true,
        );

  MyFullBtn.loading({
    super.key,
    super.svgName,
    super.svgImg,
    super.onTap,
    super.text,
    super.selected = true,
    super.shadow = true,
    super.shape,
    super.isInContentBlock,
    super.onAsyncTap,
    super.isLoading,
    this.rLetterSpacing = 10,
    this.margin = const MyEdgeInsets.only(
      top: 50,
      bottom: 50,
      left: 30,
      right: 30,
    ),
  }) : super.loading(
          size: MyBtn.defFullSize,
        );

  @override
  TextStyle defTextStyle(Color? color) {
    return TextStyle(
      color: color,
      fontSize: 50.sp,
      letterSpacing: rLetterSpacing.r,
      fontFamily: MyGlobalStoreBase.theme_s.defFontFamily,
    );
  }

  @override
  Widget buildDetail(
    double width,
    double height,
    BoxDecoration? boxDecoration,
    Widget child,
  ) {
    if (null != boxDecoration) {
      return Padding(
        padding: margin,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: DecoratedBox(
            decoration: boxDecoration.copyWith(
              borderRadius: const MyBorderRadius(MyRadius(
                MyBtn.defRelativeFullSize ~/ 3,
              )),
            ),
            child: child,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: child,
      );
    }
  }
}

class MyCtrlBtns {
  static Widget buildSetBtns(
    double size,
    void Function(double? size) onSet,
    String Function(double size) getStr, {
    double interval = 1,
    double? littleInterval = 0.1,
    bool isInContentBlock = false,
    String? svgName = MySvgNames_e.speed,
    String? svgImg,
  }) {
    assert(null == svgName || null == svgImg);
    const spaceWidth = MySizedBox(width: 50);
    return MySizedBox(
      height: 200,
      child: MyScrollView(
        children: [
          MyBtn.simple(
            onTap: () {
              onSet(size - interval);
            },
            svgName: MySvgNames_e.subtract,
          ),
          if (null != littleInterval) spaceWidth,
          if (null != littleInterval)
            MyBtn.simple(
              onTap: () {
                onSet(size - littleInterval);
              },
              svgName: MySvgNames_e.subtract_circle,
            ),
          spaceWidth,
          MyBtn(
            onTap: () {
              onSet(null);
            },
            isInContentBlock: isInContentBlock,
            svgName: svgName,
            svgImg: svgImg,
            text: getStr.call(size),
          ),
          if (null != littleInterval) spaceWidth,
          if (null != littleInterval)
            MyBtn.simple(
              onTap: () {
                onSet(size + littleInterval);
              },
              svgName: MySvgNames_e.add_circle_d,
            ),
          spaceWidth,
          MyBtn.simple(
            onTap: () {
              onSet(size + interval);
            },
            svgName: MySvgNames_e.addition,
          ),
        ],
      ),
    );
  }
}
