// ignore_for_file: camel_case_types, file_names, constant_identifier_names, non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';
import '/componets/global/MyImageBase.dart';
import '/componets/global/MyList.dart';
import '/componets/global/MyScreenUtil.dart';

//颜色枚举
class MyColors_e {
  MyColors_e._();

  static const Color blue_tianyi = Color.fromRGBO(102, 204, 255, 1),
      blue_lite = Color.fromRGBO(186, 226, 244, 1),
      green_lite = Color.fromRGBO(1, 196, 139, 1),
      green_x = Color.fromRGBO(37, 198, 218, 1),
      orange_lite = Color.fromRGBO(255, 171, 119, 1),
      yellow_lite = Color.fromRGBO(255, 225, 119, 1),
      blue_liteX = Color.fromRGBO(124, 196, 229, 1),
      red_lite = Color.fromRGBO(245, 65, 51, 1),
      gold = Color.fromRGBO(255, 255, 0, 1),
      transparent = Colors.transparent,
      write = Colors.white,
      write_xxl = Color.fromRGBO(250, 250, 252, 1),
      write_xxBlue = Color.fromRGBO(247, 248, 252, 1),
      write_xx = Color.fromRGBO(250, 250, 250, 1),
      write_xxx = Color.fromRGBO(252, 252, 252, 1),
      write_x = Color.fromRGBO(242, 242, 249, 1),
      write_xl = Color.fromRGBO(245, 245, 245, 1),
      write_liteX = Color.fromRGBO(237, 240, 249, 1),
      write_lite = Color.fromRGBO(221, 232, 252, 1),
      grey_lite = Color.fromRGBO(163, 180, 206, 1),
      black = Colors.black,
      black_liteX = Color.fromRGBO(50, 50, 50, 1),
      black_liteH = Color.fromRGBO(70, 70, 70, 1),
      black_lite = Color.fromRGBO(101, 109, 120, 1),
      black_liteLite = Color.fromRGBO(130, 140, 170, 1),
      black_x = Color.fromRGBO(47, 54, 62, 1),
      black_xl = Color.fromRGBO(8, 16, 32, 1),
      black_xx = Color.fromRGBO(20, 30, 24, 1),
      pink_lite = Color.fromRGBO(235, 194, 206, 1);

  static const listLeadSvgColors = <Color>[
    Color.fromRGBO(5, 214, 118, 1),
    MyColors_e.blue_tianyi,
    Color.fromRGBO(255, 192, 69, 1),
    MyColors_e.green_x,
    Color.fromRGBO(125, 120, 235, 1),
    Color.fromRGBO(253, 112, 64, 1),
    MyColors_e.blue_liteX,
    MyColors_e.yellow_lite,
  ];

  static Color getListLeadSvgColor(int index) {
    return listLeadSvgColors[index % listLeadSvgColors.length];
  }
}

class MyTheme_c extends ThemeExtension<MyTheme_c> {
  final MyThemeSwitchDecoration_c switchDecoration;
  final MyThemeContentDecoration_c contentDecoration;
  final MyThemeIconDecoration_c iconDecoration;
  final MyThemeProgress_c progressStyle;
  final MyThemeFavoryListDecoration_c favoryListStyle;
  final MyThemeImageStyle_c imageStyle;
  final MyThemeMusicWarp_c musicWarpStyle;

  final Gradient? backgroundGradient;
  final BoxDecoration? Function(
    double height,
    double width,
    BoxShape shape,
    bool isInBlock,
  )? btnDecoration, btnSelectDecoration, btnSimpleDecoration;
  final BoxDecoration? Function(double size, bool isInContent)? inputDecoration;
  final BoxDecoration? Function(bool isSelect)? listBoxItemDecoration;
  final BoxDecoration? Function(bool isSelect)? gridBoxItemDecoration;
  final Widget? Function(MyImageBase widget)? imgDetail;

  final EasyLoadingStyle toastStyle; // 提示框主题色
  final Color? shimmerBaseColor, shimmerHighlightColor, shimmerDecorationColor;

  final Color appbarBackgroundColorCross,
      btnContentColor, // 按钮内容颜色
      btnSimpleContentColor, // 简约按钮的内容颜色
      btnSelectContentColor, // 按钮选中时内容颜色
      btnDisableContentColor, // 按钮禁用提示色
      borderColor, // 默认边框颜色
      backgroundColor, // 背景颜色
      backgroundColorCross, // 第二背景色
      disableColor, // 禁用提示色
      dialogBarrierColor, // 弹窗外的背景色
      dialogBackgroundColor, // 弹窗背景色
      errorColor, // 错误提示色
      iconWaveColor, // 歌曲图波浪颜色
      primaryColor, // 主色调
      shadowDarkColor, // 阴影黑暗部分颜色
      shadowLightColor, // 阴影亮颜色
      textMainColor, // 主要内容字符串颜色
      textTitleColor,
      textTitleBackgroundColor,
      textCrossColor; // 次要内容字符串颜色

