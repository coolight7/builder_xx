// ignore_for_file: camel_case_types, constant_identifier_names, file_names

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/componets/global/MyImageBase.dart';
import 'package:flutter_util_xx/flutter_util_xx.dart';
import 'package:util_xx/util_xx.dart';
import 'package:builder_xx/util/MySrc.dart';
import 'MyGlobalStoreBase.dart';
import 'MyStore.dart';
import '/manager/MyTheme.dart';
import '/componets/global/MyPopup.dart';

class MyThemeStoreBase extends MyStore {
  final defFontFamily = Platformxx_c.isDesktop ? "HarmonyOS_Sans" : null;
  final themeIndex = Streamxx_c.listener(value: MyThemeIndex_e.None);

  /// 当前使用的主题是否是用户指定的
  /// * 当用户临时切换主题时，则用该值标记 true
  bool isCustomSet = false;

  /// 转 白昼 模式的时间点
  var toLightTime = const TimeOfDay(hour: 7, minute: 0);

  /// 转 夜间 模式的时间点
  var toNightTime = const TimeOfDay(hour: 18, minute: 0);

  /// 记录上一次执行的位置
  int? followTimeRunPoint;

  /// 跟随时间定时检查
  Timer? followTimeTimer;

  /// 主题切换使用模式
  MyThemeUseModel_e useModel = MyThemeUseModel_e.followSystem;

  /// 白昼模式使用的主题
  MyThemeIndex_e lightIndex = MyThemeIndex_e.mimicryLight;

  /// 夜间模式使用的主题
  MyThemeIndex_e nightIndex = MyThemeIndex_e.mimicryNight;

  /// 背景图片
  var lightBackImg = MyThemeBackgroundImg_c();
  var nightBackImg = MyThemeBackgroundImg_c();

  /// 窗口背景样式
  MyThemeWindowBackgroundStyle_e windowBackgroundStyle =
      MyThemeWindowBackgroundStyle_e.None;
  MyThemeWindowBackgroundStyle_e useWindowBackgroundStyle =
      MyThemeWindowBackgroundStyle_e.None;

  /// 整个窗口的缩放比例
  double windowScale = 1.0;

  /// 整个窗口的边距
  MyPadding_c windowPadding = MyPadding_c();

  /// 窗口宽高
  double get windowHeight =>
      ScreenUtil().screenHeight *
      (1 - windowPadding.top - windowPadding.bottom);
  double get windowWidth =>
      ScreenUtil().screenWidth * (1 - windowPadding.left - windowPadding.right);
  double get windowMinLine => math.min(windowHeight, windowWidth);
  double get windowMaxLine => math.max(windowHeight, windowWidth);
  double get windowContentHeight => windowHeight;

  /// 页面构建内容大小
  double get pageContentHeight => windowHeight;
  double get pageContentWidth => windowWidth;

  /// 使用默认主题样式
  bool get useNormalStyle =>
      (false == isWindowBackgroundStyle() && null == getBackgroundImg());
  bool get useSimpleStyle =>
      (isWindowBackgroundStyle() || null != getBackgroundImg());

  /// 是否启用夜间模式时给部分图片增加阴影遮罩
  bool enableNightImageForegroundColor = false;
  final Color _imageForegroundColor = MyColors_e.black.withOpacity(0.5);

  final bool isMainApp;

  late ThemeData themeData;
  MyTheme_c get mytheme => themeData.extension<MyTheme_c>()!;
  Color? get imageForegroundColor {
    if (isNight() && enableNightImageForegroundColor) {
      return _imageForegroundColor;
    } else {
      return null;
    }
  }

  MyThemeStoreBase(this.isMainApp) {
    themeData = MyTheme_c.getBaseTheme();
  }

  void followingSystem({
    bool doForceUpdate = true,
  }) {
    if (PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
      // 调用前为light，改为night
      useNight(doForceUpdate: doForceUpdate);
    } else {
      useLight(doForceUpdate: doForceUpdate);
    }
  }

