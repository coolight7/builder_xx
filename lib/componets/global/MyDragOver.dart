import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ## 范围拖拽切换/触发
/// * 用于实现[child]在一个横/竖范围内的拖拽，当拖拽超过一定距离时触发对应事件，
/// 松手时会让[child]归位。
/// * 包含回弹动画
class MyDragOver extends StatefulWidget {
  static const double defBoundLimit = 200;
  static const double defExtendBound = 50;

  final void Function()? onOverTop;
  final void Function()? onOverBottom;
  final void Function()? onOverLeft;
  final void Function()? onOverRight;

  final Widget? topWidget, bottomWidget, leftWidget, rightWidget;

  final void Function(Axis axis, DragStartDetails details)? onDragStart;
  final void Function(Axis axis, bool isOver, DragUpdateDetails event)?
      onDragUpdate;
  final void Function(Axis axis, DragEndDetails details)? onDragEnd;

  final Clip clipBehavior;
  final double boundLimit, extendBound;

  final Widget child;

  const MyDragOver({
    super.key,
    this.clipBehavior = Clip.hardEdge,
    this.onOverTop,
    this.onOverBottom,
    this.onOverLeft,
    this.onOverRight,
    this.topWidget,
    this.bottomWidget,
    this.leftWidget,
    this.rightWidget,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.boundLimit = defBoundLimit,
    this.extendBound = defExtendBound,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _MyDragOverState();
}

class _MyDragOverState extends State<MyDragOver>
    with SingleTickerProviderStateMixin {
  /// * [extendBound] 用于过渡滑动和回弹效果
  /// * [extendBound] 的绝对值必须比 [upperBound] 和 [lowerBound] 小
  ///       -      ...      +
  ///  lowerBound  ...  upperBound
  ///  overLower(+extend) |                       | overUpper(+extend)
  /// ------------------------------------------------------------------>
  /// left ... right
  /// top  ... bottom
  late final upperBound = widget.boundLimit.r,
      lowerBound = -widget.boundLimit.r,
      extendBound = widget.extendBound.r;

  late final padding = extendBound / 2;
  late final AnimationController controller;

  Axis? useAxis;

  void init() {
    final enableV = enableVertical();
    final enableH = enableHorizontal();
    if (enableV && enableH) {
      useAxis = null;
    } else if (enableV) {
      useAxis = Axis.vertical;
    } else if (enableH) {
      useAxis = Axis.horizontal;
    } else {
      useAxis = null;
    }
  }

  @override
  void initState() {
    // 确保未启用的方向上的过渡滚动不会导致触发
    assert((extendBound < upperBound) && (extendBound < -lowerBound));
    super.initState();
    init();
    controller = AnimationController(
      vsync: this,
      value: 0,
      upperBound: (enableUpper() ? upperBound : 0) + extendBound,
      lowerBound: (enableLower() ? lowerBound : 0) - extendBound,
    );
  }

  @override
  void didUpdateWidget(MyDragOver oldWidget) {
    init();
    super.didUpdateWidget(oldWidget);
  }

  bool isOver() {
    return (isOverUpper() || isOverLower());
  }

  bool isOverUpper() {
    return controller.value >= upperBound;
  }

  bool isOverLower() {
    return controller.value <= lowerBound;
  }

  bool enableVertical() {
    return (null != widget.onOverTop || null != widget.onOverBottom);
  }

  bool enableHorizontal() {
    return (null != widget.onOverLeft || null != widget.onOverRight);
  }

  bool enableLower() {
    return (null != widget.onOverTop || null != widget.onOverLeft);
  }

  bool enableUpper() {
    return (null != widget.onOverBottom || null != widget.onOverRight);
  }

  void onDragUpdate(DragUpdateDetails event, double? distance) {
    if (null == distance || distance == 0) {
      return;
    }
    final isable = isOver();
    if (null != useAxis) {
      widget.onDragUpdate?.call(useAxis!, isable, event);
    }
    controller.value += distance;
    if (false == isable && isOver()) {
      // 原本不满足，现在满足，震动反馈
      HapticFeedback.heavyImpact();
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (null != useAxis) {
      widget.onDragEnd?.call(useAxis!, details);
    }
    if (isOverLower()) {
      switch (useAxis) {
        case null:
          break;
        case Axis.horizontal:
          widget.onOverLeft?.call();
        case Axis.vertical:
          widget.onOverTop?.call();
      }
    } else if (isOverUpper()) {
      switch (useAxis) {
        case null:
          break;
        case Axis.horizontal:
          widget.onOverRight?.call();
        case Axis.vertical:
          widget.onOverBottom?.call();
      }
    }
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
    );
  }

  Widget buildAxisAuto(BoxConstraints con, Widget? child) {
    final isVertical = (useAxis == Axis.vertical);
    return isVertical
        ? buildAxisVertical(con, child)
        : buildAxisHorizontal(con, child);
  }

  Widget buildAxisVertical(BoxConstraints con, Widget? child) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      clipBehavior: widget.clipBehavior,
      children: [
        if (null != widget.bottomWidget)
          Positioned(
            top: padding,
            child: Visibility(
              visible: isOverUpper(),
              child: widget.bottomWidget!,
            ),
          ),
        Positioned(
          top: controller.value,
          height: con.maxHeight,
          child: child!,
        ),
        if (null != widget.topWidget)
          Positioned(
            bottom: padding,
            child: Visibility(
              visible: isOverLower(),
              child: widget.topWidget!,
            ),
          ),
      ],
    );
  }