  const MyTheme_c({
    this.appbarBackgroundColorCross = MyColors_e.write_xxBlue,
    this.btnDecoration,
    this.btnSelectDecoration,
    this.btnSimpleDecoration,
    this.btnContentColor = MyColors_e.grey_lite,
    this.btnSimpleContentColor = MyColors_e.grey_lite,
    this.btnSelectContentColor = MyColors_e.write,
    this.btnDisableContentColor = MyColors_e.pink_lite,
    this.backgroundGradient,
    this.backgroundColor = MyColors_e.write_x,
    this.backgroundColorCross = MyColors_e.write,
    this.borderColor = MyColors_e.write,
    this.contentDecoration = const MyThemeContentDecoration_c(),
    this.disableColor = MyColors_e.grey_lite,
    this.dialogBarrierColor = const Color.fromRGBO(101, 109, 120, 0.7),
    this.dialogBackgroundColor = MyColors_e.write_xxBlue,
    this.errorColor = MyColors_e.pink_lite,
    this.favoryListStyle = const MyThemeFavoryListDecoration_c(),
    this.gridBoxItemDecoration,
    this.iconDecoration = const MyThemeIconDecoration_c(),
    this.iconWaveColor = const Color.fromRGBO(255, 255, 255, 0.7),
    this.imageStyle = const MyThemeImageStyle_c(),
    this.imgDetail,
    this.inputDecoration,
    this.listBoxItemDecoration,
    this.musicWarpStyle = const MyThemeMusicWarp_c.light(),
    this.primaryColor = MyColors_e.blue_tianyi,
    this.progressStyle = const MyThemeProgress_c(),
    this.switchDecoration = const MyThemeSwitchDecoration_c(),
    this.shadowDarkColor = const Color.fromRGBO(0, 0, 0, 0.1),
    this.shadowLightColor = MyColors_e.write,
    this.shimmerBaseColor = const Color(0x80000000),
    this.shimmerDecorationColor = const Color(0x4D000000),
    this.shimmerHighlightColor = const Color(0x33000000),
    this.textMainColor = const Color.fromRGBO(60, 60, 60, 1),
    this.textTitleColor = const Color.fromRGBO(60, 60, 60, 1),
    this.textTitleBackgroundColor = const Color.fromRGBO(200, 200, 210, 0.2),
    this.textCrossColor = const Color.fromRGBO(150, 150, 150, 1),
    this.toastStyle = EasyLoadingStyle.light,
  });

  @override
  ThemeExtension<MyTheme_c> copyWith({
    EasyLoadingStyle? toastStyle, // 提示框主题色
    Color? appbarBackgroundColorCross,
    Color? btnContentColor, // 按钮内容颜色
    Color? btnSimpleContentColor, // 简约按钮的内容颜色
    Color? btnSelectContentColor, // 按钮选中时内容颜色
    Color? btnDisableContentColor, // 按钮禁用提示色
    Color? borderColor, // 默认边框颜色
    Gradient? backgroundGradient,
    Color? backgroundColor, // 背景颜色
    Color? backgroundColorCross, // 第二背景色
    MyThemeContentDecoration_c? contentDecoration,
    Color? disableColor, // 禁用提示色
    Color? dialogBarrierColor, // 弹窗外的背景色
    Color? dialogBackgroundColor, // 弹窗背景色
    Color? errorColor, // 错误提示色
    MyThemeIconDecoration_c? iconDecoration,
    Color? iconWaveColor, // 歌曲图波浪颜色
    MyThemeProgress_c? progressStyle,
    Color? primaryColor, // 主色调
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    Color? shimmerDecorationColor,
    Color? shadowDarkColor, // 阴影黑暗部分颜色
    Color? shadowLightColor, // 阴影亮颜色
    Color? textMainColor, // 主要内容字符串颜色
    Color? textCrossColor, // 次要内容字符串颜色
    BoxDecoration? Function(double height, double width, BoxShape shape, bool)?
        btnDecoration,
    BoxDecoration? Function(double height, double width, BoxShape shape, bool)?
        btnSelectDecoration,
    BoxDecoration? Function(double height, double width, BoxShape shape, bool)?
        btnSimpleDecoration,
    BoxDecoration? Function(double size, bool isInContent)? inputDecoration,
    BoxDecoration? Function(bool isSelect)? listBoxItemDecoration,
    BoxDecoration? Function(bool isSelect)? gridBoxItemDecoration,
    Widget? Function(MyImageBase widget)? imgDetail,
    BoxDecoration? tabsPageColumnBottomBar,
  }) {
    return MyTheme_c(
      appbarBackgroundColorCross:
          appbarBackgroundColorCross ?? this.appbarBackgroundColorCross,
      btnDecoration: btnDecoration ?? this.btnDecoration,
      btnSelectDecoration: btnSelectDecoration ?? this.btnSelectDecoration,
      btnSimpleDecoration: btnSimpleDecoration ?? this.btnSimpleDecoration,
      btnContentColor: btnContentColor ?? this.btnContentColor,
      btnSimpleContentColor:
          btnSimpleContentColor ?? this.btnSimpleContentColor,
      btnSelectContentColor:
          btnSelectContentColor ?? this.btnSelectContentColor,
      btnDisableContentColor:
          btnDisableContentColor ?? this.btnDisableContentColor,
      borderColor: borderColor ?? this.borderColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundColorCross: backgroundColorCross ?? this.backgroundColorCross,
      contentDecoration: contentDecoration ?? this.contentDecoration,
      disableColor: disableColor ?? this.disableColor,
      dialogBarrierColor: dialogBarrierColor ?? this.dialogBarrierColor,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      errorColor: errorColor ?? this.errorColor,
      iconDecoration: iconDecoration ?? this.iconDecoration,
      iconWaveColor: iconWaveColor ?? this.iconWaveColor,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      imgDetail: imgDetail ?? this.imgDetail,
      listBoxItemDecoration:
          listBoxItemDecoration ?? this.listBoxItemDecoration,
      gridBoxItemDecoration:
          gridBoxItemDecoration ?? this.gridBoxItemDecoration,
      primaryColor: primaryColor ?? this.primaryColor,
      progressStyle: progressStyle ?? this.progressStyle,
      shadowDarkColor: shadowDarkColor ?? this.shadowDarkColor,
      shadowLightColor: shadowLightColor ?? this.shadowLightColor,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerDecorationColor:
          shimmerDecorationColor ?? this.shimmerDecorationColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      textMainColor: textMainColor ?? this.textMainColor,
      textCrossColor: textCrossColor ?? this.textCrossColor,
      toastStyle: toastStyle ?? this.toastStyle,
    );
  }