  // 跟随系统变化
  void setFollowingSystem() {
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      // 设置跟随系统主题变化
      followingSystem();
    };
  }

  /// 取消跟随系统主题变化
  void cancleFollowSystem() {
    PlatformDispatcher.instance.onPlatformBrightnessChanged = null;
  }

  /// 返回触发执行的点
  int? followingTime({
    int? notDoPoint,
    bool doForceUpdate = true,
  }) {
    /// * 类型1：
    /// --------------|----------------------|-------------
    /// 0    -N-      L         -L-          N     -N-    24
    /// *
    ///
    ///      p0                 p1                 p2
    ///
    /// * 类型2：
    /// --------------|----------------------|-------------
    /// 0    -L-      N         -N-          L     -L-    24
    ///
    final now = TimeOfDay.now();
    final nowNum = now.hour * 60 + now.minute;
    final lightNum = toLightTime.hour * 60 + toLightTime.minute;
    final nightNum = toNightTime.hour * 60 + toNightTime.minute;
    if (lightNum <= nightNum) {
      // 类型1
      if (nowNum >= lightNum && nowNum < nightNum) {
        // p1 时间段
        if (false == isUseLightIndex() && 1 != notDoPoint) {
          // 应当转换 light
          useLight(doForceUpdate: doForceUpdate);
          return 1;
        }
      } else {
        if (false == isUseNightIndex() && 2 != notDoPoint) {
          useNight(doForceUpdate: doForceUpdate);
          return 2;
        }
      }
    } else {
      // 类型2
      if (nowNum >= nightNum && nowNum < lightNum) {
        // p1 时间段
        if (false == isUseNightIndex() && 3 != notDoPoint) {
          // 应当转换为夜间模式
          useNight(doForceUpdate: doForceUpdate);
          return 3;
        }
      } else {
        if (false == isUseLightIndex() && 4 != notDoPoint) {
          // 应当转换为白昼模式
          useLight(doForceUpdate: doForceUpdate);
          return 4;
        }
      }
    }
    return null;
  }

  void setFollowingTime() {
    isCustomSet = false;
    followTimeTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        final rePoint = followingTime(
          notDoPoint: followTimeRunPoint,
        );
        if (null != rePoint) {
          followTimeRunPoint = rePoint;
        }
      },
    );
  }

  void cancleFollowTime() {
    followTimeTimer?.cancel();
    followTimeTimer = null;
    followTimeRunPoint = null;
  }

  void useLight({
    bool doForceUpdate = true,
  }) {
    setIndex(
      lightIndex,
      doRebuild: doForceUpdate,
    );
  }

  void useNight({
    bool doForceUpdate = true,
  }) {
    setIndex(
      nightIndex,
      doRebuild: doForceUpdate,
    );
  }

  void setCustom(void Function() fun) {
    fun.call();
    isCustomSet = true;
  }

  /// 设置主题切换模式
  void setUseModel(
    MyThemeUseModel_e model, {
    bool doRebuild = true,
    bool isMustSetTheme = false,
  }) {
    // 取消原先模式的影响
    switch (useModel) {
      case MyThemeUseModel_e.Light:
      case MyThemeUseModel_e.Night:
        break;
      case MyThemeUseModel_e.followSystem:
        cancleFollowSystem();
        break;
      case MyThemeUseModel_e.followTime:
        cancleFollowTime();
        break;
    }
    // 赋新值
    useModel = model;
    // 添加新模式的影响
    switch (useModel) {
      case MyThemeUseModel_e.Light:
        useLight(doForceUpdate: doRebuild);
        break;
      case MyThemeUseModel_e.Night:
        useNight(doForceUpdate: doRebuild);
        break;
      case MyThemeUseModel_e.followSystem:
        followingSystem(doForceUpdate: doRebuild);
        setFollowingSystem();
        break;
      case MyThemeUseModel_e.followTime:
        followTimeRunPoint = followingTime(doForceUpdate: doRebuild);
        setFollowingTime();
        break;
    }
    update();
  }

  MyThemeIndex_e getIndex() {
    return themeIndex.value;
  }

  Future<void> setIndex(
    MyThemeIndex_e index, {
    bool doRebuild = true,
  }) async {
    themeIndex.value = index;
    switch (index) {
      case MyThemeIndex_e.None:
        themeData = MyTheme_c.getBaseTheme();
      case MyThemeIndex_e.mimicryLight:
        themeData = MyTheme_c.mimicryLight();
      case MyThemeIndex_e.mimicryNight:
        themeData = MyTheme_c.mimicryNight();
    }
    updateWindowBackgroundStyle();
    // Get.changeTheme(themeData);
    MyPopup.setStyle();
    if (doRebuild) {
      MyGlobalStoreBase.appRebuild(immediately: true);
    }
    if (null != themeData.appBarTheme.systemOverlayStyle) {
      SystemChrome.setSystemUIOverlayStyle(
        themeData.appBarTheme.systemOverlayStyle!,
      );
    }
  }

  bool setLightIndex(MyThemeIndex_e index, {bool doRebuild = true}) {
    switch (index) {
      case MyThemeIndex_e.mimicryLight:
        lightIndex = index;
        setUseModel(useModel, doRebuild: doRebuild);
        return true;
      case MyThemeIndex_e.None:
      case MyThemeIndex_e.mimicryNight:
        return false;
    }
  }

  bool setNightIndex(MyThemeIndex_e index, {bool doRebuild = true}) {
    switch (index) {
      case MyThemeIndex_e.None:
      case MyThemeIndex_e.mimicryLight:
        return false;
      case MyThemeIndex_e.mimicryNight:
        nightIndex = index;
        setUseModel(useModel, doRebuild: doRebuild);
        return true;
    }
  }

  /// 当前使用的是否为白昼主题
  bool isLight() {
    switch (themeIndex.value) {
      case MyThemeIndex_e.mimicryLight:
        return true;
      case MyThemeIndex_e.None:
      case MyThemeIndex_e.mimicryNight:
        return false;
    }
  }

  /// 当前使用的是否为夜间主题
  bool isNight() {
    switch (themeIndex.value) {
      case MyThemeIndex_e.None:
      case MyThemeIndex_e.mimicryLight:
        return false;
      case MyThemeIndex_e.mimicryNight:
        return true;
    }
  }

  /// 当前使用的是否为 [lightIndex] 指定的主题
  bool isUseLightIndex() {
    return (lightIndex == themeIndex.value);
  }

  /// 当前使用的是否为 [nightIndex] 指定的主题
  bool isUseNightIndex() {
    return (nightIndex == themeIndex.value);
  }

  MySrcImage_c? getBackgroundImg() {
    if (isLight()) {
      return lightBackImg.img;
    } else {
      return nightBackImg.img;
    }
  }

  MySrcImage_c? getMusicWarpBackgroundImg() {
    if (isLight()) {
      return lightBackImg.musicWarpImg;
    } else {
      return nightBackImg.musicWarpImg;
    }
  }

  Future<void> initWindowsBackgroundStyle(
    MyThemeWindowBackgroundStyle_e? type,
  ) async {
    useWindowBackgroundStyle = (type ?? MyThemeWindowBackgroundStyle_e.None);
    windowBackgroundStyle = useWindowBackgroundStyle;
  }

  Future<void> setWindowBackgroundStyle(
    MyThemeWindowBackgroundStyle_e type,
  ) async {
    windowBackgroundStyle = type;
    update();
  }

  bool isWindowBackgroundStyle() {
    return (MyThemeWindowBackgroundStyle_e.None != useWindowBackgroundStyle);
  }

  Future<void> updateWindowBackgroundStyle() async {}

  Future<void> setFollowingTimeToLightTime(TimeOfDay time) async {
    toLightTime = time;
    if (useModel == MyThemeUseModel_e.followTime) {
      followingTime();
    }
    update();
  }

  Future<void> setFollowingTimeToNightTime(TimeOfDay time) async {
    toNightTime = time;
    if (useModel == MyThemeUseModel_e.followTime) {
      followingTime();
    }
    update();
  }

  Future<void> setEnableNightImageForegroundColor(
    bool? enable, {
    bool doForceUpdate = true,
  }) async {
    enableNightImageForegroundColor =
        enable ?? !enableNightImageForegroundColor;
    update();
    if (doForceUpdate && isNight()) {
      // 如果当前是night()，则刷新显示效果
      return MyGlobalStoreBase.appRebuild();
    }
  }

  Future<void> setWindowScan(
    double scan, {
    bool doRebuild = true,
  }) async {
    windowScale = scan;
    update();
    // 刷新显示效果
    if (doRebuild) {
      return MyGlobalStoreBase.appRebuild(immediately: true);
    }
  }

  void setWindowPadding(
    MyPadding_c padding, {
    bool doRebuild = true,
  }) async {
    windowPadding = padding;
    update();
    // 刷新显示效果
    if (doRebuild) {
      MyGlobalStoreBase.appRebuild(immediately: true);
    }
  }
}