  Widget buildAxisHorizontal(BoxConstraints con, Widget? child) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.centerLeft,
      clipBehavior: widget.clipBehavior,
      children: [
        if (null != widget.rightWidget)
          Positioned(
            left: padding,
            child: Visibility(
              visible: isOverUpper(),
              child: widget.rightWidget!,
            ),
          ),
        Positioned(
          left: controller.value,
          width: con.maxWidth,
          child: child!,
        ),
        if (null != widget.leftWidget)
          Positioned(
            right: padding,
            child: Visibility(
              visible: isOverLower(),
              child: widget.leftWidget!,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final useVertical = enableVertical();
    final useHorizontal = enableHorizontal();
    if (false == useVertical && false == useHorizontal) {
      // 两个方向都没启用
      return widget.child;
    }
    final useV_H = useVertical && useHorizontal;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 竖直
      onVerticalDragStart: useV_H
          ? (details) {
              // 同时启用两个方向，需要在开始滑动时决定方向
              useAxis = Axis.vertical;
              widget.onDragStart?.call(Axis.vertical, details);
            }
          : null,
      onVerticalDragUpdate: useVertical
          ? (event) {
              if (Axis.vertical == useAxis) {
                onDragUpdate(
                  event,
                  event.primaryDelta,
                );
              }
            }
          : null,
      onVerticalDragEnd: useVertical
          ? (details) {
              if (Axis.vertical == useAxis) {
                onDragEnd(details);
              }
            }
          : null,
      // 水平
      onHorizontalDragStart: useV_H
          ? (details) {
              useAxis = Axis.horizontal;
              widget.onDragStart?.call(Axis.horizontal, details);
            }
          : null,
      onHorizontalDragUpdate: useHorizontal
          ? (event) {
              if (Axis.horizontal == useAxis) {
                onDragUpdate(event, event.primaryDelta);
              }
            }
          : null,
      onHorizontalDragEnd: useHorizontal
          ? (details) {
              if (Axis.horizontal == useAxis) {
                onDragEnd(details);
              }
            }
          : null,
      child: LayoutBuilder(builder: (_, con) {
        return AnimatedBuilder(
          builder: useV_H
              ? (_, child) => buildAxisAuto(con, child)
              : useVertical
                  ? (_, child) => buildAxisVertical(con, child)
                  : (_, child) => buildAxisHorizontal(con, child),
          animation: controller,
          child: widget.child,
        );
      }),
    );
  }
}
