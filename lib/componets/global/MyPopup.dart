// ignore_for_file: file_names, non_constant_identifier_names, camel_case_types

import 'dart:async';
import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:builder_xx/componets/global/MyContentBlock.dart';
import 'package:builder_xx/componets/global/MyMarkdown.dart';
import 'package:builder_xx/manager/MyRxCtrlManager.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:builder_xx/componets/global/MyAnimated.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/componets/global/MySvg.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MyAdaptiveLayout.dart';
import 'MyTextLine.dart';
import 'MyList.dart';
import 'MySimpleList.dart';
import 'MyBtn.dart';
import 'MyText.dart';
import '/manager/MyRoute.dart';
import '/manager/MyTheme.dart';

// 提示框
class MyPopup {
  static void setStyle() {
    EasyLoading.instance.radius = 30.r;
    EasyLoading.instance.backgroundColor = MyColors_e.transparent;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.squareCircle;
    EasyLoading.instance.loadingStyle =
        MyGlobalStoreBase.theme_s.mytheme.toastStyle;
    EasyLoading.instance.boxShadow = MyGlobalStoreBase.theme_s.isLight()
        ? const [
            MyBoxShadow(
              color: Color.fromRGBO(200, 200, 200, 1),
              blurRadius: 40,
            ),
          ]
        : const [
            BoxShadow(
              color: MyColors_e.black,
              blurRadius: 20,
            ),
          ];
    EasyLoading.instance.toastPosition = EasyLoadingToastPosition.top;
    EasyLoading.instance.animationStyle = EasyLoadingAnimationStyle.offset;
    EasyLoading.instance.animationDuration = const Duration(milliseconds: 300);
    EasyLoading.instance.textStyle = const MyTextMainStyle(
      rFontSize: 45,
      fontWeight: MyTextCross.defFontWeight,
    );
  }

  // 初始化样式
  static TransitionBuilder init() {
    return EasyLoading.init();
  }

