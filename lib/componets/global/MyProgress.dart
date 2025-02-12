// ignore_for_file: file_names, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';
import 'package:builder_xx/manager/MyOverlayManager.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/componets/global/MyText.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyAnimated.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';
import '/manager/MyTheme.dart';

class MyProgressBar extends StatelessWidget {
  final double length;
  final Color? shadowColor;
  final Color? simpleColor;
  final LinearGradient? color;
  final bool? enableAnimated;
  final bool useSimpleStyle;

  const MyProgressBar({
    super.key,
    required this.length,
    this.color,
    this.simpleColor,
    this.shadowColor,
    this.enableAnimated,
    this.useSimpleStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme.progressStyle;
    return MySizedBox(
      height: 30,
      child: AnimatedFractionallySizedBox(
        heightFactor: 1,
        widthFactor: (length < 0)
            ? 0
            : (length > 1)
                ? 1
                : length,
        duration: (enableAnimated ??
                MyGlobalStoreBase.setting_s
                    .isableAnimated(MyAnimatedLevel_e.Low)
            ? const Duration(milliseconds: 300)
            : Duration.zero),
        curve: Curves.easeOutCubic,
        child: DecoratedBox(
          decoration: useSimpleStyle
              ? BoxDecoration(
                  color: simpleColor ??
                      (MyGlobalStoreBase.theme_s.isLight()
                          ? const Color.fromRGBO(255, 255, 255, 1)
                          : const Color.fromRGBO(200, 200, 200, 0.2)),
                  borderRadius: const MyBorderRadius(MyRadius(125)),
                )
              : BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor ??
                          theme.progressShadowColor ??
                          const Color.fromRGBO(255, 255, 255, 0.7),
                      offset: const MyOffset(3, 3),
                      blurRadius: 25.r,
                      spreadRadius: 5.r,
                    ),
                    BoxShadow(
                      color: shadowColor ??
                          theme.progressShadowColor ??
                          const Color.fromRGBO(255, 255, 255, 0.7),
                      offset: const MyOffset(-3, -3),
                      blurRadius: 25.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                  borderRadius: const MyBorderRadius(MyRadius(125)),
                  gradient: color ??
                      theme.progressColor ??
                      const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          MyColors_e.write,
                          MyColors_e.write,
                        ],
                      ),
                ),
        ),
      ),
    );
  }
}

class MyProgressBase extends StatefulWidget {
  final MyDirection_e direction;
  // 进度条点击事件，参数：点击位置百分比
  final void Function(
    double widthPercent,
    double heightPercent,
    bool isMove,
  )?
      // 点击、拖动进度条时触发的函数
      // * 拖动时触发会有 200 ms延迟
      onTap,
      // 等同 [onTap]，但拖动时触发不会有延迟
      onTapFast;
  final void Function()? onTapDown, onTapUp;
  final List<Widget> children;
  final bool enableOnChangeView;
  final Color? simpleColor;

  /// 构建点击、拖动时显示的进度字符串
  /// * [null]：默认；不传递则不会在拖动时显示进度
  final String Function(
    double widthPercent,
    double heightPercent,
  )? buildOnChangeViewStr;

  /// 构建点击、拖动时显示的进度位置
  final Offset Function(
    double pointX,
    double pointY,
    double progressX,
    double progressY,
  )? buildOnChangeViewPosition;
  final Widget Function(
    double move_widthPercent,
    double move_heightPercent,
    double pointX,
    double pointY,
    double progressX,
    double progressY,
    double progressWidth,
    double progressHeight,
  )? buildOnChangeViewWidget;
  final bool useSimpleStyle;

  const MyProgressBase({
    super.key,
    this.onTap,
    this.onTapFast,
    this.onTapDown,
    this.onTapUp,
    this.children = const <Widget>[],
    this.direction = MyDirection_e.LeftToRight,
    this.enableOnChangeView = false,
    this.buildOnChangeViewWidget,
    this.buildOnChangeViewStr,
    this.buildOnChangeViewPosition,
    this.simpleColor,
    this.useSimpleStyle = false,
  });