  @override
  ThemeExtension<MyTheme_c> lerp(
    covariant ThemeExtension<MyTheme_c>? other,
    double t,
  ) {
    if (other is! MyTheme_c) {
      return this;
    }
    return copyWith(
      appbarBackgroundColorCross: Color.lerp(
          appbarBackgroundColorCross, other.appbarBackgroundColorCross, t),
      shimmerBaseColor: Color.lerp(shimmerBaseColor, other.shimmerBaseColor, t),
      shimmerHighlightColor:
          Color.lerp(shimmerHighlightColor, other.shimmerHighlightColor, t),
      shimmerDecorationColor:
          Color.lerp(shimmerDecorationColor, other.shimmerDecorationColor, t),
      btnContentColor: Color.lerp(btnContentColor, other.btnContentColor, t),
      btnSimpleContentColor:
          Color.lerp(btnSimpleContentColor, other.btnSimpleContentColor, t),
      btnSelectContentColor:
          Color.lerp(btnSelectContentColor, other.btnSelectContentColor, t),
      btnDisableContentColor:
          Color.lerp(btnDisableContentColor, other.btnDisableContentColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      backgroundColorCross:
          Color.lerp(backgroundColorCross, other.backgroundColorCross, t),
      disableColor: Color.lerp(disableColor, other.disableColor, t),
      dialogBarrierColor:
          Color.lerp(dialogBarrierColor, other.dialogBarrierColor, t),
      dialogBackgroundColor:
          Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      iconWaveColor: Color.lerp(iconWaveColor, other.iconWaveColor, t),
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      shadowDarkColor: Color.lerp(shadowDarkColor, other.shadowDarkColor, t),
      shadowLightColor: Color.lerp(shadowLightColor, other.shadowLightColor, t),
      textMainColor: Color.lerp(textMainColor, other.textMainColor, t),
      textCrossColor: Color.lerp(textCrossColor, other.textCrossColor, t),
    );
  }

  static ThemeData getBaseTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      cardColor: MyColors_e.write,
      primaryColor: MyColors_e.blue_tianyi, //主内容色调
      primaryColorLight: MyColors_e.grey_lite,
      primaryColorDark: MyColors_e.black_lite,
      focusColor: MyColors_e.write, //按钮选中时内容色
      highlightColor: MyColors_e.blue_tianyi, //按钮选中时的背景色
      disabledColor: MyColors_e.grey_lite, //普通背景色
      scaffoldBackgroundColor: MyColors_e.write_xxBlue,
      secondaryHeaderColor: MyColors_e.write,
      shadowColor: MyColors_e.write,
      splashColor: MyColors_e.transparent,
      splashFactory: InkRipple.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: MyColors_e.blue_tianyi,
        selectionColor: MyColors_e.blue_lite,
        selectionHandleColor: MyColors_e.blue_tianyi,
      ),
      buttonTheme: const ButtonThemeData(
        highlightColor: MyColors_e.transparent,
        splashColor: MyColors_e.transparent,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: MyColors_e.write_xxBlue,
        iconTheme: const IconThemeData(color: MyColors_e.black_liteX),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: MyColors_e.write.withOpacity(0),
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: MyColors_e.write.withOpacity(0),
          systemNavigationBarDividerColor: MyColors_e.write.withOpacity(0),
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: MyColors_e.black_liteX,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MyColors_e.write_xxBlue,
        selectedItemColor: MyColors_e.blue_tianyi,
        unselectedItemColor: MyColors_e.grey_lite,
      ),
      extensions: const [
        MyTheme_c(),
      ],
    );
  }

  static ThemeData mimicryLight() {
    return getBaseTheme().copyWith(
      brightness: Brightness.light,
      extensions: [
        MyTheme_c(
          appbarBackgroundColorCross: const Color.fromRGBO(245, 245, 245, 1),
          btnDecoration: (size, width, shape, isInBlock) {
            return BoxDecoration(
              color: isInBlock ? const Color.fromRGBO(243, 244, 245, 1) : null,
              gradient: isInBlock
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(244, 246, 250, 1),
                        Color.fromRGBO(255, 255, 255, 1),
                      ],
                    ),
              shape: shape,
              borderRadius: (BoxShape.circle == shape)
                  ? null
                  : MyBorderRadius.circular(size / 4),
              boxShadow: isInBlock
                  ? null
                  : MyGlobalStoreBase.theme_s.useNormalStyle
                      ? const [
                          MyBoxShadow(
                            color: Color.fromRGBO(50, 70, 90, 0.15),
                            blurRadius: 20,
                            spreadRadius: 8,
                            offset: MyOffset(16, 16),
                          ),
                          MyBoxShadow(
                            color: Color.fromRGBO(252, 253, 254, 1),
                            blurRadius: 16,
                            spreadRadius: 10,
                            offset: MyOffset(-16, -16),
                          ),
                          BoxShadow(
                            color: MyColors_e.write,
                            offset: MyOffset(-4, -4),
                          ),
                        ]
                      : const [
                          MyBoxShadow(
                            color: Color.fromRGBO(230, 240, 255, 0.5),
                            blurRadius: 20,
                            offset: Offset(3, 3),
                          ),
                          MyBoxShadow(
                            color: Color.fromRGBO(252, 252, 255, 0.8),
                            blurRadius: 20,
                            offset: Offset(-3, -3),
                          ),
                        ],
            );
          },
          btnSelectDecoration: (size, width, shape, isInBlock) {
            return BoxDecoration(
              color: MyColors_e.blue_tianyi,
              shape: shape,
              borderRadius: (BoxShape.circle == shape)
                  ? null
                  : MyBorderRadius.circular(size / 4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(102, 204, 255, 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                ),
                BoxShadow(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(-2, -2),
                ),
              ],
            );
          },
          btnSimpleDecoration: null,
          btnContentColor: MyColors_e.black_liteX,
          btnSimpleContentColor: MyColors_e.black_liteX,
          backgroundColor: MyColors_e.write,
          dialogBackgroundColor: MyColors_e.write,
          contentDecoration: const MyThemeContentDecoration_c(
            contentBlockSettingColor: MyColors_e.write_xx,
            contentButtonBackgroundColor: MyColors_e.write_xx,
            svgInContentBackgroundColor: MyColors_e.write_xl,
          ),
          favoryListStyle: MyThemeFavoryListDecoration_c(
            decoration: () {
              return const BoxDecoration(
                color: MyColors_e.write_x,
                borderRadius: MyBorderRadius(MyRadius(
                  MyListBase.defRelativeMiniListBoxItemBorderRadius,
                )),
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    offset: MyOffset(20, 20),
                    blurRadius: 50,
                    spreadRadius: 5,
                  ),
                  MyBoxShadow(
                    color: Color.fromRGBO(250, 250, 253, 1),
                    offset: MyOffset(-24, -24),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: MyColors_e.write,
                    offset: Offset(-2, -2),
                  ),
                ],
              );
            },
          ),
          inputDecoration: (size, isInContent) => BoxDecoration(
            color: isInContent
                ? const Color.fromRGBO(243, 244, 245, 1)
                : const Color.fromRGBO(248, 248, 248, 1),
            borderRadius: MyBorderRadius.circular(size / 6),
            boxShadow: isInContent
                ? null
                : MyGlobalStoreBase.theme_s.useNormalStyle
                    ? const [
                        MyBoxShadow(
                          color: Color.fromRGBO(80, 80, 80, 0.15),
                          blurRadius: 20,
                          spreadRadius: 8,
                          offset: MyOffset(16, 16),
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(253, 253, 253, 1),
                          blurRadius: 16,
                          spreadRadius: 8,
                          offset: MyOffset(-16, -16),
                        ),
                        BoxShadow(
                          color: MyColors_e.write,
                          offset: MyOffset(-6, -6),
                        ),
                      ]
                    : const [
                        MyBoxShadow(
                          color: Color.fromRGBO(230, 240, 255, 0.5),
                          blurRadius: 20,
                          offset: Offset(3, 3),
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(252, 252, 255, 0.8),
                          blurRadius: 20,
                          offset: Offset(-3, -3),
                        ),
                      ],
          ),
          listBoxItemDecoration: (isSelect) {
            if (isSelect) {
              return const BoxDecoration(
                color: Color.fromRGBO(242, 245, 250, 1),
                borderRadius: MyBorderRadius(MyRadius(
                  MyListBase.defRelativeListBoxItemBorderRadius,
                )),
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(247, 250, 255, 1),
                    blurRadius: 20,
                  ),
                ],
              );
            } else {
              return null;
            }
          },
          gridBoxItemDecoration: (isSelect) {
            if (isSelect) {
              return const BoxDecoration(
                color: Color.fromRGBO(245, 250, 255, 1),
                borderRadius: MyBorderRadius(MyRadius(
                  MyListBase.defRelativeGridBoxItemBorderRadius,
                )),
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    blurRadius: 20,
                  ),
                ],
              );
            } else {
              return null;
            }
          },
          imageStyle: MyThemeImageStyle_c(
            borderColor: const Color.fromRGBO(245, 245, 250, 1),
            backgroundColor: const Color.fromRGBO(250, 245, 255, 1),
            indexIconProgressColor: MyColors_e.write,
            indexIconBorder: (size) {
              return Border.all(
                color: const Color.fromRGBO(240, 244, 246, 1),
                width: 8.r,
              );
            },
            indexIconDecoration: (size) {
              // 阴影缩放倍率
              return MyGlobalStoreBase.theme_s.useNormalStyle
                  ? const BoxDecoration(
                      color: Color.fromRGBO(245, 245, 245, 1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        MyBoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          offset: MyOffset(18, 18),
                          blurRadius: 75,
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(250, 250, 253, 1),
                          offset: MyOffset(-18, -18),
                          blurRadius: 24,
                        ),
                        BoxShadow(
                          color: MyColors_e.write,
                          offset: Offset(-1, -1),
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      color: Color.fromRGBO(245, 245, 250, 1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        MyBoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          offset: MyOffset(12, 12),
                          blurRadius: 24,
                          spreadRadius: 12,
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(250, 250, 253, 1),
                          offset: MyOffset(-12, -12),
                          blurRadius: 20,
                        ),
                        BoxShadow(
                          color: MyColors_e.write,
                          offset: Offset(-1, -1),
                        ),
                      ],
                    );
            },
            shadowBuilder: (size) {
              // 阴影缩放倍率
              final offset = size / 16;
              final double lineOffset = MyGlobalUtil_c.numLimit(
                size / 120,
                minLimit: 1.5,
                maxLimit: 3,
              );
              return [
                MyBoxShadow(
                  color: const Color.fromRGBO(60, 60, 60, 0.2),
                  blurRadius: 50,
                  offset: Offset(offset, offset),
                ),
                MyBoxShadow(
                  color: const Color.fromRGBO(250, 250, 253, 1),
                  blurRadius: 16,
                  offset: Offset(-offset, -offset),
                ),
                BoxShadow(
                  color: MyColors_e.write,
                  offset: Offset(-lineOffset, -lineOffset),
                ),
              ];
            },
          ),
          musicWarpStyle: const MyThemeMusicWarp_c.light(),
          progressStyle: MyThemeProgress_c.defLight(),
          switchDecoration: const MyThemeSwitchDecoration_c(),
          textTitleBackgroundColor: const Color.fromRGBO(220, 255, 200, 0.2),
        ),
      ],
    );
  }

  static ThemeData mimicryNight() {
    return getBaseTheme().copyWith(
      brightness: Brightness.dark,
      cardColor: MyColors_e.black,
      primaryColor: MyColors_e.blue_tianyi,
      scaffoldBackgroundColor: MyColors_e.black_x,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: MyColors_e.black_x,
        iconTheme: const IconThemeData(color: MyColors_e.write_lite),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: MyColors_e.black_x.withOpacity(0),
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: MyColors_e.black_x.withOpacity(0),
          systemNavigationBarDividerColor: MyColors_e.black_x.withOpacity(0),
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: MyColors_e.blue_tianyi,
        selectionColor: MyColors_e.black_lite,
        selectionHandleColor: MyColors_e.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MyColors_e.black_x,
        selectedItemColor: MyColors_e.blue_tianyi,
        unselectedItemColor: MyColors_e.grey_lite,
      ),
      shadowColor: MyColors_e.grey_lite,
      extensions: [
        MyTheme_c(
          appbarBackgroundColorCross: MyColors_e.black_x,
          btnDecoration: (size, width, shape, isInBlock) {
            return BoxDecoration(
              color: MyGlobalStoreBase.theme_s.useSimpleStyle
                  ? const Color.fromRGBO(50, 55, 65, 0.7)
                  : const Color.fromRGBO(50, 55, 65, 1),
              shape: shape,
              borderRadius: (BoxShape.circle == shape)
                  ? null
                  : MyBorderRadius.circular(size / 4),
              boxShadow: (isInBlock || MyGlobalStoreBase.theme_s.useSimpleStyle)
                  ? null
                  : const [
                      MyBoxShadow(
                        color: Color.fromRGBO(25, 25, 30, 1),
                        offset: MyOffset(16, 16),
                        blurRadius: 30,
                      ),
                      MyBoxShadow(
                        color: Color.fromRGBO(63, 68, 81, 1),
                        offset: MyOffset(-16, -16),
                        blurRadius: 30,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(75, 75, 85, 1),
                        offset: Offset(-1, -1),
                      ),
                    ],
            );
          },
          btnSelectDecoration: (size, width, shape, isInBlock) {
            return BoxDecoration(
              color: MyColors_e.blue_tianyi,
              shape: shape,
              borderRadius: (BoxShape.circle == shape)
                  ? null
                  : MyBorderRadius.circular(size / 4),
              boxShadow: MyGlobalStoreBase.theme_s.useSimpleStyle
                  ? null
                  : const [
                      MyBoxShadow(
                        color: Color.fromRGBO(25, 25, 30, 1),
                        offset: MyOffset(20, 20),
                        blurRadius: 35,
                      ),
                      MyBoxShadow(
                        color: Color.fromRGBO(67, 70, 83, 1),
                        offset: MyOffset(-20, -20),
                        blurRadius: 25,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(75, 75, 85, 1),
                        offset: Offset(-1, -1),
                      ),
                    ],
            );
          },
          btnContentColor: MyColors_e.write_lite,
          btnSimpleContentColor: MyColors_e.write_lite,
          btnDisableContentColor: MyColors_e.black,
          borderColor: const Color.fromRGBO(53, 59, 69, 1),
          backgroundColor: MyColors_e.black_x,
          backgroundColorCross: MyColors_e.black,
          contentDecoration: const MyThemeContentDecoration_c(
            contentButtonBackgroundColor: MyColors_e.black,
            contentBlockSettingColor: Color.fromRGBO(42, 49, 56, 1),
            svgBackgroundColor: Color.fromRGBO(42, 49, 56, 1),
            svgInContentBackgroundColor: MyColors_e.black_x,
          ),
          disableColor: MyColors_e.black,
          dialogBarrierColor: MyColors_e.black.withOpacity(0.7),
          dialogBackgroundColor: MyColors_e.black_x,
          favoryListStyle: MyThemeFavoryListDecoration_c(
            decoration: () {
              return MyGlobalStoreBase.theme_s.useSimpleStyle
                  ? const BoxDecoration(
                      color: MyColors_e.black_x,
                      borderRadius: MyBorderRadius(MyRadius(
                        MyListBase.defRelativeMiniListBoxItemBorderRadius,
                      )),
                      boxShadow: [
                        MyBoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          offset: MyOffset(0, 20),
                          blurRadius: 60,
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(30, 30, 30, 1),
                          offset: MyOffset(0, 20),
                          blurRadius: 60,
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      color: MyColors_e.black_x,
                      borderRadius: MyBorderRadius(MyRadius(
                        MyListBase.defRelativeMiniListBoxItemBorderRadius,
                      )),
                      boxShadow: [
                        MyBoxShadow(
                          color: Color.fromRGBO(25, 25, 30, 1),
                          offset: MyOffset(26, 26),
                          blurRadius: 50,
                        ),
                        MyBoxShadow(
                          color: Color.fromRGBO(67, 72, 83, 1),
                          offset: MyOffset(-20, -20),
                          blurRadius: 30,
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(75, 75, 85, 1),
                          offset: Offset(-1, -1),
                        ),
                      ],
                    );
            },
          ),
          inputDecoration: (size, isInContent) => BoxDecoration(
            color: MyGlobalStoreBase.theme_s.useSimpleStyle
                ? const Color.fromRGBO(40, 45, 50, 1)
                : MyColors_e.black_x,
            borderRadius: MyBorderRadius.circular(size / 6),
            boxShadow: (isInContent || MyGlobalStoreBase.theme_s.useSimpleStyle)
                ? null
                : const [
                    MyBoxShadow(
                      color: Color.fromRGBO(25, 25, 30, 1),
                      offset: MyOffset(12, 12),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                    MyBoxShadow(
                      color: Color.fromRGBO(63, 68, 81, 1),
                      offset: MyOffset(-12, -12),
                      blurRadius: 20,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(75, 75, 85, 1),
                      offset: Offset(-1, -1),
                    ),
                  ],
          ),
          iconWaveColor: MyColors_e.blue_lite.withOpacity(0.2),
          iconDecoration: const MyThemeIconDecoration_c.defNight(),
          imageStyle: MyThemeImageStyle_c(
            borderColor: const Color.fromRGBO(60, 65, 75, 1),
            backgroundColor: const Color.fromRGBO(40, 55, 60, 1),
            indexIconProgressColor: const Color.fromRGBO(30, 35, 30, 1),
            indexIconBorder: (size) {
              return Border.all(
                color: const Color.fromRGBO(53, 59, 69, 1),
                width: 8.r,
              );
            },
            indexIconDecoration: (size) {
              if (MyGlobalStoreBase.theme_s.useSimpleStyle) {
                return const BoxDecoration(
                    color: MyColors_e.black_x,
                    shape: BoxShape.circle,
                    boxShadow: [
                      MyBoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        offset: MyOffset(0, 20),
                        blurRadius: 60,
                      ),
                      MyBoxShadow(
                        color: Color.fromRGBO(30, 30, 30, 1),
                        offset: MyOffset(0, 20),
                        blurRadius: 60,
                      ),
                    ]);
              }
              return const BoxDecoration(
                color: MyColors_e.black_x,
                shape: BoxShape.circle,
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(25, 25, 30, 1),
                    offset: MyOffset(12, 12),
                    blurRadius: 50,
                    spreadRadius: 16,
                  ),
                  MyBoxShadow(
                    color: Color.fromRGBO(63, 68, 81, 1),
                    offset: MyOffset(-24, -24),
                    blurRadius: 30,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(75, 75, 85, 1),
                    offset: Offset(-1, -1),
                  ),
                ],
              );
            },
            shadowBuilder: (size) {
              // 阴影缩放倍率
              return [
                MyBoxShadow(
                  color: const Color.fromRGBO(25, 25, 30, 1),
                  offset: Offset(size / 18, size / 18),
                  blurRadius: 60,
                ),
                MyBoxShadow(
                  color: const Color.fromRGBO(63, 68, 81, 1),
                  offset: Offset(-size / 35, -size / 35),
                  blurRadius: 50,
                ),
                const BoxShadow(
                  color: Color.fromRGBO(75, 75, 85, 1),
                  offset: Offset(-1, -1),
                ),
              ];
            },
          ),
          listBoxItemDecoration: (isSelect) {
            if (isSelect) {
              return const BoxDecoration(
                color: Color.fromRGBO(35, 40, 45, 1),
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(30, 35, 40, 1),
                    blurRadius: 20,
                  ),
                ],
                borderRadius: MyBorderRadius(MyRadius(
                  MyListBase.defRelativeListBoxItemBorderRadius,
                )),
              );
            } else {
              return null;
            }
          },
          gridBoxItemDecoration: (isSelect) {
            if (isSelect) {
              return const BoxDecoration(
                color: Color.fromRGBO(35, 40, 45, 1),
                boxShadow: [
                  MyBoxShadow(
                    color: Color.fromRGBO(30, 35, 40, 1),
                    blurRadius: 30,
                  ),
                ],
                borderRadius: MyBorderRadius(MyRadius(
                  MyListBase.defRelativeGridBoxItemBorderRadius,
                )),
              );
            } else {
              return null;
            }
          },
          musicWarpStyle: const MyThemeMusicWarp_c.night(),
          switchDecoration: const MyThemeSwitchDecoration_c(
            textBackgroundColor: Color.fromRGBO(35, 40, 45, 1),
            boolBackgroundColor: Color.fromRGBO(35, 40, 45, 1),
            boolFalseBackColor: MyColors_e.black_x,
            dropBackgroundColor: MyColors_e.black_x,
            dropPopupBackgroundColor: Color.fromRGBO(42, 49, 56, 1),
            dropSelectItemBackgroundColor: Color.fromRGBO(35, 40, 45, 1),
          ),
          shimmerBaseColor: MyColors_e.blue_lite,
          shimmerHighlightColor: MyColors_e.grey_lite,
          shadowDarkColor: const Color.fromARGB(255, 37, 46, 41),
          shadowLightColor: const Color.fromARGB(255, 78, 86, 102),
          textMainColor: MyColors_e.write_lite,
          textTitleColor: MyColors_e.write_lite,
          textCrossColor: MyColors_e.black_lite,
          toastStyle: EasyLoadingStyle.dark,
          progressStyle: MyThemeProgress_c(
            progressShadowColor: const Color.fromRGBO(40, 40, 50, 1),
            progressColor: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromRGBO(30, 35, 30, 1),
                Color.fromRGBO(30, 35, 30, 1),
              ],
            ),
            progressBaseDecoration: () {
              return const BoxDecoration(
                color: MyColors_e.black_x,
                borderRadius: MyBorderRadius(MyRadius(35)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(25, 25, 30, 1),
                    offset: Offset(3, 3),
                    blurRadius: 10,
                    spreadRadius: 1.5,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(63, 68, 81, 1),
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(75, 75, 85, 1),
                    offset: Offset(-1, -1),
                  ),
                ],
              );
            },
            progressBaseforegroundDecoration: () {
              return BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(53, 59, 69, 1),
                  width: 8.r,
                ),
                borderRadius: const MyBorderRadius(MyRadius(35)),
              );
            },
          ),
          textTitleBackgroundColor: const Color.fromRGBO(200, 200, 210, 0.2),
        ),
      ],
    );
  }
}