class MyPadding_c {
  double top;
  double bottom;
  double left;
  double right;

  MyPadding_c({
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
  });

  factory MyPadding_c.fromJson(Map<String, dynamic> json) {
    return MyPadding_c(
      top: json["top"] ?? 0,
      bottom: json["bottom"] ?? 0,
      left: json["left"] ?? 0,
      right: json["right"] ?? 0,
    );
  }

  static MyPadding_c fromJsonStr(String json) {
    try {
      return MyPadding_c.fromJson(convert.jsonDecode(json));
    } catch (e) {
      return MyPadding_c();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "top": top,
      "bottom": bottom,
      "left": left,
      "right": right,
    };
  }
}

enum MyThemeIndex_e {
  /// 还未初始化
  None,

  /// 拟物
  mimicryLight,
  mimicryNight,
}

class MyThemeIndex_c {
  static int toInt(MyThemeIndex_e index) {
    switch (index) {
      case MyThemeIndex_e.None:
        return -1;
      case MyThemeIndex_e.mimicryLight:
        return 0;
      case MyThemeIndex_e.mimicryNight:
        return 1;
    }
  }

  static MyThemeIndex_e? toEnum(int index) {
    switch (index) {
      case 0:
        return MyThemeIndex_e.mimicryLight;
      case 1:
        return MyThemeIndex_e.mimicryNight;
    }
    return null;
  }
}

