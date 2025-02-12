// ignore_for_file: file_names, camel_case_types

import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:flutter/widgets.dart';
import 'MyAnimated.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

// 比例，宽 / 高
class MyScaleBreakpoints extends Breakpoint {
  static const MyScaleBreakpoints small = MyScaleBreakpoints(end: 1);
  static const MyScaleBreakpoints medium =
      MyScaleBreakpoints(begin: 1, end: 1.5);
  static const MyScaleBreakpoints large = MyScaleBreakpoints(begin: 1.5);

  static const MyScaleBreakpoints column = MyScaleBreakpoints(end: 1);
  static const MyScaleBreakpoints row = MyScaleBreakpoints(begin: 1);

  static const MyScaleBreakpoints phone = MyScaleBreakpoints(end: 0.68);

  final double? begin;
  final double? end;

  const MyScaleBreakpoints({
    this.begin,
    this.end,
  });

  /// 是否是符合
  bool isConform() {
    // 计算比例
    final scale = MyGlobalStoreBase.theme_s.windowWidth /
        MyGlobalStoreBase.theme_s.windowHeight;
    final double lowerBound = begin ?? double.negativeInfinity;
    final double upperBound = end ?? double.infinity;
    return scale >= lowerBound && scale < upperBound;
  }

  @override
  bool isActive(BuildContext context) {
    return isConform();
  }
}

class MyAdaptiveLayout extends StatelessWidget {
  final double rowBodyRatio, columnBodyRatio;
  final Widget Function(BuildContext context) columnBody;
  final Widget Function(BuildContext context)? columnSecondBody;
  final Widget Function(BuildContext context) rowBody;
  final Widget Function(BuildContext context)? rowSecondBody;
  final bool? enableAnimations;
  final MyScaleBreakpoints columnBreakpoint;
  final MyScaleBreakpoints rowBreakpoint;

  const MyAdaptiveLayout({
    super.key,
    required this.columnBody,
    required this.rowBody,
    this.columnSecondBody,
    this.rowSecondBody,
    this.rowBodyRatio = 0.5,
    this.columnBodyRatio = 0.5,
    this.enableAnimations,
    this.columnBreakpoint = MyScaleBreakpoints.column,
    this.rowBreakpoint = MyScaleBreakpoints.row,
  });

  const MyAdaptiveLayout.onlyBody({
    super.key,
    required this.columnBody,
    required this.rowBody,
    this.columnSecondBody,
    this.rowSecondBody,
    this.rowBodyRatio = 0.5,
    this.columnBodyRatio = 0.5,
    this.enableAnimations,
    this.columnBreakpoint = MyScaleBreakpoints.column,
    this.rowBreakpoint = MyScaleBreakpoints.row,
  });

  static bool isColumn() {
    return MyScaleBreakpoints.column.isConform();
  }

  static bool isRow() {
    return (false == isColumn());
  }

  /// 页面切换动画过程的时间
  static Duration routeAnimatedDuration({
    bool useColumn = false,
  }) {
    if (useColumn ||
        isColumn() ||
        false ==
            MyGlobalStoreBase.setting_s.isableAnimated(
              MyAnimatedLevel_e.Medium,
            )) {
      return const Duration(milliseconds: 400);
    } else {
      return const Duration(seconds: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isColumn = columnBreakpoint.isConform();
    return AdaptiveLayout(
      bodyRatio: (isColumn) ? columnBodyRatio : rowBodyRatio,
      internalAnimations: enableAnimations ??
          MyGlobalStoreBase.setting_s.isableAnimated(
            MyAnimatedLevel_e.Medium,
          ),
      primaryNavigation: null,
      secondaryNavigation: null,
      bottomNavigation: null,
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?>{
          columnBreakpoint: SlotLayout.from(
            key: const Key('columnBody'),
            builder: columnBody,
          ),
          rowBreakpoint: SlotLayout.from(
            key: const Key('rowBody'),
            builder: rowBody,
          ),
        },
      ),
      secondaryBody: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?>{
          columnBreakpoint: (null != columnSecondBody)
              ? SlotLayout.from(
                  key: const Key('columnSBody'),
                  builder: columnSecondBody,
                )
              : null,
          rowBreakpoint: (null != rowSecondBody)
              ? SlotLayout.from(
                  key: const Key('rowSBody'),
                  builder: rowSecondBody,
                )
              : null,
        },
      ),
    );
  }
}

class MySize_c {
  double? height;
  double? width;

  MySize_c({
    this.height = 0,
    this.width = 0,
  });
}