class MyThemeSwitchDecoration_c {
  static double defBorderWidth() {
    return 10.r;
  }

  final Color boolSvgColor,
      boolTrueSelectedSvgColor,
      boolBackgroundColor,
      boolTrueBackColor,
      boolFalseBackColor;
  final Color? textBackgroundColor,
      textSelectedBackColor,
      textSelectedColor,
      textItemColor;
  final Color? dropBackgroundColor,
      dropPopupBackgroundColor,
      dropSelectItemBackgroundColor;

  const MyThemeSwitchDecoration_c({
    this.boolSvgColor = MyColors_e.grey_lite,
    this.boolTrueSelectedSvgColor = MyColors_e.write,
    this.boolBackgroundColor = MyColors_e.write_x,
    this.boolTrueBackColor = MyColors_e.blue_tianyi,
    this.boolFalseBackColor = MyColors_e.write,
    this.textBackgroundColor = MyColors_e.write_xl,
    this.textSelectedBackColor = MyColors_e.blue_tianyi,
    this.textSelectedColor = MyColors_e.write,
    this.textItemColor,
    this.dropBackgroundColor = MyColors_e.write_xl,
    this.dropPopupBackgroundColor = MyColors_e.write,
    this.dropSelectItemBackgroundColor = MyColors_e.write_xxBlue,
  });