enum MyThemeUseModel_e {
  Light, // 固定极昼
  Night, // 固定极夜
  followSystem, // 跟随系统
  followTime, // 跟随时间
}

class MyThemeUseModel_c {
  static String toName(MyThemeUseModel_e type) {
    switch (type) {
      case MyThemeUseModel_e.followSystem:
        return "跟随系统";
      case MyThemeUseModel_e.followTime:
        return "跟随时间";
      case MyThemeUseModel_e.Light:
        return "固定白昼";
      case MyThemeUseModel_e.Night:
        return "固定夜间";
    }
  }

  // [MyThemeUseModel_e] 转换
  static int toInt(MyThemeUseModel_e model) {
    switch (model) {
      case MyThemeUseModel_e.Light:
        return 1;
      case MyThemeUseModel_e.Night:
        return 2;
      case MyThemeUseModel_e.followSystem:
        return 3;
      case MyThemeUseModel_e.followTime:
        return 4;
    }
  }

  static MyThemeUseModel_e? toEnum(int model) {
    switch (model) {
      case 1:
        return MyThemeUseModel_e.Light;
      case 2:
        return MyThemeUseModel_e.Night;
      case 3:
        return MyThemeUseModel_e.followSystem;
      case 4:
        return MyThemeUseModel_e.followTime;
    }
    return null;
  }
}

/// 窗口背景样式类型
enum MyThemeWindowBackgroundStyle_e {
  /// 无
  None,

  /// 透明
  Transparent,

  /// 半透明
  TransparentColor,

  /// 模糊
  Acrylic,

  /// 模糊 云母
  Mica,
}

