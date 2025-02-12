// ignore_for_file: file_names, constant_identifier_names, non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';

enum MyAnimatedLevel_e {
  Undefined,
  Disable,
  Low,
  Medium,
  Height,
}

class MyAnimatedLevel_c {
  static int levelToInt(MyAnimatedLevel_e level) {
    switch (level) {
      case MyAnimatedLevel_e.Undefined:
        return -1;
      case MyAnimatedLevel_e.Disable:
        return 10;
      case MyAnimatedLevel_e.Low:
        return 20;
      case MyAnimatedLevel_e.Medium:
        return 30;
      case MyAnimatedLevel_e.Height:
        return 40;
    }
  }

  static MyAnimatedLevel_e intToLevel(int? level) {
    switch (level) {
      case -1:
        return MyAnimatedLevel_e.Undefined;
      case 10:
        return MyAnimatedLevel_e.Disable;
      case 20:
        return MyAnimatedLevel_e.Low;
      case 30:
        return MyAnimatedLevel_e.Medium;
      case 40:
        return MyAnimatedLevel_e.Height;
    }
    return MyAnimatedLevel_e.Undefined;
  }

  static int compareTo(MyAnimatedLevel_e left, MyAnimatedLevel_e right) {
    return (left.index - right.index);
  }

  static bool isEnable(
      MyAnimatedLevel_e useLevel, MyAnimatedLevel_e needLevel) {
    return (MyAnimatedLevel_e.Disable != useLevel &&
        MyAnimatedLevel_e.Disable != needLevel &&
        (useLevel.index - needLevel.index) >= 0);
  }
}

Widget MyAnimatedSimpleBuilder({
  required Widget child,
  required Widget Function(
    Widget child,
  ) animatedBuilder,
  MyAnimatedLevel_e level = MyAnimatedLevel_e.Medium,
}) {
  if (MyAnimatedLevel_c.isEnable(
    MyGlobalStoreBase.setting_s.useAnimatedLevel,
    level,
  )) {
    // 设置动画等级大于等于该组件动画等级
    return animatedBuilder(child);
  } else {
    return child;
  }
}

Widget MyAnimatedBuilder<T>({
  required Widget Function(
    bool enableAnimated,
    T? bindValue,
  ) childBuilder,
  required Widget Function(
    Widget Function(
      bool enableAnimated,
      T? bindValue,
    ) childBuilder,
    bool enableAnimated,
    T? bindValue,
  ) animatedDetialBuilder,
  MyAnimatedLevel_e level = MyAnimatedLevel_e.Medium,
  T? bindValue,
}) {
  if (MyAnimatedLevel_c.isEnable(
    MyGlobalStoreBase.setting_s.useAnimatedLevel,
    level,
  )) {
    // 设置动画等级大于等于该组件动画等级
    return animatedDetialBuilder(
      childBuilder,
      true,
      bindValue,
    );
  } else {
    return childBuilder(
      false,
      bindValue,
    );
  }
}