  static void showEasyToast(String in_text) {
    if (in_text.isEmpty) {
      return;
    }
    EasyLoading.showToast(
      in_text,
      toastPosition: EasyLoadingToastPosition.top,
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示加载提示
  static Future<void> showEasyLoading(
    String? info, {
    Widget? action,
    bool? dismissOnTap,
  }) {
    final theme_s = MyGlobalStoreBase.theme_s;
    return EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: (null != action)
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      theme_s.isLight() ? MyColors_e.write : MyColors_e.black,
                  borderRadius: MyBorderRadius.circularRInt(30),
                ),
                margin: const MyEdgeInsets.all(50),
                padding: const MyEdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MySettingContentBlock(
                      height: 250.r,
                      width: 250.r,
                      backgroundColor: MyColors_e.blue_tianyi,
                      borderRadius: const MyBorderRadius(MyRadius(30)),
                      child: Center(
                        child: LoadingAnimationWidget.threeRotatingDots(
                          color: MyColors_e.write,
                          size: 200.r,
                        ),
                      ),
                    ),
                    if (null != info)
                      Padding(
                        padding: const MyEdgeInsets.only(top: 30),
                        child: MyTextMain.thin(info),
                      ),
                    action,
                  ],
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    height: 180.r,
                    width: theme_s.windowWidth * 0.9,
                    decoration: BoxDecoration(
                      color: theme_s.isLight()
                          ? MyColors_e.write
                          : MyColors_e.black,
                      borderRadius: MyBorderRadius.circularRInt(70),
                    ),
                    margin: const MyEdgeInsets.only(top: 50, bottom: 50),
                    padding: const MyEdgeInsets.only(left: 50, right: 50),
                    child: Row(
                      children: [
                        LoadingAnimationWidget.threeRotatingDots(
                          color: theme_s.mytheme.textMainColor,
                          size: 100.r,
                        ),
                        Padding(
                          padding: const MyEdgeInsets.only(left: 50),
                          child: MyTextMain(info ?? "加载中..."),
                        )
                      ],
                    )),
              ],
            ),
      dismissOnTap: dismissOnTap,
    );
  }

  static Future<T?> showEasyLoadingFuture<T>({
    String title = "正在加载...",
    Future<T?> Function(MyRxObj_c<bool>? isCancel)? futureFunc,
    Future<T?>? future,
    Widget? appendInfo,
    void Function()? onCancelTap,
  }) async {
    final isCancel = MyRxObj_c(false);
    final children = [
      if (null != appendInfo) appendInfo,
      if (null != onCancelTap)
        MyBtn(
          key: ValueKey(isCancel.value),
          isLoading: isCancel,
          isInContentBlock: true,
          selected: false,
          text: " 中止 ",
          onTap: () {
            isCancel.value = true;
            onCancelTap.call();
          },
        )
    ];
    showEasyLoading(
      title,
      action: (children.isNotEmpty)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : null,
    );
    Future<T?>? reData;
    if (null != futureFunc) {
      reData = futureFunc.call(isCancel);
    } else {
      reData = future;
    }
    await Future.wait([
      if (null != reData) reData,
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    closeEasy();
    return reData;
  }

  static Future<void> showEasyError(
    String status, {
    Duration? duration,
    bool? dismissOnTap,
  }) {
    return EasyLoading.showError(
      status,
      duration: duration,
      dismissOnTap: dismissOnTap,
    );
  }

  static Future<void> showEasySuccess(
    String status, {
    Duration? duration,
    bool? dismissOnTap,
  }) {
    return EasyLoading.showSuccess(
      status,
      duration: duration,
      dismissOnTap: dismissOnTap,
    );
  }

  static Future<void> showEasyInfo(
    String status, {
    Duration? duration,
    bool? dismissOnTap,
  }) {
    return EasyLoading.showInfo(
      status,
      duration: duration,
      dismissOnTap: dismissOnTap,
    );
  }

  /// 隐藏 [SWinToast] 和 [WinLoading] , [WinError],  [WinInfo], [WinSuccess]
  static Future<void> closeEasy({
    bool animation = true,
    Duration? closeDelay,
  }) async {
    if (null != closeDelay) {
      await Future.delayed(closeDelay);
    }
    return EasyLoading.dismiss(animation: animation);
  }

  static SnackbarController showSnackBar(
    String title,
    String msg, {
    void Function(GetSnackBar)? onTap,
    Widget? icon,
    MyBtn? button,
    Duration? duration = const Duration(seconds: 3),
  }) {
    return Get.snackbar(
      "",
      "",
      titleText: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 120.r,
        ),
        child: Row(
          children: [
            if (null != icon) icon,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextMain(
                    title,
                    style: const MyTextMainStyle(
                      fontWeight: MyTextCross.defFontWeight,
                    ),
                  ),
                  if (msg.isNotEmpty)
                    Padding(
                      padding: const MyEdgeInsets.only(top: 10),
                      child: MyTextMain(
                        msg,
                        style: const MyTextMainStyle(
                          rFontSize: MyTextCross.defRFontSize,
                          fontWeight: MyTextCross.defFontWeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (null != button) button,
          ],
        ),
      ),
      messageText: const SizedBox(),
      padding: const MyEdgeInsets.only(
        top: 30,
        left: 30,
        right: 30,
        bottom: 15,
      ),
      margin: const MyEdgeInsets.all(50),
      onTap: onTap,
      duration: duration,
    );
  }

  /// 返回是否点击了按钮
  static Future<bool> showSnackBarConfirm({
    required String title,
    String? depict,
    Duration duration = const Duration(seconds: 5),
    String btnName = "取消",
  }) async {
    bool rebool = false;
    SnackbarController? ctrl;
    ctrl = MyPopup.showSnackBar(
      title,
      depict ?? "",
      duration: duration,
      button: MyBtn.simple(
        text: btnName,
        onTap: () {
          if (false == rebool) {
            rebool = true;
            ctrl?.close();
          }
        },
      ),
    );
    await ctrl.future;
    return rebool;
  }

  static MySize_c bottomSheetAutoSize(double maxHeight) {
    return MySize_c(
      height: (maxHeight < 1200.r) ? (maxHeight * 0.9) : (maxHeight * 0.7),
      width: MyGlobalStoreBase.theme_s.windowWidth * 0.9,
    );
  }

  static MySize_c bottomSheetMaxSize(double maxHeight) {
    return MySize_c(
      height: maxHeight * 0.9,
      width: MyGlobalStoreBase.theme_s.windowWidth * 0.9,
    );
  }

  static Widget buildAlertContentBlock(Widget child) {
    return MySettingContentBlock.inContent(
      width: max(
        MyGlobalStoreBase.theme_s.windowWidth * 0.5,
        800.r,
      ),
      child: child,
    );
  }

  /* 确认信息对话框
    * [textConfirm]: 确定按钮文字，默认null，将使用默认文字
    * 当 [textConfirm] = null && [onConfirm] = null 时，将移除该按钮
  */
  static Future<T?> showAlert<T>(
    String title, {
    Widget? content,
    String contentStr = "",
    String? textConfirm = "",
    String? textCancel = "",
    bool enableDismissible = true,
    T Function()? onConfirm,
    Future<T> Function()? onConfirmAsync,
    T Function()? onCancel,
    Future<T> Function()? onCancleAsync,
  }) async {
    final context = Get.overlayContext;
    if (null == context) {
      return null;
    }
    if (null != textConfirm && textConfirm.isEmpty) {
      textConfirm = " 确定 ";
    }
    final showBtnRight =
        (null != textConfirm && (null != onConfirm || null != onConfirmAsync));
    if (null != textCancel && textCancel.isEmpty) {
      // 替换默认文字
      if (showBtnRight) {
        // 有确定按钮
        textCancel = " 取消 ";
      } else {
        // 无确定按钮
        textCancel = " 关闭 ";
      }
    }
    final showBtnCancel = (null != textCancel);
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    T? reData;
    final btnlist = [
      if (showBtnCancel)
        (null != onCancleAsync)
            ? MyBtn.loading(
                size: MyBtn.defFullSize,
                text: textCancel,
                isInContentBlock: true,
                onAsyncTap: () async {
                  reData = await onCancleAsync.call();
                },
              )
            : MyBtn(
                size: MyBtn.defFullSize,
                text: textCancel,
                isInContentBlock: true,
                onTap: (null != onCancel)
                    ? () {
                        reData = onCancel.call();
                      }
                    : MyRoute_c.back,
              ),
      if (showBtnRight && showBtnCancel) const MySizedBox(width: 50),
      if (showBtnRight)
        (null != onConfirmAsync)
            ? MyBtn.loading(
                size: MyBtn.defFullSize,
                text: textConfirm,
                selected: true,
                isInContentBlock: true,
                onAsyncTap: () async {
                  reData = await onConfirmAsync.call();
                },
              )
            : MyBtn(
                size: MyBtn.defFullSize,
                text: textConfirm,
                selected: true,
                isInContentBlock: true,
                onTap: (null != onConfirm)
                    ? () {
                        reData = onConfirm.call();
                      }
                    : () {
                        MyRoute_c.back();
                      },
              )
    ];
    final isColumn = MyAdaptiveLayout.isColumn();
    final maxWidth = MyGlobalStoreBase.theme_s.windowWidth;
    final limitHeight = MyGlobalStoreBase.theme_s.windowHeight * 0.9;
    // 取 [limitHeight - 500.r] 和 400.r 中的大值
    // 防止 limitHeight 太小导致不够减
    final maxContentHeight = min(
      max(limitHeight - 500.r, 400.r),
      limitHeight,
    );
    final manager = MyRxCtrlManager_c.to;
    int? pageId;
    if (manager.autoHandlePageEvent) {
      pageId = manager.pageInto();
    }
    try {
      await showMaterialModalBottomSheet(
        duration:
            MyGlobalStoreBase.setting_s.switchValueAnimatedLevel<Duration?>(
          MyAnimatedLevel_e.Low,
          enableValue: const Duration(milliseconds: 500),
          disableValue: Duration.zero,
        ),
        animationCurve: Curves.easeOutCirc,
        barrierColor: theme.dialogBarrierColor,
        backgroundColor: MyColors_e.transparent,
        context: context,
        enableDrag: enableDismissible,
        isDismissible: false,
        bounce: true,
        expand: true,
        builder: (context) => BackButtonListener(
          onBackButtonPressed: () async {
            if (enableDismissible) {
              // 如果已经是根目录，则回退路由
              MyRoute_c.back();
            }
            return true;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (enableDismissible) {
                MyRoute_c.back();
              }
            },
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {},
                    child: Container(
                      width: isColumn ? double.infinity : null,
                      margin: isColumn
                          ? const MyEdgeInsets.only(
                              left: 50,
                              right: 50,
                              bottom: 50,
                            )
                          : const MyEdgeInsets.only(bottom: 50),
                      padding: const MyEdgeInsets.only(
                        left: 50,
                        right: 50,
                      ),
                      decoration: BoxDecoration(
                        color: theme.contentDecoration.contentBlockSettingColor,
                        borderRadius: const MyBorderRadius(MyRadius(70)),
                      ),
                      constraints: isColumn
                          ? BoxConstraints(maxHeight: limitHeight)
                          : BoxConstraints(
                              minWidth: maxWidth * 0.6,
                              maxWidth: maxWidth * 0.9,
                              maxHeight: limitHeight,
                            ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const MyEdgeInsets.all(50),
                            child: MyTextInnerLine(
                              title,
                              appendLineRWidth: 20,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: min(160.r, maxContentHeight),
                              maxHeight: maxContentHeight,
                            ),
                            child: content ??
                                SingleChildScrollView(
                                  physics: MyListBase.allBouncingScrollPhysics,
                                  child: MyTextCross.multiLine(
                                    contentStr,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                          ),
                          MySizedBox(
                            height: 250,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: btnlist,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (manager.autoHandlePageEvent) {
      manager.pageBack(pageId);
    }
    return reData;
  }

  static Future<void> showBottomSheetBase({
    required Widget Function(BuildContext) childBuilder,
    MySize_c? Function(double maxHeight)? sizeBuilder,
    Color? backgroundColor,
    bool enableDismissible = true, // 允许用户点击背景/拖动等方式关闭关闭
  }) async {
    final context = Get.overlayContext;
    if (null == context) {
      return;
    }
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final maxHeight = MyGlobalStoreBase.theme_s.windowHeight;
    final isColumn = MyAdaptiveLayout.isColumn();
    final size = sizeBuilder?.call(maxHeight) ?? bottomSheetAutoSize(maxHeight);
    final manager = MyRxCtrlManager_c.to;
    int? pageId;
    if (manager.autoHandlePageEvent) {
      pageId = manager.pageInto();
    }
    try {
      // TODO: height 使用max后会被裁剪
      await showMaterialModalBottomSheet(
        duration:
            MyGlobalStoreBase.setting_s.switchValueAnimatedLevel<Duration?>(
          MyAnimatedLevel_e.Low,
          enableValue: const Duration(milliseconds: 500),
          disableValue: Duration.zero,
        ),
        animationCurve: Curves.easeOutQuart,
        barrierColor: theme.dialogBarrierColor,
        backgroundColor: MyColors_e.transparent,
        context: context,
        enableDrag: enableDismissible,
        isDismissible: false,
        bounce: true,
        expand: true,
        builder: (context) => BackButtonListener(
          onBackButtonPressed: () async {
            if (enableDismissible) {
              // 如果已经是根目录，则回退路由
              MyRoute_c.back();
            }
            return true;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (enableDismissible) {
                MyRoute_c.back();
              }
            },
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: isColumn
                        ? SafeArea(
                            // 让底部有弹窗背景色
                            bottom: false,
                            child: Container(
                              height: size.height,
                              width: double.infinity,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: backgroundColor ??
                                    theme.dialogBackgroundColor,
                                // 修复 linux 渲染异常
                                borderRadius: Platformxx_c.isLinux
                                    ? MyBorderRadius.circularRInt(70)
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(70.r),
                                        topRight: Radius.circular(70.r),
                                      ),
                              ),
                              child: SafeArea(
                                child: childBuilder.call(context),
                              ),
                            ),
                          )
                        : SafeArea(
                            child: Container(
                              height: size.height,
                              width: size.width,
                              clipBehavior: Clip.hardEdge,
                              margin: const MyEdgeInsets.only(bottom: 50),
                              decoration: BoxDecoration(
                                color: backgroundColor ??
                                    theme.dialogBackgroundColor,
                                borderRadius:
                                    const MyBorderRadius(MyRadius(70)),
                              ),
                              child: childBuilder.call(context),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (manager.autoHandlePageEvent) {
      manager.pageBack(pageId);
    }
  }

  static Future<void> showBottomSheet({
    required String title,
    String? depict,
    required Widget Function() contentBuilder,
    MySize_c? Function(double maxHeight)? sizeBuilder,
    Color? backgroundColor,
    bool enableDismissible = true, // 允许用户点击背景/拖动等方式关闭关闭
    bool enableCloseByNotBtn = true, // 允许按钮以外的方式关闭, 启用 [enableDismissible] 才有效
    String textConfirm = "确定",
    void Function()? onConfirm,
    Future<void> Function()? onConfirmAsync,
  }) async {
    return showBottomSheetBase(
      backgroundColor: backgroundColor,
      enableDismissible: enableDismissible && enableCloseByNotBtn,
      sizeBuilder: sizeBuilder,
      childBuilder: (context) {
        final theme = MyGlobalStoreBase.theme_s.mytheme;
        return Column(
          children: [
            Padding(
              padding: const MyEdgeInsets.only(
                top: 50,
                bottom: 30,
                left: 50,
                right: 50,
              ),
              child: Row(
                children: [
                  if (enableDismissible)
                    MySizedBox(
                      width: MyBtn.defRelativeSimpleSize.toDouble(),
                    ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const MyEdgeInsets.only(left: 20, right: 20),
                        child: MyTextInnerLine(
                          title,
                          appendLineRWidth: 20,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  if (enableDismissible)
                    Container(
                      height: MyBtn.defSimpleSize,
                      width: MyBtn.defSimpleSize,
                      decoration: BoxDecoration(
                        color: theme.contentDecoration.svgBackgroundColor ??
                            theme.backgroundColorCross,
                        borderRadius: const MyBorderRadius(MyRadius(
                          MyBtn.defRelativeSimpleSize ~/ 4,
                        )),
                      ),
                      child: Center(
                        child: MyBtn.simple(
                          size: MyBtn.defSimpleSize,
                          svgName: MySvgNames_e.cancel,
                          onTap: MyRoute_c.back,
                        ),
                      ),
                    )
                ],
              ),
            ),
            if (true == depict?.isNotEmpty)
              Padding(
                padding: const MyEdgeInsets.only(
                  left: 50,
                  right: 50,
                  bottom: 30,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: MyTextCross.multiLine(
                      depict!,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            Expanded(child: contentBuilder()),
            if (null != onConfirmAsync || null != onConfirm)
              (null != onConfirmAsync)
                  ? MyFullBtn.loading(
                      margin: MyFullBtn.defPopupBtnMargin,
                      text: textConfirm,
                      onAsyncTap: onConfirmAsync,
                    )
                  : MyFullBtn(
                      margin: MyFullBtn.defPopupBtnMargin,
                      text: textConfirm,
                      onTap: onConfirm ?? MyRoute_c.back,
                    ),
            const MySizedBox(height: 20),
          ],
        );
      },
    );
  }

  /// 底部选择弹窗
  /// * [data] 和 [controller] 必须传入其中一个
  /// * [data] 列表数据
  /// * [controller] 列表控制器
  ///   * 当传入控制器时， [data] 将被忽略
  /// * [sizeBuilder] 指定弹窗的大小
  ///   * 默认将取决于可用区域大小:
  ///   * 若可用高度大于 [800.r] 则使用一半的可用高度
  ///   * 否则占满可用高度
  /// * [enableDismissible] 允许用户点击背景/拖动等方式关闭关闭
  static Future<void> showSelect({
    required String title,
    String? depict,
    Widget? header,
    List<MySettingListItemData_c>? data,
    MySimpleListController<MySettingListItemData_c>? controller,
    MySize_c? Function(double maxHeight)? sizeBuilder,
    bool enableDismissible = true,
    bool enableCopy = false,
    bool Function(MySettingListItemData_c, int)? isSelect,
  }) async {
    assert(null != data || null != controller);
    if (true == depict?.isEmpty) {
      depict = null;
    }
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final useCtrl =
        controller ??= MySimpleListController<MySettingListItemData_c>(
      data!,
    );
    await showBottomSheetBase(
      enableDismissible: enableDismissible,
      sizeBuilder: sizeBuilder,
      backgroundColor: theme.contentDecoration.contentBlockSettingColor,
      childBuilder: (context) => Padding(
        padding: const MyEdgeInsets.all(50),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const MyEdgeInsets.only(left: 20, right: 20),
                    child: MyTextInnerLine(
                      title,
                      appendLineRWidth: 20,
                    ),
                  ),
                ),
                if (enableDismissible)
                  Container(
                    height: MyBtn.defSimpleSize,
                    width: MyBtn.defSimpleSize,
                    margin: const MyEdgeInsets.only(left: 30),
                    decoration: BoxDecoration(
                      color:
                          theme.contentDecoration.svgInContentBackgroundColor ??
                              theme.backgroundColor,
                      borderRadius: const MyBorderRadius(
                        MyRadius(
                          MyBtn.defRelativeSimpleSize ~/ 4,
                        ),
                      ),
                    ),
                    child: Center(
                      child: MyBtn.simple(
                        size: MyBtn.defSimpleSize,
                        svgName: MySvgNames_e.cancel,
                        onTap: () {
                          MyRoute_c.back();
                        },
                      ),
                    ),
                  )
              ],
            ),
            if (null != depict)
              Padding(
                padding: const MyEdgeInsets.only(top: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: MyTextCross.multiLine(
                    depict,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            if (null != header) header,
            const MySizedBox(height: 30),
            Expanded(
              child: MySettingList(
                useCtrl,
                isSelect: isSelect,
                inContent: true,
                padding: EdgeInsets.zero,
                onItemLongPress: enableCopy
                    ? (ctrl, item, index) {
                        MyPopup.showEasyToast("已复制");
                        Clipboard.setData(ClipboardData(
                          text: "${item.infoMain}:${item.infoCross ?? ''}",
                        ));
                      }
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  static Future<T?> showSelectSimple<T>({
    required String title,
    required String Function(T item) toInfoMain,
    required List<T> data,
    String? depict,
    T? selectValue,
    T? defaultValue,
    bool selectAll = false,
    Widget? action,
    bool enableDismissible = true,
    String? Function(T item)? toInfoCross,
    MySize_c? Function(double maxHeight)? sizeBuilder,
    Future<bool> Function(T item)? onTap,
  }) async {
    T? selectItem;
    final todata = <MySettingListItemData_c>[];
    for (int i = 0; i < data.length; ++i) {
      final item = data[i];
      final isSelect = (selectAll || selectValue == item);
      final isDefault = (defaultValue == item);
      todata.add(MySettingListItemData_c(
        infoMain:
            isDefault ? "${toInfoMain.call(item)}（默认）" : toInfoMain.call(item),
        infoCross: toInfoCross?.call(item),
        action: isSelect ? action : null,
        onTap: (p0, p1, p2) async {
          if ((await onTap?.call(item)) == false) {
            return;
          }
          selectItem = item;
          MyRoute_c.back();
        },
      ));
    }
    await showSelect(
      title: title,
      data: todata,
      depict: depict,
      sizeBuilder: sizeBuilder,
      enableDismissible: enableDismissible,
      isSelect: selectAll
          ? null
          : (item, index) {
              return selectValue == data[index];
            },
    );
    return selectItem;
  }

  static Future<void> showSelectColor({
    required String title,
    required void Function(Color) onColorChanged,
    Color color = MyColors_e.blue_tianyi,
    List<Color> recentColors = const <Color>[MyColors_e.blue_tianyi],
  }) {
    final selectColor = MyRxObj_c(color);
    return MyPopup.showBottomSheet(
      title: title,
      sizeBuilder: MyPopup.bottomSheetMaxSize,
      contentBuilder: () {
        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Obx(() => ColorPicker(
                  width: 200.r,
                  height: 200.r,
                  borderRadius: 50.r,
                  color: selectColor.value,
                  showColorCode: true,
                  enableOpacity: true,
                  wheelSquareBorderRadius: 100.r,
                  enableTooltips: false,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.primary: true,
                    ColorPickerType.wheel: true,
                    ColorPickerType.custom: false,
                    ColorPickerType.both: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.bw: false,
                  },
                  pickerTypeLabels: const <ColorPickerType, String>{
                    ColorPickerType.primary: "推荐",
                    ColorPickerType.wheel: "自定义选色盘"
                  },
                  pickerTypeTextStyle: const MyTextMainStyle(rFontSize: 45),
                  colorCodeTextStyle: const MyTextCrossStyle(rFontSize: 40),
                  recentColors: recentColors,
                  showRecentColors: true,
                  onColorChanged: (color) {
                    selectColor.value = color;
                    onColorChanged(color);
                  },
                ))
          ],
        );
      },
    );
  }

  static Future<void> showListInfo({
    required String title,
    List<MySettingListItemData_c>? data,
    bool checkDataInfoCross = true,
    Future<List<MySettingListItemData_c>> Function()? load,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    assert(null != data || null != load);
    final controller = MySimpleListController<MySettingListItemData_c>(
      data ?? [],
      isAllShimmer: (null != load),
    );
    if (null != load) {
      Timer(delay, () async {
        final redatalist = await load.call();
        if (checkDataInfoCross) {
          for (int i = 0; i < redatalist.length; ++i) {
            final item = redatalist[i];
            item.infoCross ??= "『未知』";
          }
        }
        controller.update_list(
          redatalist,
          doUpdate: false,
        );
        controller.setIsAllShimmer(false);
      });
    }
    return MyPopup.showSelect(
      title: title,
      controller: controller,
      enableCopy: true,
    );
  }

  static Future<void> showLaunchUrl(
    String name,
    Uri url, {
    String? content,
  }) {
    return MyPopup.showAlert(
      "即将跳转浏览器访问",
      contentStr: """•『$name』
• ${content ?? url.toString()}""",
      onConfirm: () {
        // 调用浏览器访问
        launchUrl(
          url,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        MyRoute_c.back();
      },
    );
  }

  static Future<void> showBottomSheetMarkdown({
    required String title,
    required String markdown,
  }) {
    return MyPopup.showBottomSheet(
      title: title,
      contentBuilder: () => MyMarkdown(data: markdown),
    );
  }
}