class MyThemeWindowBackgroundStyle_c {
  static bool isSupport() {
    return Platformxx_c.isDesktop;
  }

  static int toInt(MyThemeWindowBackgroundStyle_e type) {
    switch (type) {
      case MyThemeWindowBackgroundStyle_e.None:
        return 1;
      case MyThemeWindowBackgroundStyle_e.Transparent:
        return 2;
      case MyThemeWindowBackgroundStyle_e.TransparentColor:
        return 3;
      case MyThemeWindowBackgroundStyle_e.Acrylic:
        return 4;
      case MyThemeWindowBackgroundStyle_e.Mica:
        return 5;
    }
  }

  static MyThemeWindowBackgroundStyle_e? toEnum(int type) {
    switch (type) {
      case 1:
        return MyThemeWindowBackgroundStyle_e.None;
      case 2:
        return MyThemeWindowBackgroundStyle_e.Transparent;
      case 3:
        return MyThemeWindowBackgroundStyle_e.TransparentColor;
      case 4:
        return MyThemeWindowBackgroundStyle_e.Acrylic;
      case 5:
        return MyThemeWindowBackgroundStyle_e.Mica;
    }
    return null;
  }

  static String toName(MyThemeWindowBackgroundStyle_e type) {
    switch (type) {
      case MyThemeWindowBackgroundStyle_e.None:
        return "默认";
      case MyThemeWindowBackgroundStyle_e.Transparent:
        return "透明";
      case MyThemeWindowBackgroundStyle_e.TransparentColor:
        return "半透明";
      case MyThemeWindowBackgroundStyle_e.Acrylic:
        return "模糊 • 毛玻璃";
      case MyThemeWindowBackgroundStyle_e.Mica:
        return "模糊 • 云母";
    }
  }
}

/// 自定义主题
class MyThemeCustom_c {
  Color? btnContentColor; // 按钮内容颜色
  Color? btnSimpleContentColor; // 简约按钮的内容颜色
  Color? btnSelectContentColor; // 按钮选中时内容颜色
  Color? btnDisableContentColor; // 按钮禁用提示色

  Color? tagBackgroundColor; // 标签颜色

  Color? textMainColor; // 主要内容字符串颜色
  Color? textCrossColor; // 次要内容字符串颜色

  Color? switchBoolBackgroundColor; // 开关背景颜色
  Color? switchBoolSelectItemColor; // 开关项颜色
  Color? switchTextBackgroundColor; // 文字选择颜色
  Color? switchTextSelectItemColor; // 文字项颜色

  Color? progressColor; // 进度条颜色
  Color? progressAudioCurrentColor; // 音乐播放进度条颜色

  MyThemeCustom_c({
    this.btnContentColor,
    this.btnSimpleContentColor,
    this.btnSelectContentColor,
    this.btnDisableContentColor,
    this.tagBackgroundColor,
    this.textMainColor,
    this.textCrossColor,
    this.switchBoolSelectItemColor,
    this.switchBoolBackgroundColor,
    this.switchTextSelectItemColor,
    this.switchTextBackgroundColor,
    this.progressColor,
    this.progressAudioCurrentColor,
  });

  factory MyThemeCustom_c.fromJson(Map<String, dynamic> json) {
    return MyThemeCustom_c(
      btnContentColor:
          FlutterParsexx_c.parseString2Color(json["btnContentColor"]),
      btnSimpleContentColor:
          FlutterParsexx_c.parseString2Color(json["btnSimpleContentColor"]),
      btnSelectContentColor:
          FlutterParsexx_c.parseString2Color(json["btnSelectContentColor"]),
      btnDisableContentColor:
          FlutterParsexx_c.parseString2Color(json["btnDisableContentColor"]),
      tagBackgroundColor:
          FlutterParsexx_c.parseString2Color(json["tagBackgroundColor"]),
      textMainColor: FlutterParsexx_c.parseString2Color(json["textMainColor"]),
      textCrossColor:
          FlutterParsexx_c.parseString2Color(json["textCrossColor"]),
      switchBoolSelectItemColor:
          FlutterParsexx_c.parseString2Color(json["switchBoolSelectItemColor"]),
      switchBoolBackgroundColor:
          FlutterParsexx_c.parseString2Color(json["switchBoolBackgroundColor"]),
      switchTextSelectItemColor:
          FlutterParsexx_c.parseString2Color(json["switchTextSelectItemColor"]),
      switchTextBackgroundColor:
          FlutterParsexx_c.parseString2Color(json["switchTextBackgroundColor"]),
      progressColor: FlutterParsexx_c.parseString2Color(json["progressColor"]),
      progressAudioCurrentColor:
          FlutterParsexx_c.parseString2Color(json["progressAudioCurrentColor"]),
    );
  }

