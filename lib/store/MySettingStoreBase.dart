// ignore_for_file: file_names, camel_case_types, constant_identifier_names, non_constant_identifier_names

import 'package:builder_xx/componets/global/MyList.dart';
import 'package:builder_xx/store/MyStore.dart';
import 'package:builder_xx/componets/global/MyAnimated.dart';

import 'MyGlobalStoreBase.dart';

class MySettingStoreBase extends MyStore {
  /// 沉浸模式
  MyImmersionModel_e immersionModelType = MyImmersionModel_e.OnlyHide;

  bool get isImmersionModel {
    switch (immersionModelType) {
      case MyImmersionModel_e.OnlyHide:
      case MyImmersionModel_e.HideAndLock:
        return true;
      case MyImmersionModel_e.Disable:
        return false;
    }
  }

  /// 使用的动画等级
  MyAnimatedLevel_e useAnimatedLevel = MyAnimatedLevel_e.Height;

  /// 在歌曲列表中显示歌曲图
  bool showIconInList = true;

  /// 列表边界渐变
  bool showListMask = false;

  /// 网格布局
  MyListLayoutType_e listLayoutType = MyListLayoutType_e.Auto;

  MySettingStoreBase.buildInstance();

  bool isableAnimated(MyAnimatedLevel_e level) {
    return MyAnimatedLevel_c.isEnable(useAnimatedLevel, level);
  }

  T switchValueAnimatedLevel<T>(
    MyAnimatedLevel_e level, {
    required T enableValue,
    required T disableValue,
  }) {
    if (isableAnimated(level)) {
      return enableValue;
    }
    return disableValue;
  }

  void setEnableAnimatedLevel(
    MyAnimatedLevel_e level, {
    bool doRebuild = true,
  }) {
    useAnimatedLevel = level;
    update();
    if (doRebuild) {
      MyGlobalStoreBase.appRebuild();
    }
  }
}

enum MyImmersionModel_e {
  /// 仅隐藏
  OnlyHide,

  /// 隐藏并锁定触摸
  HideAndLock,
  Disable,
}

class MyImmersionModel_c {
  static String toName(MyImmersionModel_e type) {
    switch (type) {
      case MyImmersionModel_e.Disable:
        return "关闭";
      case MyImmersionModel_e.OnlyHide:
        return "隐藏";
      case MyImmersionModel_e.HideAndLock:
        return "隐藏并锁定";
    }
  }

  static String toDepict(MyImmersionModel_e type) {
    switch (type) {
      case MyImmersionModel_e.Disable:
        return "";
      case MyImmersionModel_e.OnlyHide:
        return "播放页面一段时间不操作后隐藏部分按钮。";
      case MyImmersionModel_e.HideAndLock:
        return """• 播放页面一段时间不操作后隐藏部分按钮。
• 并锁定播放页面底部控制栏，上拉页面后显示。
• 使用鼠标时效果等同 [隐藏]""";
    }
  }

  static int toInt(MyImmersionModel_e type) {
    switch (type) {
      case MyImmersionModel_e.Disable:
        return 2;
      case MyImmersionModel_e.OnlyHide:
        return 3;
      case MyImmersionModel_e.HideAndLock:
        return 4;
    }
  }

  static MyImmersionModel_e? toEnum(int type) {
    switch (type) {
      // case 1:
      //   return MyImmersionModel_e.Enable;
      case 2:
        return MyImmersionModel_e.Disable;
      case 3:
        return MyImmersionModel_e.OnlyHide;
      case 4:
        return MyImmersionModel_e.HideAndLock;
    }
    return null;
  }
}