  const MyThemeSwitchDecoration_c.night({
    this.boolSvgColor = MyColors_e.grey_lite,
    this.boolTrueSelectedSvgColor = MyColors_e.write,
    this.boolBackgroundColor = const Color.fromRGBO(15, 15, 15, 1),
    this.boolTrueBackColor = MyColors_e.blue_tianyi,
    this.boolFalseBackColor = MyColors_e.black,
    this.textBackgroundColor = const Color.fromRGBO(15, 15, 15, 1),
    this.textSelectedBackColor = MyColors_e.blue_tianyi,
    this.textSelectedColor = MyColors_e.write,
    this.textItemColor,
    this.dropBackgroundColor = const Color.fromRGBO(15, 15, 15, 1),
    this.dropPopupBackgroundColor = const Color.fromRGBO(24, 27, 31, 1),
    this.dropSelectItemBackgroundColor = MyColors_e.black,
  });
}

class MyThemeContentDecoration_c {
  final Color? contentButtonBackgroundColor,
      contentBlockSettingColor,
      svgBackgroundColor,
      svgInContentBackgroundColor;

  const MyThemeContentDecoration_c({
    this.contentButtonBackgroundColor = MyColors_e.write,
    this.contentBlockSettingColor = MyColors_e.write,
    this.svgBackgroundColor = MyColors_e.write_x,
    this.svgInContentBackgroundColor = MyColors_e.write_xx,
  });
}