  static MyThemeCustom_c? fromJsonStr(
    String json, {
    Objxx_c<String>? error,
  }) {
    try {
      return MyThemeCustom_c.fromJson(convert.jsonDecode(json));
    } catch (e) {
      error?.value = e.toString();
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "btnContentColor": FlutterParsexx_c.parseColor2String(btnContentColor),
      "btnSimpleContentColor":
          FlutterParsexx_c.parseColor2String(btnSimpleContentColor),
      "btnSelectContentColor":
          FlutterParsexx_c.parseColor2String(btnSelectContentColor),
      "btnDisableContentColor":
          FlutterParsexx_c.parseColor2String(btnDisableContentColor),
      "tagBackgroundColor":
          FlutterParsexx_c.parseColor2String(tagBackgroundColor),
      "textMainColor": FlutterParsexx_c.parseColor2String(textMainColor),
      "textCrossColor": FlutterParsexx_c.parseColor2String(textCrossColor),
      "switchBoolSelectItemColor":
          FlutterParsexx_c.parseColor2String(switchBoolSelectItemColor),
      "switchBoolBackgroundColor":
          FlutterParsexx_c.parseColor2String(switchBoolBackgroundColor),
      "switchTextSelectItemColor":
          FlutterParsexx_c.parseColor2String(switchTextSelectItemColor),
      "switchTextBackgroundColor":
          FlutterParsexx_c.parseColor2String(switchTextBackgroundColor),
      "progressColor": FlutterParsexx_c.parseColor2String(progressColor),
      "progressAudioCurrentColor":
          FlutterParsexx_c.parseColor2String(progressAudioCurrentColor),
    };
  }

  String toViewString() {
    return toString()
        .replaceAll('{', '{\n')
        .replaceAll(':', ' : ')
        .replaceAll('[', '[\n')
        .replaceAll(',', ',\n')
        .replaceAll('}', '\n}')
        .replaceAll(']', '\n]');
  }

  @override
  String toString() {
    return convert.jsonEncode(toJson());
  }
}

class MyThemeBackgroundImg_c {
  MySrcImage_c? img;
  MySrcImage_c? musicWarpImg;

  MyThemeBackgroundImg_c({
    this.img,
    this.musicWarpImg,
  });

  bool isEmpty() {
    return (null == img && null == musicWarpImg);
  }

  factory MyThemeBackgroundImg_c.fromJson(Map<String, dynamic> json) {
    final img = json["img"];
    final musicWarpImg = json["musicWarpImg"];
    return MyThemeBackgroundImg_c(
      img: MySrcImage_c.fromMySrcOrNull(
        MySrc_c.fromStringOrNull<MySrcInfo_c>(
          img,
          MySrcInfo_c(),
        ),
      ),
      musicWarpImg: MySrcImage_c.fromMySrcOrNull(
        MySrc_c.fromStringOrNull<MySrcInfo_c>(
          musicWarpImg,
          MySrcInfo_c(),
        ),
      ),
    );
  }

  factory MyThemeBackgroundImg_c.fromJsonStr(String json) {
    try {
      return MyThemeBackgroundImg_c.fromJson(convert.jsonDecode(json));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return MyThemeBackgroundImg_c();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "img": img?.toString(),
      "musicWarpImg": musicWarpImg?.toString(),
    };
  }
}