  @override
  _MyProgressState createState() => _MyProgressState();
}

class _MyProgressState extends State<MyProgressBase> {
  GlobalKey<State<StatefulWidget>>? progressKey;
  double pointX = -1,
      pointY = -1,
      progressX = -1,
      progressY = -1,
      progressWidth = -1,
      progressHeight = -1;
  double move_widthPercent = -1, move_heightPercent = -1;
  late final MyRxObj_c<bool> isShowPosition;
  late final OverlayEntry overlayEntity;
  late final moveThrottle = EventxxThrottle_c<MapEntry<double, double>>(
    time: const Duration(milliseconds: 300),
    onListen: (entity) {
      widget.onTap?.call(entity.key, entity.value, true);
    },
  );

  @override
  void initState() {
    super.initState();
    progressKey = (null != widget.onTap) ? GlobalKey() : null;
    if (widget.enableOnChangeView) {
      isShowPosition = MyRxObj_c(false);
      overlayEntity = OverlayEntry(builder: (_) {
        return Obx(() {
          if (isShowPosition.value) {
            if (null != widget.buildOnChangeViewWidget) {
              return widget.buildOnChangeViewWidget!(
                move_widthPercent,
                move_heightPercent,
                pointX,
                pointY,
                progressX,
                progressY,
                progressWidth,
                progressHeight,
              );
            }
            final position = widget.buildOnChangeViewPosition?.call(
              pointX,
              pointY,
              progressX,
              progressY,
            );
            double? top = position?.dy;
            if (null == top) {
              top = (progressY - 90.r);
              if (top < 10) {
                top = (progressY + 200.r);
              }
            }
            return Positioned(
              left: position?.dx ?? pointX,
              top: top,
              child: IgnorePointer(
                child: Container(
                  padding: const MyEdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: MyColors_e.blue_tianyi,
                    borderRadius: MyBorderRadius.circularRInt(15),
                  ),
                  child: MyTextMain(
                    widget.buildOnChangeViewStr?.call(
                          move_widthPercent,
                          move_heightPercent,
                        ) ??
                        "",
                    style: const MyTextMainStyle(
                      rFontSize: 42,
                      color: MyColors_e.write,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
      });
      Timer(const Duration(milliseconds: 100), () {
        MyOverlayManager.insert(overlayEntity);
      });
    }
  }

  @override
  void dispose() {
    progressKey = null;
    if (widget.enableOnChangeView) {
      try {
        overlayEntity.remove();
      } catch (_) {}
    }
    super.dispose();
  }

  MapEntry<double, double> onCalc(double pointx, double pointy) {
    final randerBox = progressKey?.currentContext?.findRenderObject();
    if (null != randerBox) {
      final rander = randerBox as RenderBox;
      final translation = rander.getTransformTo(null).getTranslation();
      // 进度条位置
      progressX = translation.x;
      progressY = translation.y;
      // 进度条宽高
      progressWidth = rander.size.width;
      progressHeight = rander.size.height;
      // 点击坐标
      pointX = pointx;
      pointY = pointy;
      double reKey = 0, reVal = 0;
      switch (widget.direction) {
        case MyDirection_e.LeftToRight:
          reKey = (pointX - progressX) / progressWidth;
          reVal = (pointY - progressY) / progressHeight;
          break;
        case MyDirection_e.RightToLeft:
          reKey = (pointX - progressX) / progressWidth;
          reVal = (pointY - progressY) / progressHeight;
          break;
        case MyDirection_e.TopToBottom:
          reKey = (pointX - progressX) / progressHeight;
          reVal = (pointY - progressY) / progressWidth;
          break;
        case MyDirection_e.BottomToTop:
          reKey = (pointX - progressX) / progressHeight;
          reVal = (progressY - pointY) / progressWidth;
          break;
      }
      if (reKey < 0) {
        reKey = 0;
      } else if (reKey > 1) {
        reKey = 1;
      }
      if (reVal < 0) {
        reVal = 0;
      } else if (reVal > 1) {
        reVal = 1;
      }
      return MapEntry<double, double>(reKey, reVal);
    }
    return const MapEntry<double, double>(0, 0);
  }

  void onTapDo(double pointx, double pointy) {
    final pair = onCalc(pointx, pointy);
    widget.onTapFast?.call(pair.key, pair.value, false);
    widget.onTap?.call(pair.key, pair.value, false);
  }

  void onMoveDo(double pointx, double pointy) {
    final pair = onCalc(pointx, pointy);
    if (move_widthPercent == pair.key && move_heightPercent == pair.value) {
      // 如果和之前的值相同就不再触发
      return;
    }
    move_widthPercent = pair.key;
    move_heightPercent = pair.value;
    flushPositionView(
      pointx,
      pointy,
    );
    widget.onTapFast?.call(move_widthPercent, move_heightPercent, true);
    moveThrottle.notify(pair);
  }

  void flushPositionView(double x, double y) {
    if (widget.enableOnChangeView) {
      pointX = x;
      pointY = y;
      if (false == isShowPosition.value) {
        isShowPosition.value = true;
      } else {
        isShowPosition.update((value) {});
      }
    }
  }

  void showPositionView(double x, double y) {
    if (widget.enableOnChangeView) {
      final pair = onCalc(x, y);
      move_widthPercent = pair.key;
      move_heightPercent = pair.value;
      flushPositionView(x, y);
    }
  }

  void hidePositionView() {
    if (widget.enableOnChangeView) {
      isShowPosition.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Widget reWidget;
    if (widget.useSimpleStyle) {
      reWidget = MySizedBox(
        height: 70,
        width: double.infinity,
        child: Center(
          child: Container(
            key: progressKey,
            height: 30.r,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.simpleColor ??
                  (MyGlobalStoreBase.theme_s.isLight()
                      ? const Color.fromRGBO(150, 150, 150, 0.3)
                      : const Color.fromRGBO(180, 180, 180, 0.15)),
              borderRadius: const MyBorderRadius(MyRadius(125)),
            ),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: widget.children,
            ),
          ),
        ),
      );
    } else {
      final theme = MyGlobalStoreBase.theme_s.mytheme.progressStyle;
      reWidget = Container(
        key: progressKey,
        height: 70.r,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: theme.progressBaseDecoration.call(),
        foregroundDecoration: theme.progressBaseforegroundDecoration?.call(),
        child: Padding(
          padding: const MyEdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 30,
            right: 30,
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: widget.children,
          ),
        ),
      );
    }

    if (null != widget.onTap) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          showPositionView(event.position.dx, event.position.dy);
        },
        onHover: (event) {
          showPositionView(
            event.position.dx,
            event.position.dy,
          );
        },
        onExit: (event) {
          hidePositionView();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            onTapDo(details.globalPosition.dx, details.globalPosition.dy);
            widget.onTapDown?.call();
          },
          onTapUp: (details) {
            widget.onTapUp?.call();
            switch (details.kind) {
              case PointerDeviceKind.touch:
                // 如果是触摸，则抬起时隐藏
                hidePositionView();
              default:
                break;
            }
          },
          // 滑动
          onHorizontalDragStart: (details) {
            onMoveDo(details.globalPosition.dx, details.globalPosition.dy);
          },
          onHorizontalDragUpdate: (details) {
            onMoveDo(details.globalPosition.dx, details.globalPosition.dy);
          },
          onHorizontalDragCancel: () {
            if (Platformxx_c.isAndroid) {
              hidePositionView();
            }
          },
          onHorizontalDragEnd: (details) {
            if (Platformxx_c.isAndroid) {
              hidePositionView();
            }
          },
          child: reWidget,
        ),
      );
    } else {
      return reWidget;
    }
  }
}
