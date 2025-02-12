// ignore_for_file: file_names, non_constant_identifier_names

import "dart:math" as math;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:builder_xx/componets/global/MyGestureDetector.dart';
import 'package:builder_xx/componets/global/MyPopup.dart';
import 'package:refreshed/refreshed.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyScreenUtil.dart';
import 'MySvg.dart';
import 'MyText.dart';
import '/manager/MyTheme.dart';
import '/componets/global/MyBtn.dart';

class MySwitchRolling<T> extends StatelessWidget {
  final T current;
  final List<T> values;
  final Widget Function(T value, bool foreground)? iconBuilder;
  final void Function(T current)? onTap;
  final void Function(T)? onChanged;
  final bool? loading;
  final double? height;
  final double? width;
  final double? borderWidth;
  final Size indicatorSize;
  final ForegroundIndicatorTransition indicatorTransition;
  final ToggleStyle Function(T value)? styleBuilder;

  const MySwitchRolling({
    super.key,
    required this.current,
    required this.values,
    this.onTap,
    this.onChanged,
    this.iconBuilder,
    this.loading,
    this.height,
    this.width,
    this.styleBuilder,
    this.borderWidth,
    this.indicatorSize = const Size(46.0, double.infinity),
    this.indicatorTransition = const ForegroundIndicatorTransition.rolling(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final lastHeight = height ?? 90.r;
    final reWidget = SizedBox(
      height: lastHeight,
      width: width ?? values.length * 90.r,
      child: AnimatedToggleSwitch<T>.rolling(
        current: current,
        values: values,
        iconOpacity: 0.7,
        iconBuilder: iconBuilder,
        indicatorAnimationType: AnimationType.none,
        styleAnimationType: AnimationType.none,
        styleBuilder: styleBuilder,
        style: ToggleStyle(
          indicatorColor: theme.primaryColor,
          borderColor: MyColors_e.transparent,
        ),
        borderWidth: borderWidth ?? MyThemeSwitchDecoration_c.defBorderWidth(),
        height: lastHeight,
        indicatorSize: indicatorSize,
        onTap: (null != onTap) ? ((p0) => onTap!(current)) : null,
        loading: loading,
        onChanged: onChanged,
        indicatorTransition: indicatorTransition,
        loadingIconBuilder: (context, global) {
          return const CupertinoActivityIndicator(
            color: MyColors_e.grey_lite,
          );
        },
      ),
    );
    if (null != onTap) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: reWidget,
      );
    } else {
      return reWidget;
    }
  }
}

class MySwitchBool extends StatelessWidget {
  /// [false, true]
  final bool checked;
  final void Function(bool in_checked)? onTap;
  final void Function(bool in_checked)? onChanged;
  final bool loading;

  const MySwitchBool({
    super.key,
    this.checked = false,
    this.onTap,
    this.onChanged,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme.switchDecoration;
    return MySwitchRolling<bool>(
      key: key,
      height: 100.r,
      width: 190.r,
      indicatorSize: const Size(double.infinity, double.infinity),
      current: checked,
      values: const [false, true],
      onTap: onTap,
      onChanged: onChanged,
      loading: loading,
      iconBuilder: (value, foreground) {
        if (false == foreground) {
          return const SizedBox();
        }
        return Center(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: value ? theme.boolTrueBackColor : theme.boolFalseBackColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: MySvg(
                svgName: (value)
                    ? MySvgNames_e.circle_dot
                    : MySvgNames_e.circleDashed,
                size: 50.r,
                color: (foreground && value)
                    ? theme.boolTrueSelectedSvgColor
                    : theme.boolSvgColor,
              ),
            ),
          ),
        );
      },
      styleBuilder: (value) {
        if (value) {
          return ToggleStyle(
            indicatorColor: MyColors_e.transparent,
            backgroundColor: theme.boolBackgroundColor,
            borderColor: MyColors_e.transparent,
            indicatorBorderRadius: const MyBorderRadius(MyRadius(40)),
          );
        } else {
          return ToggleStyle(
            indicatorColor: MyColors_e.transparent,
            backgroundColor: theme.boolBackgroundColor,
            borderColor: MyColors_e.transparent,
            indicatorBorderRadius: const MyBorderRadius(MyRadius(40)),
          );
        }
      },
    );
  }
}

