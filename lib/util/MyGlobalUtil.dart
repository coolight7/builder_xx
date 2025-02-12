// ignore_for_file: file_names, non_constant_identifier_names, camel_case_types, constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';

/// 方向
enum MyDirection_e {
  LeftToRight,
  RightToLeft,
  TopToBottom,
  BottomToTop,
}

class MyDirection_c {
  static MyDirection_e? intToMyDirection(int? direction) {
    switch (direction) {
      case 1:
        return MyDirection_e.LeftToRight;
      case 2:
        return MyDirection_e.RightToLeft;
      case 3:
        return MyDirection_e.TopToBottom;
      case 4:
        return MyDirection_e.BottomToTop;
    }
    return null;
  }

  static int myDirectionToInt(MyDirection_e direction) {
    switch (direction) {
      case MyDirection_e.LeftToRight:
        return 1;
      case MyDirection_e.RightToLeft:
        return 2;
      case MyDirection_e.TopToBottom:
        return 3;
      case MyDirection_e.BottomToTop:
        return 4;
    }
  }

  static Alignment textAlignToAlignment(
    TextAlign align, {
    bool row = true,
  }) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        if (row) {
          return Alignment.centerLeft;
        } else {
          return Alignment.topCenter;
        }
      case TextAlign.right:
      case TextAlign.end:
        if (row) {
          return Alignment.centerRight;
        } else {
          return Alignment.bottomCenter;
        }
      case TextAlign.center:
      case TextAlign.justify:
        return Alignment.center;
    }
  }
}

enum MyLoadPlain_e {
  /// 仅使用缓存
  OnlyCache,

  /// 仅进行网络请求
  OnlyNet,

  /// 优先读取缓存，如果缓存存在，则直接返回，否则进行网络请求
  CacheOrNet,

  /// 优先网络请求，如果请求失败，则尝试读取缓存
  NetOrCache,
}

enum MyLoadPlainNetResult_e {
  /// 加载成功
  Success,

  /// 加载失败
  Faild,

  /// 请使用缓存
  UseCache,
}

/// 数据加载计划
class MyLoadPlain_c {
  static Future<bool> inline_load({
    required MyLoadPlain_e loadPlain,
    required Future<bool> Function() inline_byCache,
    required Future<MyLoadPlainNetResult_e> Function(
            Objxx_c<bool>? isRespFaildExternal)
        inline_byNet,
  }) async {
    Future<bool> useNet(Objxx_c<bool>? value) async {
      final result = await inline_byNet(value);
      switch (result) {
        case MyLoadPlainNetResult_e.Success:
          return true;
        case MyLoadPlainNetResult_e.Faild:
          return false;
        case MyLoadPlainNetResult_e.UseCache:
          return await inline_byCache();
      }
    }

    bool rebool = false;
    switch (loadPlain) {
      case MyLoadPlain_e.OnlyCache:
        rebool = await inline_byCache();
        break;
      case MyLoadPlain_e.OnlyNet:
        final result = await inline_byNet(null);
        switch (result) {
          case MyLoadPlainNetResult_e.Success:
            rebool = true;
          case MyLoadPlainNetResult_e.Faild:
          case MyLoadPlainNetResult_e.UseCache:
            rebool = false;
        }
        break;
      case MyLoadPlain_e.CacheOrNet:
        rebool = await inline_byCache();
        if (false == rebool) {
          // 无需尝试 cache
          final result = await inline_byNet(null);
          switch (result) {
            case MyLoadPlainNetResult_e.Success:
              rebool = true;
            case MyLoadPlainNetResult_e.Faild:
            case MyLoadPlainNetResult_e.UseCache:
              rebool = false;
          }
        }
        break;
      case MyLoadPlain_e.NetOrCache:
        final isRespFaildExternal = Objxx_c<bool>(false);
        rebool = await useNet(isRespFaildExternal);
        // 外部错误导致请求失败
        if (false == rebool && true == isRespFaildExternal.value) {
          rebool = await inline_byCache();
        }
        break;
    }
    return rebool;
  }
}

class MyPosition_c {
  double dx;
  double dy;

  MyPosition_c({
    this.dx = 0,
    this.dy = 0,
  });
}

class MyRxObj_c<T> extends Rx<T> {
  MyRxObj_c(super.initial);

  void checkUpdate(T Function(T value) fn) {
    value = fn(value);
  }

  @override
  void update(void Function(T value) fn) {
    fn(value);
    refresh();
  }

  @override
  dynamic toJson() {
    try {
      return (value as dynamic)?.toJson();
    } on Exception catch (_) {
      throw Exception("$T has not method [toJson]");
    }
  }
}

/// 用于包裹判断[value]是否是有效值
class MyAvailableObj_c<T> {
  T? value;
  bool available = false;

  MyAvailableObj_c();

  void setValue(T? in_value) {
    value = in_value;
    available = true;
  }

  void clearValue() {
    value = null;
    available = false;
  }
}

/// 排序升降序枚举
enum MySortOrder_e {
  Desc, // 降序
  Asc, // 升序
}

class MyBoxFit_c {
  static int toInt(BoxFit type) {
    switch (type) {
      case BoxFit.contain:
        return 0;
      case BoxFit.cover:
        return 1;
      case BoxFit.fill:
        return 2;
      case BoxFit.fitHeight:
        return 3;
      case BoxFit.fitWidth:
        return 4;
      case BoxFit.scaleDown:
        return 5;
      case BoxFit.none:
        return 6;
    }
  }

  static BoxFit? toEnum(int? type) {
    switch (type) {
      case 0:
        return BoxFit.contain;
      case 1:
        return BoxFit.cover;
      case 2:
        return BoxFit.fill;
      case 3:
        return BoxFit.fitHeight;
      case 4:
        return BoxFit.fitWidth;
      case 5:
        return BoxFit.scaleDown;
      case 6:
        return BoxFit.none;
    }
    return null;
  }

  static String toName(BoxFit type) {
    switch (type) {
      case BoxFit.contain:
        return "自适应";
      case BoxFit.cover:
        return "充满";
      case BoxFit.fill:
        return "拉伸";
      case BoxFit.fitHeight:
        return "填充高度";
      case BoxFit.fitWidth:
        return "填充宽度";
      case BoxFit.scaleDown:
        return "缩放";
      case BoxFit.none:
        return "无";
    }
  }
}

enum MyAbilityState_e {
  Auto,
  Enable,
  Disable,
}

class MyAbilityState_c {
  static MyAbilityState_e? toEnum(int? type) {
    switch (type) {
      case 1:
        return MyAbilityState_e.Auto;
      case 2:
        return MyAbilityState_e.Enable;
      case 3:
        return MyAbilityState_e.Disable;
    }
    return null;
  }

  static int toInt(MyAbilityState_e type) {
    switch (type) {
      case MyAbilityState_e.Auto:
        return 1;
      case MyAbilityState_e.Enable:
        return 2;
      case MyAbilityState_e.Disable:
        return 3;
    }
  }

  static String toName(MyAbilityState_e type) {
    switch (type) {
      case MyAbilityState_e.Auto:
        return "自动";
      case MyAbilityState_e.Enable:
        return "开启";
      case MyAbilityState_e.Disable:
        return "关闭";
    }
  }
}

class MyGlobalUtil_c {
  static double numLimit(
    double a, {
    required double minLimit,
    required double maxLimit,
  }) {
    if (a <= minLimit) {
      return minLimit;
    } else if (a >= maxLimit) {
      return maxLimit;
    }
    return a;
  }
}
