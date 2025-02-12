// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/componets/global/MyAnimated.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyBtn.dart';
import 'MyScreenUtil.dart';
import 'MySvg.dart';
import 'MyText.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';

class MyInputBase extends StatelessWidget {
  final Objxx_c<String> bindStr;
  final void Function(TextEditingController)? onTap, onTapOutside;
  final void Function(String)? onChange;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enable;
  final isFormat = MyRxObj_c(true);
  final RegExp? regex;
  final String? hintText, labelText, helpText, errText;
  final double? width, height;
  final int rFontSize;
  final TextInputType? keyboardType; // 键盘类型
  final int? maxLines, minLines; // 最大行数
  final String? prefixSvgName;
  final int? countMaxLimit; //  最大计数
  final Iterable<String>? autofillHints;
  late final MyRxObj_c<int> countNum;

  MyInputBase(
    this.bindStr, {
    super.key,
    this.hintText,
    this.labelText,
    this.helpText,
    this.errText,
    this.regex,
    this.countMaxLimit,
    this.onChange,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.enable = true,
    this.width = double.infinity,
    double? height,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixSvgName,
    TextEditingController? controller,
    this.focusNode,
    this.obscureText = false,
    this.autofillHints = const <String>[],
    int? rFontSize,
  })  : height = height ?? (300.r),
        rFontSize = rFontSize ?? 42,
        controller = controller ?? TextEditingController() {
    this.controller.text = bindStr.value;
    this.controller.selection = TextSelection(
      baseOffset: bindStr.value.length,
      extentOffset: 0,
    );
    if (null != countMaxLimit) {
      countNum = MyRxObj_c(bindStr.value.length);
    }
    flushInput(bindStr.value);
  }

  void flushInput(String str) {
    bindStr.value = str;
    flushIsFormat();
    flushCountNum();
    if (null != onChange) {
      onChange!(str);
    }
  }

  void flushCountNum() {
    if (null != countMaxLimit) {
      countNum.value = bindStr.value.length;
    }
  }

  /// 刷新格式验证状态
  void flushIsFormat() {
    isFormat.value = (null == regex) || (regex!.hasMatch(bindStr.value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return TextSelectionTheme(
      data: MyGlobalStoreBase.theme_s.themeData.textSelectionTheme,
      child: Obx(() => TextField(
            autofillHints: autofillHints,
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            focusNode: focusNode,
            keyboardType: keyboardType,
            autofocus: false,
            scrollPadding: EdgeInsets.zero,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            onChanged: flushInput,
            onSubmitted: onSubmitted,
            onTap: (null != onTap) ? () => onTap?.call(controller) : null,
            onTapOutside: (null != onTapOutside)
                ? (event) => onTapOutside?.call(controller)
                : null,
            obscureText: obscureText,
            onEditingComplete: onEditingComplete,
            cursorOpacityAnimates: MyGlobalStoreBase.setting_s.isableAnimated(
              MyAnimatedLevel_e.Medium,
            ),
            style: MyTextMainStyle(
              color: (isFormat.value) ? theme.textMainColor : theme.errorColor,
              rFontSize: rFontSize,
            ),
            decoration: InputDecoration(
              enabled: enable,
              isDense: true,
              border: InputBorder.none,
              prefixIcon: (null != prefixSvgName)
                  ? SizedBox(
                      width: height,
                      height: height,
                      child: Center(
                        child: MySvg(
                          svgName: prefixSvgName!,
                          size: (null != height) ? (height! / 2) : (100.r),
                        ),
                      ),
                    )
                  : null,
              labelText: labelText,
              labelStyle: MyTextCrossStyle(rFontSize: rFontSize),
              hintText: hintText, //默认字符串
              hintStyle: MyTextCrossStyle(rFontSize: rFontSize),
              helperText: isFormat.value ? helpText : null,
              helperStyle: const MyTextCrossStyle(),
              errorText: isFormat.value ? null : errText,
              errorStyle: MyTextCrossStyle(color: theme.errorColor),
              counter: (null != countMaxLimit)
                  ? Obx(() => MyTextCross("${countNum.value}/$countMaxLimit"))
                  : null,
            ),
          )),
    );
  }
}

class MyInput extends StatelessWidget {
  final void Function(TextEditingController)? onTap, onTapOutside;
  final void Function(String)? onChange;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final Objxx_c<String> bindStr;
  final RegExp? regex;
  final String? hintText, labelText, helpText, errText;
  final double? width, height;
  final int? rFontSize;
  final TextInputType? keyboardType; // 键盘类型
  final int? maxLines, minLines; // 最大行数
  final String? prefixSvgName;
  final FocusNode? focusNode;
  final int? countMaxLimit;
  final EdgeInsetsGeometry? padding, margin;
  final Widget? action;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final bool isInContent;

  const MyInput(
    this.bindStr, {
    super.key,
    this.hintText,
    this.labelText,
    this.helpText,
    this.errText,
    this.regex,
    this.countMaxLimit,
    this.onTap,
    this.onTapOutside,
    this.onChange,
    this.onEditingComplete,
    this.onSubmitted,
    this.width = double.infinity,
    this.height,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixSvgName,
    this.focusNode,
    this.rFontSize,
    this.controller,
    this.margin,
    this.padding,
    this.action,
    this.autofillHints = const <String>[],
    this.obscureText = false,
    this.isInContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final size = height ?? 200.r;
    return Container(
      width: width,
      margin: margin ?? const MyEdgeInsets.all(30),
      padding: padding ?? const MyEdgeInsets.all(30),
      decoration: theme.inputDecoration?.call(size, isInContent),
      child: Row(
        children: [
          Expanded(
            child: MyInputBase(
              bindStr,
              key: super.key,
              hintText: hintText,
              labelText: labelText,
              helpText: helpText,
              errText: errText,
              regex: regex,
              countMaxLimit: countMaxLimit,
              onTap: onTap,
              onTapOutside: onTapOutside,
              onChange: onChange,
              onEditingComplete: onEditingComplete,
              onSubmitted: onSubmitted,
              obscureText: obscureText,
              width: width,
              height: size,
              keyboardType: keyboardType,
              maxLines: maxLines,
              prefixSvgName: prefixSvgName,
              controller: controller,
              focusNode: focusNode,
              rFontSize: rFontSize,
              autofillHints: autofillHints,
            ),
          ),
          if (null != action) action!
        ],
      ),
    );
  }
}

class MyInputPasswd extends StatelessWidget {
  final enableHide = MyRxObj_c(true);
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final Objxx_c<String> bindStr;
  final RegExp? regex;
  final Iterable<String>? autofillHints;
  final String? hintText, labelText, helpText, errText;
  final int? countMaxLimit;
  final bool isInContent;

  MyInputPasswd(
    this.bindStr, {
    super.key,
    this.onEditingComplete,
    this.onSubmitted,
    this.regex,
    this.hintText,
    this.labelText,
    this.helpText,
    this.errText,
    this.countMaxLimit,
    this.autofillHints = const <String>[],
    this.isInContent = false,
  });

  void shiftEnableHide() {
    enableHide.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => MyInput(
          bindStr,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          regex: regex,
          hintText: hintText,
          labelText: labelText,
          helpText: helpText,
          errText: errText,
          obscureText: enableHide.value,
          autofillHints: autofillHints,
          countMaxLimit: countMaxLimit,
          isInContent: isInContent,
          action: MyBtn.simple(
            onTap: shiftEnableHide,
            svgName:
                (enableHide.value) ? MySvgNames_e.eye_d : MySvgNames_e.eye_l,
          ),
        ));
  }
}