class MySwitchBoolBar extends MySwitchBool {
  final String title;
  final String? depict;

  const MySwitchBoolBar({
    required this.title,
    this.depict,
    super.key,
    super.checked = false,
    super.onTap,
    super.onChanged,
    super.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MyGestureDetector(
      onTap: (null != onTap) ? () => onTap?.call(checked) : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextMain.thin(title),
                if (true == depict?.isNotEmpty)
                  Padding(
                    padding: const MyEdgeInsets.only(top: 10),
                    child: MyTextCross.multiLine(depict!),
                  )
              ],
            ),
          ),
          Padding(
            padding: const MyEdgeInsets.only(left: 30),
            child: super.build(context),
          ),
        ],
      ),
    );
  }
}

/// 应当自行保证 values 中没有重复的值
class MySwitchText<T> extends StatelessWidget {
  final List<T> values;
  final List<String> valuesText;
  final T current;
  final void Function(T)? onChanged;
  final double? height, width, itemWidth;

  const MySwitchText({
    super.key,
    required this.values,
    required this.valuesText,
    required this.current,
    this.onChanged,
    this.height,
    this.width = double.infinity,
    this.itemWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final itemWidth = this.itemWidth ?? 300.r;
    return MySwitchRolling<T>(
      values: values,
      current: current,
      indicatorTransition: const ForegroundIndicatorTransition.fading(),
      indicatorSize: Size(itemWidth, double.infinity),
      height: height ?? 160.r,
      borderWidth: 25.r,
      width: width ?? (itemWidth * values.length + 50.r),
      onChanged: onChanged,
      iconBuilder: (value, foreground) {
        String text = "";
        for (int i = values.length; i-- > 0;) {
          if (values[i] == value) {
            text = valuesText[i];
            break;
          }
        }
        return Center(
          child: MyTextCross(
            text,
            style: MyTextCrossStyle(
              rFontSize: 45,
              color: (foreground)
                  ? theme.switchDecoration.textSelectedColor
                  : theme.switchDecoration.textItemColor,
            ),
          ),
        );
      },
      styleBuilder: (value) {
        return ToggleStyle(
          indicatorColor: theme.switchDecoration.textSelectedBackColor,
          backgroundColor: theme.switchDecoration.textBackgroundColor,
          borderRadius: const MyBorderRadius(MyRadius(40)),
          indicatorBorderRadius: const MyBorderRadius(MyRadius(30)),
        );
      },
    );
  }
}

class MySwitchTextPopup<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final String Function(T) toName;
  final String? Function(T)? toDepict;
  final void Function(T) onChanged;
  final T selectValue;
  final T? defaultValue;
  final Widget? customButton;

  const MySwitchTextPopup({
    super.key,
    required this.title,
    required this.values,
    required this.toName,
    required this.onChanged,
    required this.selectValue,
    this.toDepict,
    this.customButton,
    this.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    final switchDecoration = MyGlobalStoreBase.theme_s.mytheme.switchDecoration;
    return MyGestureDetector(
      onTap: () {
        MyPopup.showSelectSimple(
          title: title,
          toInfoMain: toName,
          toInfoCross: toDepict,
          data: values,
          defaultValue: defaultValue,
          selectValue: selectValue,
          onTap: (value) async {
            onChanged(value);
            return true;
          },
        );
      },
      child: Container(
        height: 200.r,
        width: double.infinity,
        padding: const MyEdgeInsets.all(30),
        decoration: BoxDecoration(
          color: switchDecoration.dropBackgroundColor,
          borderRadius: MyBorderRadius.circularRInt(40),
        ),
        child: Row(
          children: [
            Expanded(
              child: MyTextMain(
                toName(selectValue),
                textAlign: TextAlign.left,
                style: const MyTextMainStyle(
                  fontWeight: MyTextCross.defFontWeight,
                ),
              ),
            ),
            customButton ??
                const MyBtn.simple(
                  svgName: MySvgNames_e.select,
                  showDisableColor: false,
                ),
          ],
        ),
      ),
    );
  }
}

class MyDropdownButton<T> extends StatelessWidget {
  final List<T> values;
  final String Function(T) toName;
  final String? Function(T)? toDepict;
  final void Function(T?) onChanged;
  final T? selectValue;
  final T? defaultValue;
  final int? rItemHeight, rWidth;
  final Widget? customButton;