class MyThemeIconDecoration_c {
  static const defVideoBorderRadius = MyBorderRadius(MyRadius(20));

  final BoxDecoration? Function(double iconSize)? photoCircleDecoration;
  final BoxDecoration? Function(
    BorderRadiusGeometry? borderRadius,
    double iconSize,
  )? photoRectDecoration;
  final Color? photoBorderColor;
  final BoxDecoration? Function(double height, double width)? videoDecoration;

  const MyThemeIconDecoration_c({
    this.photoBorderColor = const Color.fromRGBO(240, 240, 247, 1),
    this.photoCircleDecoration = defLightPhotoCircleDecoration,
    this.photoRectDecoration = defLightPhotoRectDecoration,
    this.videoDecoration = defLightVideoDecoration,
  });

  const MyThemeIconDecoration_c.defNight({
    this.photoBorderColor = const Color.fromRGBO(53, 59, 69, 1),
    this.photoCircleDecoration = defNightPhotoCircleDecoration,
    this.photoRectDecoration = defNightPhotoRectDecoration,
    this.videoDecoration = defNightVideoDecoration,
  });

  static BoxDecoration defLightPhotoCircleDecoration(
    double iconSize,
  ) {
    final lineOffset = MyGlobalUtil_c.numLimit(
      iconSize / 150,
      minLimit: 1.5,
      maxLimit: 3,
    );
    return BoxDecoration(
      borderRadius: MyBorderRadius.circular(iconSize / 2),
      color: MyColors_e.write_x,
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 15, 30, 0.15),
          offset: Offset(iconSize / 16, iconSize / 16),
          blurRadius: iconSize / 12,
        ),
        BoxShadow(
          color: const Color.fromRGBO(250, 252, 253, 1),
          offset: Offset(-iconSize / 20, -iconSize / 20),
          blurRadius: iconSize / 16,
        ),
        BoxShadow(
          color: MyColors_e.write,
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }

  static BoxDecoration defLightPhotoRectDecoration(
    BorderRadiusGeometry? borderRadius,
    double iconSize,
  ) {
    final double lineOffset = max(iconSize / 150, 1.5);
    return BoxDecoration(
      borderRadius: borderRadius,
      color: MyColors_e.write_x,
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          offset: Offset(iconSize / 16, iconSize / 16),
          blurRadius: iconSize / 8,
        ),
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.9),
          offset: Offset(-iconSize / 24, -iconSize / 24),
          blurRadius: iconSize / 20,
        ),
        BoxShadow(
          color: MyColors_e.write_xxBlue,
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }

  static BoxDecoration defLightVideoDecoration(double height, double width) {
    final double lineOffset = max(height / 250, 1);
    return BoxDecoration(
      borderRadius: MyThemeIconDecoration_c.defVideoBorderRadius,
      color: MyColors_e.write_x,
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.3),
          offset: Offset(height / 16, height / 16),
          blurRadius: height / 16,
        ),
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.8),
          offset: Offset(-height / 16, -height / 16),
          blurRadius: height / 16,
        ),
        BoxShadow(
          color: MyColors_e.write,
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }

  static BoxDecoration defNightPhotoCircleDecoration(double iconSize) {
    final double lineOffset = max(iconSize / 200, 1);
    return BoxDecoration(
      borderRadius: MyBorderRadius.circular(iconSize / 2),
      color: MyColors_e.black_x,
      boxShadow: [
        MyBoxShadow(
          color: const Color.fromRGBO(35, 35, 40, 1),
          offset: Offset(iconSize / 16, iconSize / 16),
          blurRadius: 60,
        ),
        MyBoxShadow(
          color: const Color.fromRGBO(65, 70, 90, 1),
          offset: Offset(-iconSize / 20, -iconSize / 20),
          blurRadius: 60,
        ),
        BoxShadow(
          color: const Color.fromRGBO(80, 80, 85, 1),
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }

  static BoxDecoration defNightPhotoRectDecoration(borderRadius, iconSize) {
    final double lineOffset = max(iconSize / 150, 1);
    return BoxDecoration(
      borderRadius: borderRadius,
      color: MyColors_e.black_x,
      boxShadow: [
        MyBoxShadow(
          color: const Color.fromRGBO(25, 25, 30, 1),
          offset: Offset(iconSize / 16, iconSize / 16),
          blurRadius: 60,
        ),
        MyBoxShadow(
          color: const Color.fromRGBO(63, 68, 81, 1),
          offset: Offset(-iconSize / 30, -iconSize / 30),
          blurRadius: 60,
        ),
        BoxShadow(
          color: const Color.fromRGBO(75, 75, 85, 1),
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }

  static BoxDecoration defNightVideoDecoration(height, width) {
    final double lineOffset = max(height / 250, 1);
    return BoxDecoration(
      borderRadius: MyThemeIconDecoration_c.defVideoBorderRadius,
      color: MyColors_e.black_x,
      boxShadow: [
        MyBoxShadow(
          color: const Color.fromRGBO(25, 25, 30, 1),
          offset: Offset(height / 20, height / 20),
          blurRadius: 60,
        ),
        MyBoxShadow(
          color: const Color.fromRGBO(63, 68, 81, 1),
          offset: Offset(-height / 30, -height / 30),
          blurRadius: 50,
        ),
        BoxShadow(
          color: const Color.fromRGBO(75, 75, 85, 1),
          offset: Offset(-lineOffset, -lineOffset),
        ),
      ],
    );
  }
}

class MyThemeProgress_c {
  final Color? progressShadowColor;
  final LinearGradient? progressColor;
  final BoxDecoration Function() progressBaseDecoration;
  final BoxDecoration Function()? progressBaseforegroundDecoration;

  const MyThemeProgress_c({
    this.progressShadowColor,
    this.progressColor,
    this.progressBaseDecoration = defBoxDecoration,
    this.progressBaseforegroundDecoration,
  });

  static BoxDecoration defBoxDecoration() {
    return const BoxDecoration();
  }

  factory MyThemeProgress_c.defLight() {
    return MyThemeProgress_c(
      progressBaseDecoration: () {
        return const BoxDecoration(
          color: MyColors_e.write_x,
          borderRadius: MyBorderRadius(MyRadius(35)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(3, 3),
              blurRadius: 10,
              spreadRadius: 1.5,
            ),
            BoxShadow(
              color: MyColors_e.write,
              offset: Offset(-2, -2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: MyColors_e.write,
              offset: Offset(-1, -1),
            ),
          ],
        );
      },
      progressBaseforegroundDecoration: () {
        return BoxDecoration(
          border: Border.all(
            color: MyColors_e.write_xxBlue,
            width: 8.r,
          ),
          borderRadius: const MyBorderRadius(MyRadius(35)),
        );
      },
    );
  }

  static MyThemeProgress_c buildNight() {
    return MyThemeProgress_c(
      progressShadowColor: const Color.fromRGBO(40, 40, 50, 1),
      progressColor: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          MyColors_e.black_xx,
          MyColors_e.black_xx,
        ],
      ),
      progressBaseDecoration: () {
        return const BoxDecoration(
          color: Color.fromRGBO(30, 40, 50, 1),
          borderRadius: MyBorderRadius(MyRadius(35)),
          boxShadow: [
            MyBoxShadow(
              color: Color.fromRGBO(47, 54, 62, 0.6),
              blurRadius: 8,
              spreadRadius: 6,
            ),
          ],
        );
      },
      progressBaseforegroundDecoration: () {
        return BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(53, 59, 69, 1),
            width: 8.r,
          ),
          borderRadius: const MyBorderRadius(MyRadius(35)),
        );
      },
    );
  }
}

class MyThemeFavoryListDecoration_c {
  static const defLightColorList = [
    Color.fromARGB(255, 70, 60, 160),
    Color.fromRGBO(180, 255, 240, 1),
    Color.fromRGBO(180, 240, 255, 1),
    Color.fromRGBO(150, 255, 230, 1),
  ];

  static const defNightColorList = [
    Color.fromARGB(255, 10, 25, 50),
    Color.fromARGB(255, 67, 63, 157),
    Color.fromARGB(255, 30, 255, 220),
    Color.fromARGB(255, 140, 200, 255),
  ];

  final BoxDecoration Function()? decoration, foregroundDecoration;

  const MyThemeFavoryListDecoration_c({
    this.decoration,
    this.foregroundDecoration,
  });

  static MyThemeFavoryListDecoration_c buildNight() {
    return MyThemeFavoryListDecoration_c(
      decoration: () => const BoxDecoration(
        borderRadius: MyBorderRadius(MyRadius(
          MyListBase.defRelativeMiniListBoxItemBorderRadius,
        )),
        boxShadow: [
          BoxShadow(
            color: MyColors_e.black_x,
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class MyThemeImageStyle_c {
  final Color borderColor, backgroundColor, indexIconProgressColor;
  final List<BoxShadow>? Function(double size)? shadowBuilder;
  final Border Function(double size)? indexIconBorder;
  final BoxDecoration Function(double size)? indexIconDecoration;

  const MyThemeImageStyle_c({
    this.borderColor = MyColors_e.black_x,
    this.backgroundColor = MyColors_e.black,
    this.shadowBuilder = MyThemeImageStyle_c.defNight,
    this.indexIconProgressColor = MyColors_e.black_xx,
    this.indexIconDecoration = defNightIndexIconDecoration,
    this.indexIconBorder = defNightIndexIconBorder,
  });

  static List<BoxShadow>? defNight(double size) {
    return [
      BoxShadow(
        color: const Color.fromRGBO(47, 54, 62, 0.7),
        blurRadius: size / 20,
        spreadRadius: size / 30,
      ),
    ];
  }

  static BoxDecoration defNightIndexIconDecoration(double size) {
    return BoxDecoration(
      color: MyColors_e.black_x,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(47, 54, 62, 0.7),
          blurRadius: size / 20,
          spreadRadius: size / 30,
        ),
      ],
    );
  }

  static Border defNightIndexIconBorder(double size) {
    return Border.all(
      color: MyColors_e.black_x,
      width: 7.r,
    );
  }
}

class MyThemeMusicWarp_c {
  // 播放暂停按钮显示阴影
  final bool playBtnShowShadow;
  final Color defBackgroundColor;
  final Gradient? gradient;

  const MyThemeMusicWarp_c.light({
    this.playBtnShowShadow = true,
    this.gradient = const LinearGradient(
      colors: [
        Color.fromRGBO(210, 230, 250, 1),
        Color.fromRGBO(240, 240, 250, 1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
    ),
    this.defBackgroundColor = const Color.fromRGBO(212, 229, 247, 1),
  });

  const MyThemeMusicWarp_c.night({
    this.playBtnShowShadow = true,
    this.gradient = const LinearGradient(
      colors: [
        Color.fromRGBO(50, 60, 85, 1),
        Color.fromRGBO(50, 55, 70, 1),
        MyColors_e.black_x,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
    ),
    this.defBackgroundColor = MyColors_e.black_x,
  });
}