  final List<DropdownMenuItem<T>> items = [];

  MyDropdownButton({
    super.key,
    required this.values,
    required this.toName,
    required this.onChanged,
    this.toDepict,
    this.rItemHeight,
    this.rWidth,
    this.customButton,
    this.selectValue,
    this.defaultValue,
  }) {
    for (int i = 0; i < values.length; ++i) {
      final value = values[i];
      String name = toName(value);
      if (value == defaultValue) {
        name += "（默认）";
      }
      final nameWidget = MyTextMain(
        name,
        textAlign: TextAlign.left,
        style: const MyTextMainStyle(
          rFontSize: 45,
        ),
      );
      final depict = toDepict?.call(value);
      Widget? depictWidget;
      if (null != depict) {
        depictWidget = MyTextCross.multiLine(
          depict,
          style: const MyTextCrossStyle(
            rFontSize: 45,
          ),
          textAlign: TextAlign.left,
        );
      }
      items.add(DropdownMenuItem(
        value: value,
        child: (null != depictWidget)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  nameWidget,
                  const MySizedBox(height: 10),
                  depictWidget,
                ],
              )
            : nameWidget,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final switchDecoration = MyGlobalStoreBase.theme_s.mytheme.switchDecoration;
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        items: items,
        value: selectValue,
        customButton: customButton,
        onChanged: onChanged,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
        buttonStyleData: ButtonStyleData(
          height: rItemHeight?.r ?? 200.r,
          width: rWidth?.r ?? double.infinity,
          padding: const MyEdgeInsets.only(left: 30, right: 30),
          decoration: BoxDecoration(
            color: switchDecoration.dropBackgroundColor,
            boxShadow: const [],
            borderRadius: MyBorderRadius.circularRInt(40),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: const MyBtn.simple(
            svgName: MySvgNames_e.select,
            showDisableColor: false,
          ),
          iconSize: 120.r,
        ),
        // 弹窗样式
        dropdownStyleData: DropdownStyleData(
          maxHeight: math.min(700.r, Get.height / 4 * 3),
          width: rWidth?.r,
          decoration: BoxDecoration(
            borderRadius: MyBorderRadius.circularRInt(40),
            color: switchDecoration.dropPopupBackgroundColor,
          ),
          padding: const MyEdgeInsets.only(top: 30, bottom: 30),
          useRootNavigator: true,
          useSafeArea: true,
        ),
        menuItemStyleData: MenuItemStyleData(
          height: (rItemHeight ?? 200).r,
          padding: const MyEdgeInsets.only(left: 30, right: 30),
          selectedMenuItemBuilder: (context, child) {
            final height = (rItemHeight ?? 200).r;
            return Container(
              height: height,
              width: double.infinity,
              margin: const MyEdgeInsets.only(left: 30, right: 30),
              padding: const MyEdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                color: switchDecoration.dropSelectItemBackgroundColor,
                borderRadius: const MyBorderRadius(MyRadius(40)),
              ),
              child: Row(
                children: [
                  Container(
                    height: height / 2,
                    width: 16.r,
                    decoration: BoxDecoration(
                      color: MyColors_e.blue_tianyi,
                      borderRadius: MyBorderRadius.circularRInt(10),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyAdaptSwitchText<T> extends StatelessWidget {
  final List<T> values;
  final String Function(T) toName;
  final String? Function(T)? toDepict;
  final void Function(T?) onChanged;
  final T? selectValue;
  final T? defaultValue;
  final double itemWidth;

  const MyAdaptSwitchText({
    super.key,
    required this.values,
    required this.toName,
    required this.onChanged,
    this.toDepict,
    this.selectValue,
    this.defaultValue,
    required this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      if (itemWidth * values.length > constraints.maxWidth) {
        // 超过可用宽度，采用下拉选择
        return MyDropdownButton<T>(
          values: values,
          toName: toName,
          toDepict: toDepict,
          onChanged: onChanged,
          selectValue: selectValue,
          defaultValue: defaultValue,
        );
      } else {
        return MySwitchText(
          values: values,
          valuesText: List.generate(
            values.length,
            (index) => toName.call(values[index]),
          ),
          current: selectValue,
          onChanged: onChanged,
        );
      }
    });
  }
}
