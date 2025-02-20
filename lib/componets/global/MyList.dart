// ignore_for_file: prefer_conditional_assignment, non_constant_identifier_names, file_names, constant_identifier_names, camel_case_types,

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:builder_xx/componets/global/MyAdaptiveLayout.dart';
import 'package:builder_xx/componets/global/MyContentBlock.dart';
import 'package:builder_xx/manager/MyRxCtrlManager.dart';
import 'package:builder_xx/manager/MyRoute.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:util_xx/util_xx.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:refreshed/refreshed.dart';
import 'MyScreenUtil.dart';
import 'MyScrollView.dart';
import 'MyAnimated.dart';
import 'MyLoadingShimmer.dart';
import 'MySimpleList.dart';
import 'MyText.dart';
import 'MyBtn.dart';
import 'MyReorderableList.dart';
import 'MySvg.dart';
import 'MyPopup.dart';
import 'MyMask.dart';
import '/manager/MyTheme.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';

/// 布局方式
enum MyListLayoutType_e {
  /// 自动
  Auto,

  /// 单列列表
  ListBox,

  /// 网格
  GridBox,

  /// 多列列表
  MultiListBox,
}

class MyListLayoutType_c {
  static int toInt(MyListLayoutType_e type) {
    switch (type) {
      case MyListLayoutType_e.Auto:
        return 1;
      case MyListLayoutType_e.ListBox:
        return 10;
      case MyListLayoutType_e.GridBox:
        return 20;
      case MyListLayoutType_e.MultiListBox:
        return 30;
    }
  }

  static MyListLayoutType_e? toEnum(int type) {
    switch (type) {
      case 1:
        return MyListLayoutType_e.Auto;
      case 10:
        return MyListLayoutType_e.ListBox;
      case 20:
        return MyListLayoutType_e.GridBox;
      case 30:
        return MyListLayoutType_e.MultiListBox;
    }
    return null;
  }

  static String toName(MyListLayoutType_e type) {
    switch (type) {
      case MyListLayoutType_e.Auto:
        return "自动";
      case MyListLayoutType_e.ListBox:
        return "列表";
      case MyListLayoutType_e.GridBox:
        return "网格";
      case MyListLayoutType_e.MultiListBox:
        return "多列列表";
    }
  }

  static String toDepict(MyListLayoutType_e type) {
    switch (type) {
      case MyListLayoutType_e.Auto:
        return """• 屏幕宽高比例接近手机时使用列表布局
• 接近平板或横屏时使用网格布局
• 若高度不足则优先使用多列列表代替网格布局""";
      case MyListLayoutType_e.ListBox:
      case MyListLayoutType_e.GridBox:
        return "";
      case MyListLayoutType_e.MultiListBox:
        return "根据宽度自动生成多个列表";
    }
  }
}

/// 是否使用动画
enum MyAnimationUseType_e {
  Enable,
  Disable,
  Auto,
}

class MyEventWorker_c {
  Worker? worker;
  StreamxxListener_c? listener;

  MyEventWorker_c({
    this.worker,
    this.listener,
  });

  void dispose() {
    worker?.dispose();
    worker = null;
    listener?.dispose();
    listener = null;
  }
}

class MyListController<T> extends MyRxControllerAdapt<MyListController<T>> {
  /// 用于存储可能要用到的监听器worker，
  late final List<MyEventWorker_c> eventWorkers = [];
  late final context = <String, dynamic>{};

  /// 列表项是否固定大小
  bool _isFixedSize = true;
  bool get isFixedSize => _isFixedSize;

  /// 数据列表
  List<T> list;

  /// 选中列表
  var checkList = <int>[];
  bool get isCheckAll =>
      (checkList.isNotEmpty && checkList.length == list.length);

  /// 在编辑模式下，才会显示允许拖拽和显示多选框
  /// 是否在编辑模式
  final isEdit = Streamxx_c(value: false, checkModify: true);

  /// 是否发生有修改
  bool isEdit_change = false;

  /// 是否显示全面加载动画
  bool isAllShimmer;

  /// 是否正在执行刷新
  bool isReflush;

  /// 是否正在执行加载更多
  bool isLoadingAppend;

  bool hideItemLeading = false;

  /// 当控制器销毁时，释放 [eventWorkers]
  bool enableAutoDisposeWorker;

  /// 更多功能列表 控制器
  MySimpleListController<MySettingListItemData_c>? _menuCtrl;
  MySimpleListController<MySettingListItemData_c> get menuCtrl {
    _menuCtrl ??= MySimpleListController<MySettingListItemData_c>([]);
    return _menuCtrl!;
  }

  /// 列表滚动控制器
  final ScrollController scrollCtrl;
  late final ListObserverController listScrollObserverCtrl;
  late final GridObserverController gridScrollObserverCtrl;

  /// 当滚动时执行，需要指定 [scrollObserver_autoTriggerObserveTypes]
  final void Function(int index)? onScrollFun;

  /// 指定执行 [onScrollFun] 的时机
  final List<ObserverAutoTriggerObserveType>?
      scrollObserver_autoTriggerObserveTypes;

  Future<void> Function()? onEditSaveClick;
  Future<MyListCtrlBehavior_e?> Function()? onAddClick;

  /// 布局方式
  late final MyListLayoutType_e useLayoutType;

  /// 是否应当以ListBox的样式展示Leading
  bool get showListBoxLeading => (useLayoutType == MyListLayoutType_e.ListBox ||
      useLayoutType == MyListLayoutType_e.MultiListBox);

  /// 列表控制器
  /// * [layoutType] 指定布局方式
  ///   * [MyListLayoutType_e.Auto] 时自动跟随设置，若设置也是[MyListLayoutType_e.Auto]
  ///   则根据设备宽高自动选择
  /// * [autoLayoutTypeByWidth] 指定宽度帮助分析布局
  MyListController(
    this.list, {
    super.enableAutoDelete,
    super.onInitFun,
    super.onCloseFun,
    this.onScrollFun,
    Duration? hideItemLeadingDuration,
    this.isAllShimmer = false,
    this.isReflush = false,
    this.isLoadingAppend = false,
    this.enableAutoDisposeWorker = true,
    MyListLayoutType_e layoutType = MyListLayoutType_e.ListBox,
    bool autoLayoutEnableGrid = true,
    double? autoLayoutTypeByWidth,
    ScrollController? scrollCtrl,
    this.scrollObserver_autoTriggerObserveTypes,
    this.onEditSaveClick,
    this.onAddClick,
  }) : scrollCtrl = scrollCtrl ?? ScrollController() {
    if (null != hideItemLeadingDuration &&
        MyGlobalStoreBase.setting_s.showIconInList) {
      // 构造列表时先隐藏图片，然后再显示，缓解创建列表时的卡顿
      hideItemLeading = true;
      Timer(hideItemLeadingDuration, () {
        setHideItemLeading(false);
      });
    }
    if (MyListLayoutType_e.Auto != layoutType) {
      useLayoutType = layoutType;
    } else {
      switch (MyGlobalStoreBase.setting_s.listLayoutType) {
        case MyListLayoutType_e.Auto:
          // 根据设备屏幕比例自动确定
          if (MyScaleBreakpoints.phone.isConform()) {
            // 手机布局
            useLayoutType = MyListLayoutType_e.ListBox;
          } else {
            late final useWidth =
                autoLayoutTypeByWidth ?? MyGlobalStoreBase.theme_s.windowWidth;
            late final useHeight =
                MyGlobalStoreBase.theme_s.windowContentHeight;
            // 横屏或较宽竖屏平板布局
            if (useWidth < 1200.r) {
              // 宽度不足，使用列表布局
              useLayoutType = MyListLayoutType_e.ListBox;
            } else if (useHeight < 1400.r || false == autoLayoutEnableGrid) {
              // 高度不足，使用多列列表，或者不允许网格布局
              useLayoutType = MyListLayoutType_e.MultiListBox;
            } else {
              // 宽高足够，使用网格布局
              useLayoutType = MyListLayoutType_e.GridBox;
            }
          }
          break;
        case MyListLayoutType_e.ListBox:
        case MyListLayoutType_e.GridBox:
        case MyListLayoutType_e.MultiListBox:
          useLayoutType = MyGlobalStoreBase.setting_s.listLayoutType;
          break;
      }
    }
    switch (useLayoutType) {
      case MyListLayoutType_e.Auto:
      case MyListLayoutType_e.ListBox:
        listScrollObserverCtrl = ListObserverController(
          controller: this.scrollCtrl,
        );
        break;
      case MyListLayoutType_e.MultiListBox:
      case MyListLayoutType_e.GridBox:
        gridScrollObserverCtrl = GridObserverController(
          controller: this.scrollCtrl,
        );
        break;
    }
  }

  static List<T> copyList<T>(List<T>? inlist) {
    if (null == inlist) {
      return [];
    }
    return List.generate(
      inlist.length,
      (index) => inlist[index],
    );
  }

  /// 构造 | 更新 widget
  /// * 这可以用来避免一些因为重复构造导致出问题的 widget
  /// * 使用它意味着，如果 [hasBuilderFun] 一直返回 [true]，则后面永远不会触发 [builderFun],
  /// 而是每次都触发 [updateFun]
  static Widget myBuilderBase({
    required Objxx_c<Widget?> widget,
    dynamic bindValue,
    bool Function()? hasBuilderFun, // 是否完成构造，默认判断widget是否非空
    required void Function() updateFun,
    required Widget Function() builderFun,
  }) {
    if ((null != hasBuilderFun && true == hasBuilderFun()) ||
        (null != widget.value)) {
      // 已经构造完成
      updateFun();
    } else {
      // 需要构造
      widget.value = builderFun();
    }
    return widget.value!;
  }

  static Widget myGetBuilder<T extends GetxController>({
    Key? key,
    Object? id,
    T? init,
    bool? global, // 当init为空时，默认为true，否则默认为false
    required Objxx_c<Widget?> widget,
    void Function(BindElement<T> state)? initState,
    bool Function(T in_ctrler)? hasBuilderFun, // 是否完成构造，默认判断widget是否非空
    required void Function(T in_ctrler) updateFun,
    required Widget Function(T in_ctrler) builderFun,
  }) {
    return GetBuilder<T>(
      key: key,
      init: init,
      id: id,
      global: global ?? (null == init),
      initState: initState,
      builder: (ctrl) {
        return myBuilderBase(
          widget: widget,
          hasBuilderFun: (null != hasBuilderFun)
              ? () => hasBuilderFun(init ?? ctrl)
              : null,
          updateFun: () => updateFun(init ?? ctrl),
          builderFun: () => builderFun(init ?? ctrl),
        );
      },
    );
  }

  static Future<MyListCtrlBehavior_e?> autoSave<T>(
    MyListController<T> controller,
    FutureOr<MyListCtrlBehavior_e?> Function() doFun, {
    bool autoEditOpen = false,
  }) async {
    // 打开编辑模式
    if (autoEditOpen) {
      controller.ensureEditOpen();
    }
    final rebehavior = await doFun();
    switch (rebehavior) {
      case MyListCtrlBehavior_e.SaveAndUpdate:
        controller.setEditChange(doUpdate: false);
        await controller.onEditSaveClick?.call();
      case MyListCtrlBehavior_e.ExitAndUpdate:
        controller.editExit();
      case MyListCtrlBehavior_e.ClearCheckAndUpdate:
        controller.checkList.clear();
        controller.update();
      case MyListCtrlBehavior_e.OpenAndUpdate:
        if (controller.isEdit.value) {
          controller.update();
        } else {
          controller.editOpen();
        }
      case MyListCtrlBehavior_e.Update:
        controller.update();
      case MyListCtrlBehavior_e.None:
      case null:
        break;
    }
    return rebehavior;
  }

  @override
  void onClose() {
    if (enableAutoDisposeWorker) {
      workersClear();
    }
    scrollCtrl.dispose();
    // 清理 list 可能导致部分ui组件报错数组越界
    // list = const [];
    checkList = const [];
    super.onClose();
  }

  /// 删除控制器
  @override
  void delete() {
    _menuCtrl?.delete();
    super.delete();
  }

  T1? getContextValue<T1>(String key) {
    final data = context[key];
    if (data is T1) {
      return data;
    }
    return null;
  }

  /// 添加监听器worker
  /// * 返回添加后监听器列表的长度
  int addWorker({
    Worker? worker,
    StreamxxListener_c? listener,
  }) {
    eventWorkers.add(MyEventWorker_c(worker: worker, listener: listener));
    return eventWorkers.length;
  }

  /// 清空workers
  void workersClear() {
    for (int i = eventWorkers.length; i-- > 0;) {
      eventWorkers[i].dispose();
    }
    eventWorkers.clear();
  }

  /// 更换list
  void update_list(
    List<T> in_list, {
    bool doUpdate = true,
  }) {
    // 更新 [checklist]
    if (isEdit.value && in_list.length != list.length) {
      // 如果是全选，则刷新后仍然全选
      if (checkList.length == list.length) {
        checkList = List<int>.generate(
          list.length,
          (index) => index,
        );
      } else {
        checkList.clear();
      }
    }
    list = in_list;
    if (doUpdate) {
      update();
    }
  }

  void setScrollInitIndex(int index) {
    switch (useLayoutType) {
      case MyListLayoutType_e.Auto:
        break;
      case MyListLayoutType_e.ListBox:
        listScrollObserverCtrl.initialIndex = index;
        break;
      case MyListLayoutType_e.MultiListBox:
      case MyListLayoutType_e.GridBox:
        gridScrollObserverCtrl.initialIndex = index;
    }
  }

  /// 判断滚动到目标位置[targetIndex]是否应当启用动画
  bool isableScrollAnimated(MyAnimationUseType_e doAnimated, int targetIndex) {
    switch (doAnimated) {
      case MyAnimationUseType_e.Auto:
        if (MyGlobalStoreBase.setting_s
            .isableAnimated(MyAnimatedLevel_e.Medium)) {
          switch (useLayoutType) {
            case MyListLayoutType_e.Auto:
            case MyListLayoutType_e.ListBox:
            case MyListLayoutType_e.MultiListBox:
              // 自动滚动判断，如果目标离当前位置大于10行，则不使用动画
              final nowIndex =
                  scrollCtrl.offset ~/ MyListBase.defListBoxItemHeight;
              var subIndex = (targetIndex - nowIndex);
              if (subIndex < 0) {
                subIndex = -subIndex;
              }
              return (subIndex <= 10);
            case MyListLayoutType_e.GridBox:
              final nowIndex =
                  scrollCtrl.offset ~/ MyListBase.defGridBoxItemHeight;
              var subIndex = (targetIndex - nowIndex);
              if (subIndex < 0) {
                subIndex = -subIndex;
              }
              return (subIndex <= 16);
          }
        } else {
          return false;
        }
      case MyAnimationUseType_e.Enable:
        return true;
      case MyAnimationUseType_e.Disable:
        return false;
    }
  }

  /// 滚动回列表顶部
  /// * [useAnimatedType] 是否使用动画
  /// * [bounce] 是否超出滚动范围，使用回弹效果
  /// * [bounceExtent] 超出滚动范围的距离
  Future<void> scrollToTop({
    MyAnimationUseType_e useAnimatedType = MyAnimationUseType_e.Auto,
    bool bounce = false,
    double? bounceExtent,
  }) async {
    final double position =
        bounce ? (bounceExtent ?? -MyListBase.defGridBoxItemHeight) : 0;
    if (isableScrollAnimated(useAnimatedType, 0)) {
      return scrollCtrl
          .animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          )
          .catchError((e) {});
    } else {
      return scrollCtrl.jumpTo(position);
    }
  }

  /// 滚动到列表底部
  /// * [useAnimatedType] 是否使用动画
  /// * [bounce] 是否超出滚动范围，使用回弹效果
  /// * [bounceExtent] 超出滚动范围的距离
  Future<void> scrollToEnd({
    MyAnimationUseType_e useAnimatedType = MyAnimationUseType_e.Auto,
    bool bounce = false,
    double? bounceExtent,
  }) async {
    final position = bounce
        ? scrollCtrl.position.maxScrollExtent +
            (bounceExtent ?? MyListBase.defGridBoxItemHeight)
        : scrollCtrl.position.maxScrollExtent;
    if (isableScrollAnimated(useAnimatedType, list.length)) {
      return scrollCtrl
          .animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          )
          .catchError((e) {});
    }
    return scrollCtrl.jumpTo(
      position,
    );
  }

  /// 滚动到指定下标位置
  Future<void> scrollToIndex(
    int index, {
    int? shift,
    Duration? duration,
    MyAnimationUseType_e useAnimatedType = MyAnimationUseType_e.Auto,
  }) async {
    if (list.isNotEmpty && scrollCtrl.hasClients) {
      switch (useLayoutType) {
        case MyListLayoutType_e.Auto:
        case MyListLayoutType_e.ListBox:
          index += (shift ?? -1);
          if (index < 0) {
            index = 0;
          } else if (index > list.length) {
            index = list.length;
          }
          if (isableScrollAnimated(useAnimatedType, index)) {
            return listScrollObserverCtrl
                .animateTo(
                  index: index,
                  duration: duration ?? const Duration(milliseconds: 700),
                  curve: Curves.ease,
                  isFixedHeight: isFixedSize,
                  offset: (targetOffset) => 100.r,
                )
                .catchError((e) {});
          } else {
            return listScrollObserverCtrl
                .jumpTo(
                  index: index,
                  isFixedHeight: isFixedSize,
                  offset: (targetOffset) => 100.r,
                )
                .catchError((e) {});
          }
        case MyListLayoutType_e.MultiListBox:
        case MyListLayoutType_e.GridBox:
          index += (shift ?? 0);
          if (index < 0) {
            index = 0;
          } else if (index > list.length) {
            index = list.length;
          }
          if (isableScrollAnimated(useAnimatedType, index)) {
            return gridScrollObserverCtrl
                .animateTo(
                  index: index,
                  duration: duration ?? const Duration(milliseconds: 700),
                  curve: Curves.ease,
                  offset: (targetOffset) => 100.r,
                  isFixedHeight: isFixedSize,
                )
                .catchError((e) {});
          }
          return gridScrollObserverCtrl
              .jumpTo(
                index: index,
                offset: (targetOffset) => 100.r,
                isFixedHeight: isFixedSize,
              )
              .catchError((e) {});
      }
    }
  }

  /// 滚动到第一次in_fun返回true时的位置
  Future<int?> scrollToFirstWhen(
    bool Function(T item, int index) in_fun, {
    int? shift,
    MyAnimationUseType_e useAnimatedType = MyAnimationUseType_e.Auto,
  }) async {
    int index = 0;
    for (; index < list.length; ++index) {
      if (true == in_fun(list[index], index)) {
        await scrollToIndex(
          index,
          shift: shift,
          useAnimatedType: useAnimatedType,
        );
        return index;
      }
    }
    return null;
  }

  void ensureEditOpen() {
    if (false == isEdit.value) {
      editOpen();
    }
  }

  // 开启编辑模式，开启时默认会备份list
  void editOpen({
    bool doUpdate = true,
  }) {
    isEdit.value = true;
    if (doUpdate) {
      update();
    }
  }

  /// 退出编辑模式
  void editExit({
    bool doUpdate = true,
  }) {
    isEdit.value = false;
    isEdit_change = false;
    checkList.clear();
    if (doUpdate) {
      update();
    }
  }

  /// 保存修改
  /// [onEditSave] 返回 true 时，将会把 [listBackUp] 置空
  Future<bool> editSave({
    Future<bool> Function(
      List<T> list,
      bool isEdit_change,
    )? onEditSave,
    bool doExit = true,
  }) async {
    if (null != onEditSave) {
      if (false == (await onEditSave(list, isEdit_change))) {
        return false;
      }
    }
    if (true == doExit) {
      editExit();
    } else {
      setEditChange(isChange: false);
    }
    return true;
  }

  void setEditChange({
    bool isChange = true,
    bool doUpdate = true,
  }) {
    isEdit_change = isChange;
    if (doUpdate) {
      update();
    }
  }

  void setIsAllShimmer(
    bool enable, {
    bool doUpdate = true,
  }) {
    isAllShimmer = enable;
    if (doUpdate) {
      update();
    }
  }

  void setIsReflush(bool isable) {
    isReflush = isable;
  }

  void setIsLoadingAppend(bool isable) {
    isLoadingAppend = isable;
  }

  void setHideItemLeading(bool enable) {
    hideItemLeading = enable;
    update();
  }

  void unCheckAll({
    bool doUpdate = true,
  }) {
    checkList.clear();
    if (doUpdate) {
      update();
    }
  }

  void checkAll({
    bool doUpdate = true,
  }) {
    checkList = List<int>.generate(
      list.length,
      (index) => index,
    );
    if (doUpdate) {
      update();
    }
  }
}

class MyListBase<T> extends StatelessWidget {
  /// 让列表总是可弹性滚动
  static const allBouncingScrollPhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  static const int defRelativeMiniListBoxItemBorderRadius = 30;
  static const int defRelativeListBoxItemBorderRadius = 40;
  static const int defRelativeGridBoxItemBorderRadius = 50;

  static const int defRelativeListBoxItemHeight = 220;
  static const int defRelativeGridBoxItemHeight = 600;
  static const int defRelativeMultiListBoxItemWidth = 1000;

  static const double defRelativeListBoxLeadingSize = 160;
  static const double defRelativeGirdBoxLeadingSize = 600;

  /// 单行高度
  static double get defListBoxItemHeight => defRelativeListBoxItemHeight.r;
  static double get defGridBoxItemHeight => defRelativeGridBoxItemHeight.r;
  static double get defMultiListBoxItemWidth =>
      defRelativeMultiListBoxItemWidth.r;

  /// Leading 图片大小
  static double get defListBoxItemLeadingSize =>
      defRelativeListBoxLeadingSize.r;
  static double get defGridBoxItemLeadingSize =>
      defRelativeGirdBoxLeadingSize.r;

  static const Duration defAnimatedDuration = Duration(milliseconds: 200);

  final MyListController<T> controller;

  /// _开头的事件函数是最终决定使用的响应函数
  /// * 一般响应事件由两个函数构成 [onEvent] 和 [use_onEvent]
  /// * [onEvent] 用于接收构造函数的外部传参
  /// * [use_onEvent] 是最终决定会使用的响应函数
  /// * 且会存在一个构造该响应函数的可继承函数 [onEventFun]
  /// * 在 [init] 时，会调用 [onEventFun] 构造 [use_onEvent]
  /// * 在 [onEventFun] 内部一般就会决定是否使用外部传参的 [onEvent] 和默认的响应
  /// 函数。
  /// * 继承本类时，可直接继承 [onEventFun] 修改构造决定、修改默认的响应函数。
  late final bool Function(T item, int index)? use_selected;
  late final void Function(T item, int index)? use_onItemCheck;
  late final void Function(T item, int index)? use_onItemTap;
  late final void Function(T item, int index)? use_onLongPress;

  /// (title, relist)
  late final MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?> use_onItemMenu;
  late final Future<bool> Function()? use_onReflush;
  late final Future<IndicatorResult> Function()? use_onLoadMore;

  final bool isFixedSize;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  /// 是否允许当右键时显示更多功能列表
  final bool enableItemSecondaryTapToMenu;

  /// 是否启用拖拽
  final bool enableDrop;

  /// 是否启用多选框
  final bool enableCheck;

  /// 列表项数量
  final int? itemCount;

  MyListBase(
    this.controller, {
    super.key,
    this.isFixedSize = true,
    this.enableDrop = true,
    this.enableCheck = true,
    bool doInitFunction = true,
    this.itemCount,
    this.physics = MyListBase.allBouncingScrollPhysics,
    this.enableItemSecondaryTapToMenu = true,
    this.shrinkWrap = false,
    this.padding,
  }) {
    controller._isFixedSize = isFixedSize;
    if (doInitFunction) {
      initFunction();
    }
  }

  /// 初始化函数，它会伴随 [MyListBase] 的构造而执行
  void initFunction() {
    use_selected = selectedFun();
    use_onItemCheck = onItemCheckFun();
    use_onItemTap = onItemTapFun();
    use_onLongPress = onLongPressFun();
    use_onItemMenu = onItemMenuFun();
    use_onReflush = onReflushFun();
    use_onLoadMore = onLoadMoreFun();
  }

  /// 计算正确可用的 列表项数量
  int getItemCount() {
    int count = controller.list.length;
    if (null != itemCount && itemCount! >= 0 && itemCount! <= count) {
      count = itemCount!;
    }
    return count;
  }

  /// 拖动列表项事件
  void dragItem(
    int oldItemIndex,
    int newItemIndex, {
    bool doCheck = true,
  }) {
    if (doCheck && (false == controller.isEdit.value || false == enableDrop)) {
      return;
    }
    if (oldItemIndex < newItemIndex) {
      --newItemIndex;
    }
    var tItem = controller.list.removeAt(oldItemIndex);
    controller.list.insert(newItemIndex, tItem);
    if (enableCheck) {
      // 调整移动了项目后选中列表中的下标
      final checkarr = controller.checkList;
      if (oldItemIndex < newItemIndex) {
        for (int i = 0; i < checkarr.length; ++i) {
          if (checkarr[i] == oldItemIndex) {
            checkarr[i] = newItemIndex;
          } else if (checkarr[i] > oldItemIndex &&
              checkarr[i] <= newItemIndex) {
            checkarr[i]--;
          }
        }
      } else if (oldItemIndex > newItemIndex) {
        for (int i = 0; i < checkarr.length; ++i) {
          if (checkarr[i] == oldItemIndex) {
            checkarr[i] = newItemIndex;
          } else if (checkarr[i] >= newItemIndex &&
              checkarr[i] < oldItemIndex) {
            checkarr[i]++;
          }
        }
      }
    }
    controller.setEditChange();
    HapticFeedback.selectionClick();
  }

  Widget? buildItemLeading(T item, int index) {
    return null;
  }

  Widget? buildItemLeadingWhenHide(T item, int index) {
    switch (controller.useLayoutType) {
      case MyListLayoutType_e.Auto:
      case MyListLayoutType_e.ListBox:
      case MyListLayoutType_e.MultiListBox:
        return const MySizedBox(
          height: defRelativeListBoxLeadingSize,
          width: defRelativeListBoxLeadingSize,
        );
      case MyListLayoutType_e.GridBox:
        return const MySizedBox(
          height: defRelativeGirdBoxLeadingSize,
          width: defRelativeGirdBoxLeadingSize,
        );
    }
  }

  Widget? buildItemInfo(T item, int index) {
    return null;
  }

  Widget? buildItemTag(T item, int index) {
    return null;
  }

  Widget? buildItemActions(T item, int index) {
    return null;
  }

  Widget? buildHeader() {
    return null;
  }

  Widget? buildEmpty() {
    return null;
  }

  void Function(T item, int index)? onItemCheckFun() {
    return null;
  }

  bool Function(T item, int index)? selectedFun() {
    return null;
  }

  void Function(T item, int index)? onItemTapFun() {
    return null;
  }

  void Function(T item, int index)? onLongPressFun() {
    return null;
  }

  MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?> onItemMenuFun() {
    return const MyListCtrlBtn_c.hide();
  }

  /// 刷新事件
  Future<bool> Function()? onReflushFun() {
    return null;
  }

  /// 加载更多事件
  Future<IndicatorResult> Function()? onLoadMoreFun() {
    return null;
  }

  void onItemSecondaryTapDo(T item, int index) {
    if (enableItemSecondaryTapToMenu) {
      onItemMenuDo(item, index);
    }
  }

  void onItemMenuDo(T item, int index) async {
    if (MyListCtrlBtnState_e.Show == use_onItemMenu.state) {
      final onTap = use_onItemMenu.onTap;
      if (null != onTap) {
        final (title, depict, relist) = await onTap.call(item, index, [
          if (enableDrop && index != 0)
            MySettingListItemData_c(
              leaderSvgName: MySvgNames_e.top,
              infoMain: "移动到列表顶部",
              infoCross: "欲穷千里目，更上一层楼",
              onTap: (p0, p1, p2) {
                MyRoute_c.back();
                MyListController.autoSave(
                  controller,
                  () {
                    dragItem(
                      index,
                      0,
                      doCheck: false,
                    );
                    return MyListCtrlBehavior_e.SaveAndUpdate;
                  },
                );
              },
            ),
          if (enableDrop && index != (controller.list.length - 1))
            MySettingListItemData_c(
              leaderSvgName: MySvgNames_e.bottom,
              infoMain: "移动到列表底部",
              infoCross: "飞流直下三千尺，疑是银河落九天",
              onTap: (p0, p1, p2) {
                MyRoute_c.back();
                MyListController.autoSave(
                  controller,
                  () {
                    dragItem(
                      index,
                      controller.list.length,
                      doCheck: false,
                    );
                    return MyListCtrlBehavior_e.SaveAndUpdate;
                  },
                );
              },
            ),
        ]);
        if (null != relist) {
          MyPopup.showSelect(
            title: title ?? "更多",
            depict: depict,
            data: relist,
          );
        }
      }
    }
  }

  void onItemCheckDo(T item, int index) {
    use_onItemCheck?.call(item, index);
    controller.update();
  }

  Widget? buildBtnItemMenu(T item, int index) {
    if (MyListCtrlBtnState_e.Hide != use_onItemMenu.state) {
      return MyList.buildCtrlBtn(
        child: MyBtn.simple(
          svgName: MySvgNames_e.menu,
          onTap: (MyListCtrlBtnState_e.Disable != use_onItemMenu.state)
              ? () => onItemMenuDo(item, index)
              : null,
        ),
      );
    }
    return null;
  }

  /// 构建列表项
  Widget buildListBoxItem(
    T item,
    int index,
    Decoration? decoration,
    Decoration? selectDecoration,
  ) {
    // 是否选中当前列表项
    final isSelected = (false == controller.isEdit.value &&
        true == use_selected?.call(item, index));
    final myItemLeading = controller.hideItemLeading
        ? buildItemLeadingWhenHide(item, index)
        : buildItemLeading(item, index);
    final myItemInfo = buildItemInfo(item, index);
    final myItemTag = buildItemTag(item, index);
    final myItemActions = buildItemActions(item, index);
    final btnItemMenu = buildBtnItemMenu(item, index);
    final child = Row(
      children: [
        if (null != myItemLeading)
          (null != use_onItemTap || null != use_onLongPress)
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.isEdit.value && enableCheck) {
                        // 多选状态
                        onItemCheckDo(item, index);
                      } else {
                        use_onItemTap?.call(item, index);
                      }
                    },
                    onLongPress: () {
                      use_onLongPress?.call(item, index);
                    },
                    onSecondaryTap: () {
                      onItemSecondaryTapDo(item, index);
                    },
                    child: myItemLeading,
                  ),
                )
              : myItemLeading,
        Expanded(
          child: (null == myItemInfo)
              ? const SizedBox()
              // 存在触摸事件或编辑状态
              : (null != use_onItemTap ||
                      null != use_onLongPress ||
                      controller.isEdit.value)
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (controller.isEdit.value && enableCheck) {
                            // 选中状态
                            onItemCheckDo(item, index);
                          } else {
                            use_onItemTap?.call(item, index);
                          }
                        },
                        onLongPress: () => use_onLongPress?.call(item, index),
                        onSecondaryTap: () {
                          onItemSecondaryTapDo(item, index);
                        },
                        child: myItemInfo,
                      ),
                    )
                  : myItemInfo,
        ),
        if (null != myItemTag) myItemTag,
        if (null != myItemActions) myItemActions,
        if (null != btnItemMenu) btnItemMenu,
        Visibility(
          visible: enableCheck && controller.isEdit.value,
          child: MyList.buildCtrlBtn(
            child: MyBtn.simple(
              // 选中框
              onTap: () {
                if (null != use_onItemCheck) {
                  onItemCheckDo(item, index);
                }
              },
              color: (controller.checkList.contains(index))
                  ? MyColors_e.blue_tianyi
                  : null,
              svgName: (controller.checkList.contains(index))
                  ? MySvgNames_e.checkRect_l
                  : MySvgNames_e.checkRect_d,
            ),
          ),
        ),
        Visibility(
          visible: enableDrop && controller.isEdit.value,
          child: SizedBox(width: MyBtn.defSimpleSize + 20.r),
        ),
      ],
    );
    const padding = MyEdgeInsets.only(
      top: 20,
      bottom: 20,
      left: 20,
    );
    return Container(
      key: ValueKey(index),
      height: (controller.isFixedSize) ? double.infinity : null,
      width: double.infinity,
      padding: padding,
      margin: const MyEdgeInsets.only(top: 10, bottom: 10),
      // 选中动画
      decoration: isSelected ? selectDecoration : decoration,
      child: child,
    );
  }

  Widget? buildGridBoxItem(
    T item,
    int index,
    Decoration? decoration,
    Decoration? selectDecoration,
  ) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    // 是否选中当前列表项
    final isSelected = (false == controller.isEdit.value &&
        true == use_selected?.call(item, index));
    final myItemLeading = controller.hideItemLeading
        ? buildItemLeadingWhenHide(item, index)
        : buildItemLeading(item, index);
    final myItemInfo = buildItemInfo(item, index);
    final myItemTag = buildItemTag(item, index);
    final myItemActions = buildItemActions(item, index);
    final btnItemMenu = buildBtnItemMenu(item, index);
    final myItemContent = Stack(
      alignment: Alignment.topLeft,
      children: [
        // itemLeading
        if (null != myItemLeading)
          (null != use_onItemTap || null != use_onLongPress)
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.isEdit.value && enableCheck) {
                        // 选中状态
                        onItemCheckDo(item, index);
                      } else {
                        use_onItemTap?.call(item, index);
                      }
                    },
                    onLongPress: () {
                      use_onLongPress?.call(item, index);
                    },
                    onSecondaryTap: () {
                      onItemSecondaryTapDo(item, index);
                    },
                    child: myItemLeading,
                  ),
                )
              : myItemLeading,
        // itemActions
        if ((null != myItemActions) ||
            (null != btnItemMenu) ||
            (enableCheck && controller.isEdit.value))
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const MyEdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 20,
                right: 20,
              ),
              margin: const MyEdgeInsets.only(
                left: 30,
                right: 30,
                top: 30,
              ),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withOpacity(0.3),
                borderRadius: const MyBorderRadius(MyRadius(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (null != myItemActions) myItemActions,
                  if (null != btnItemMenu) btnItemMenu,
                  Visibility(
                    visible: enableCheck && controller.isEdit.value,
                    child: MyBtn.simple(
                      // 选中框
                      onTap: () {
                        if (null != use_onItemCheck) {
                          onItemCheckDo(item, index);
                        }
                      },
                      color: (controller.checkList.contains(index))
                          ? MyColors_e.blue_tianyi
                          : null,
                      svgName: (controller.checkList.contains(index))
                          ? MySvgNames_e.checkRect_l
                          : MySvgNames_e.checkRect_d,
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(builder: (content, constraints) {
            final size = min(constraints.maxWidth, constraints.maxWidth);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: size,
                height: size,
                child: myItemContent,
              ),
            );
          }),
        ),
        // itemInfo
        if (null != myItemInfo)
          // 存在触摸事件或编辑状态
          (null != use_onItemTap ||
                  null != use_onLongPress ||
                  controller.isEdit.value)
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.isEdit.value) {
                        // 选中状态
                        onItemCheckDo(item, index);
                      } else {
                        use_onItemTap?.call(item, index);
                      }
                    },
                    onLongPress: () => use_onLongPress?.call(item, index),
                    onSecondaryTap: () {
                      onItemSecondaryTapDo(item, index);
                    },
                    child: myItemInfo,
                  ),
                )
              : myItemInfo,
        if (null != myItemTag) myItemTag,
      ],
    );
    const padding = MyEdgeInsets.only(top: 30, left: 30, right: 30, bottom: 15);
    return Container(
      key: ValueKey(index),
      height: double.infinity,
      width: double.infinity,
      padding: padding,
      // 选中动画
      decoration: isSelected ? selectDecoration : null,
      child: child,
    );
  }

  /// 尝试构建支持上下拉的列表外框
  /// * 如果 [onReflush] 或 [onLoadMore] 存在, 则构建外框
  /// * 否则不额外处理 [childBuilder]
  Widget buildReflushBase({
    required Widget Function(
      ScrollPhysics? physics,
      ScrollController? scrollCtrl,
    ) childBuilder,
  }) {
    if (null == use_onReflush && null == use_onLoadMore) {
      return childBuilder(physics, controller.scrollCtrl);
    } else {
      return EasyRefresh.builder(
        key: const ValueKey("refresh"),
        header: const MaterialHeader(
          safeArea: false,
          clamping: false,
          color: MyColors_e.write,
          backgroundColor: MyColors_e.blue_tianyi,
        ),
        footer: BezierFooter(
          triggerOffset: 150.r,
          foregroundColor: MyColors_e.write,
          backgroundColor: MyColors_e.blue_tianyi,
          noMoreWidget: const MyTextCross("没有更多了"),
        ),
        canRefreshAfterNoMore: true,
        canLoadAfterNoMore: true,
        scrollController: controller.scrollCtrl,
        onRefresh: (null != use_onReflush)
            ? () async {
                if (false == controller.isReflush) {
                  controller.setIsReflush(true);
                  final rebool = await use_onReflush!();
                  controller.setIsReflush(false);
                  HapticFeedback.vibrate();
                  if (rebool) {
                    return IndicatorResult.success;
                  } else {
                    return IndicatorResult.fail;
                  }
                }
                return IndicatorResult.none;
              }
            : null,
        onLoad: (null != use_onLoadMore)
            ? () async {
                if (false == controller.isLoadingAppend) {
                  controller.setIsLoadingAppend(true);
                  final reState = await use_onLoadMore!();
                  controller.setIsLoadingAppend(false);
                  HapticFeedback.vibrate();
                  return reState;
                }
                return IndicatorResult.none;
              }
            : null,
        scrollBehaviorBuilder: (null != physics)
            ? (_) {
                return ERScrollBehavior(physics);
              }
            : null,
        // 如果使用自定义的physics，可能导致高度不够时无法滑动出刷新。
        childBuilder: (context, physics) => childBuilder(
          physics,
          controller.scrollCtrl,
        ),
      );
    }
  }

  Widget buildBoxEmpty(EdgeInsets listPadding) {
    // 空列表是显示
    final header = buildHeader();
    final empty = buildEmpty();
    return buildReflushBase(
      childBuilder: (physics, scrollCtrl) => ListView(
        key: const ValueKey("mylist-empty"),
        physics: physics,
        shrinkWrap: shrinkWrap,
        controller: scrollCtrl,
        padding: listPadding,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        children: [
          if (null != header) header,
          (null != empty) ? empty : MyTextCross.buildDefEmpty(),
        ],
      ),
    );
  }

  Widget buildListBoxAllShimmer(EdgeInsets listPadding) {
    // 列表加载动画
    return buildReflushBase(
      childBuilder: (physics, scrollCtrl) => MyShimmerList(
        key: const ValueKey("mylist-loading"),
        physics: physics,
        padding: listPadding,
        shrinkWrap: shrinkWrap,
        header: buildHeader(),
      ),
    );
  }

  BoxDecoration? createListBoxItemStyle(bool selected) {
    return MyGlobalStoreBase.theme_s.mytheme.listBoxItemDecoration
        ?.call(selected);
  }

  BoxDecoration? createGridBoxItemStyle(bool selected) {
    return MyGlobalStoreBase.theme_s.mytheme.gridBoxItemDecoration
        ?.call(selected);
  }

  Widget buildListBoxMain(EdgeInsets listPadding, int count) {
    final headerWidget = buildHeader();
    return buildReflushBase(
      childBuilder: (physics, scrollCtrl) {
        final style = createListBoxItemStyle(false);
        final selectStyle = createListBoxItemStyle(true);
        Widget itemBuilder(BuildContext _, int index) {
          return buildListBoxItem(
            controller.list[index],
            index,
            style,
            selectStyle,
          );
        }

        return ListViewObserver(
          leadingOffset: listPadding.top,
          controller: controller.listScrollObserverCtrl,
          onObserve: (model) =>
              (null != controller.scrollObserver_autoTriggerObserveTypes)
                  ? controller.onScrollFun?.call(model.firstChild?.index ?? 0)
                  : null,
          autoTriggerObserveTypes:
              controller.scrollObserver_autoTriggerObserveTypes,
          child: enableDrop
              ? MyReorderableList.builder(
                  key: const ValueKey("mylist-list"),
                  padding: listPadding,
                  // 当指定 [itemExtent] 时，排序会空出一行的高度
                  itemExtent:
                      (isFixedSize) ? MyListBase.defListBoxItemHeight : null,
                  header: headerWidget,
                  shrinkWrap: shrinkWrap,
                  scrollController: scrollCtrl,
                  physics: physics,
                  itemCount: count,
                  itemBuilder: itemBuilder,
                  itemDragHandle: (enableDrop && controller.isEdit.value)
                      ? const _BuildItemDargHandle()
                      : const SizedBox(),
                  onReorder: (oldIndex, newIndex) =>
                      dragItem(oldIndex, newIndex),
                  proxyDecorator: (child, index, animation) {
                    final theme = MyGlobalStoreBase.theme_s.mytheme;
                    return Container(
                      color: theme.backgroundColor,
                      child: child,
                    );
                  },
                )
              : CustomScrollView(
                  shrinkWrap: shrinkWrap,
                  controller: scrollCtrl,
                  physics: physics,
                  slivers: [
                    if (null != headerWidget)
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: listPadding.top,
                          left: listPadding.left,
                          right: listPadding.right,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: headerWidget,
                        ),
                      ),
                    SliverPadding(
                      padding: listPadding,
                      sliver: isFixedSize
                          ? SliverFixedExtentList.builder(
                              key: const ValueKey("mylist-list"),
                              itemExtent: MyListBase.defListBoxItemHeight,
                              itemCount: count,
                              itemBuilder: itemBuilder,
                            )
                          : SliverList.builder(
                              key: const ValueKey("mylist-list"),
                              itemCount: count,
                              itemBuilder: itemBuilder,
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget buildGridBoxMain(EdgeInsets listPadding, int count) {
    final style = createGridBoxItemStyle(false);
    final selectStyle = createGridBoxItemStyle(true);
    final headerWidget = buildHeader();
    return buildReflushBase(
      childBuilder: (physics, scrollCtrl) {
        return GridViewObserver(
          leadingOffset: listPadding.top,
          controller: controller.gridScrollObserverCtrl,
          onObserve: (null != controller.scrollObserver_autoTriggerObserveTypes)
              ? (model) => controller.onScrollFun
                  ?.call(model.displayingChildIndexList.firstOrNull ?? 0)
              : null,
          autoTriggerObserveTypes:
              controller.scrollObserver_autoTriggerObserveTypes,
          child: CustomScrollView(
            shrinkWrap: shrinkWrap,
            controller: scrollCtrl,
            physics: physics,
            slivers: [
              if (null != headerWidget)
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: listPadding.top,
                    left: listPadding.left,
                    right: listPadding.right,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: headerWidget,
                  ),
                ),
              SliverPadding(
                padding: listPadding,
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MyListBase.defGridBoxItemHeight,
                    crossAxisSpacing: 10.r,
                    mainAxisSpacing: 10.r,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: count,
                  itemBuilder: (context, index) => buildGridBoxItem(
                    controller.list[index],
                    index,
                    style,
                    selectStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMultiListBoxMain(EdgeInsets listPadding, int count) {
    final style = createListBoxItemStyle(false);
    final selectStyle = createListBoxItemStyle(true);
    final headerWidget = buildHeader();
    return buildReflushBase(
      childBuilder: (physics, scrollCtrl) {
        return GridViewObserver(
          leadingOffset: listPadding.top,
          controller: controller.gridScrollObserverCtrl,
          onObserve: (null != controller.scrollObserver_autoTriggerObserveTypes)
              ? (model) => controller.onScrollFun
                  ?.call(model.displayingChildIndexList.firstOrNull ?? 0)
              : null,
          autoTriggerObserveTypes:
              controller.scrollObserver_autoTriggerObserveTypes,
          child: CustomScrollView(
            shrinkWrap: shrinkWrap,
            controller: scrollCtrl,
            physics: physics,
            slivers: [
              if (null != headerWidget)
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: listPadding.top,
                    left: listPadding.left,
                    right: listPadding.right,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: headerWidget,
                  ),
                ),
              SliverPadding(
                padding: listPadding,
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MyListBase.defMultiListBoxItemWidth,
                    mainAxisExtent: MyListBase.defListBoxItemHeight,
                    crossAxisSpacing: 10.r,
                  ),
                  itemCount: count,
                  itemBuilder: (context, index) => buildListBoxItem(
                    controller.list[index],
                    index,
                    style,
                    selectStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reWidget = GetBuilder(
      key: const ValueKey("mylist"),
      global: false,
      init: controller,
      builder: (_) {
        final listPadding = padding ??
            ((false == shrinkWrap && MyGlobalStoreBase.setting_s.showListMask)
                ? const MyEdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 80,
                    bottom: 80,
                  )
                : const MyEdgeInsets.all(30));
        if (controller.isAllShimmer) {
          // 列表加载动画
          return buildListBoxAllShimmer(listPadding);
        }
        final count = getItemCount();
        if (count == 0) {
          // 空列表是显示
          return buildBoxEmpty(listPadding);
        }
        // 列表主体
        switch (controller.useLayoutType) {
          case MyListLayoutType_e.Auto:
          case MyListLayoutType_e.ListBox:
            return buildListBoxMain(listPadding, count);
          case MyListLayoutType_e.GridBox:
            return buildGridBoxMain(listPadding, count);
          case MyListLayoutType_e.MultiListBox:
            return buildMultiListBoxMain(listPadding, count);
        }
      },
    );
    if (false == shrinkWrap && MyGlobalStoreBase.setting_s.showListMask) {
      return MyListMask(child: reWidget);
    } else {
      return reWidget;
    }
  }
}

class _BuildItemDargHandle extends StatelessWidget {
  const _BuildItemDargHandle();

  @override
  Widget build(BuildContext context) {
    return MyBtn.simple(
      onTap: () {},
      svgName: MySvgNames_e.sort,
    );
  }
}

enum MyListCtrlBtnState_e {
  Show,
  Hide,
  Disable,
}

class MyListCtrlBtn_c<T> {
  final MyListCtrlBtnState_e state;
  final T? onTap;

  const MyListCtrlBtn_c({
    this.state = MyListCtrlBtnState_e.Show,
    required this.onTap,
  });

  const MyListCtrlBtn_c.hide()
      : state = MyListCtrlBtnState_e.Hide,
        onTap = null;

  bool isHide() {
    return (MyListCtrlBtnState_e.Hide == state);
  }

  bool isDisable() {
    return (MyListCtrlBtnState_e.Disable == state);
  }

  MyListCtrlBtn_c<T> copyWith({
    MyListCtrlBtnState_e? state,
    T? onTap,
  }) {
    return MyListCtrlBtn_c(
      state: state ?? this.state,
      onTap: onTap ?? this.onTap,
    );
  }
}

enum MyListEventState_e {
  Enable,
  Disable,
}

class MyListEvent_c<T> {
  final MyListEventState_e state;
  final T? onEvent;

  const MyListEvent_c({
    this.state = MyListEventState_e.Enable,
    required this.onEvent,
  });

  const MyListEvent_c.disable()
      : state = MyListEventState_e.Disable,
        onEvent = null;

  /// 选择使用的事件响应函数
  /// * 如果[event]非null，且[state]为Enable，则使用[event.onEvent]
  /// * 否则使用[onEvent]
  static T? switchOnEvent<T>(MyListEvent_c<T?>? event, T? onEvent) {
    if (null != event) {
      switch (event.state) {
        case MyListEventState_e.Enable:
          return event.onEvent;
        case MyListEventState_e.Disable:
          return null;
      }
    }
    return onEvent;
  }
}

class MyList<T> extends MyListBase<T> {
  static Color get defCtrlBtnColor {
    if (MyGlobalStoreBase.theme_s.isLight()) {
      return MyColors_e.black_liteX;
    } else {
      return MyColors_e.write_lite;
    }
  }

  static Color get defCtrlBtnBackgroundColor {
    if (MyGlobalStoreBase.theme_s.isLight()) {
      return const Color.fromRGBO(248, 248, 248, 0.7);
    } else {
      return const Color.fromRGBO(145, 160, 180, 0.1);
    }
  }

  late final void Function()? use_onCheckAllTap;

  /// 定位按钮
  late final MyListCtrlBtn_c<void Function()?> use_onPositionTap;

  /// 添加按钮
  /// * 返回值:
  ///   * [true]:  EditSave and Update
  ///   * [false]: none
  ///   * [null]:  Exit and Update
  late final MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function()?>
      use_onAddTap;

  /// 移除按钮
  late final Future<MyListCtrlBehavior_e?> Function()? use_onRemoveTap;

  /// * 点击移除按钮后，如果有选中列表，将会自动处理
  ///   * 然后进行提示 [onRemoveDoItemTip]，
  ///   * 最后执行函数 [onRemoveDo]
  /// * 当指定 [onRemoveTap] 时，该函数无效
  late final String Function(T item, int index)? use_onRemoveDoItemTip;
  late final MyListCtrlBtn_c<
          Future<MyListCtrlBehavior_e?> Function(List<int>?, List<T>?)?>
      use_onRemoveDo;

  /// 构造更多功能列表的处理函数
  /// * 如果 [onMenuTap] 不为 null，则将显示 更多功能按钮
  /// * 用户点击更多功能按钮后，将判断是否正在编辑状态：
  ///   * 是，则将编辑状态的基本功能列表传入
  ///   * 否，则将非编辑状态的基本功能列表传入
  /// * 经过 [onMenuTap] 处理返回 功能列表
  ///   * 如果返回null，则不显示功能列表
  ///   * 如果返回非null，则显示功能列表弹窗
  late final Future<List<MySettingListItemData_c>?> Function(
    List<MySettingListItemData_c> menuListBase,
    bool isEdit,
  )? use_onMenuTap;

  // [isShow, onTap]
  late final MyListCtrlBtn_c<Future<bool> Function()?> use_onEditOpen;

  late final MyListCtrlBtn_c<
          Future<bool> Function(
            List<T> list,
            bool isChange,
          )?>

      /// 编辑后保存事件
      use_onEditSave;

  final String? removeTipTitle;
  final bool showBtnTipCount;
  final saveIsLoading = Objxx_c<MyRxObj_c<bool>?>(null);
  final addIsLoading = Objxx_c<MyRxObj_c<bool>?>(null);
  final String? positionBtnTitle;

  double get floatHeaderBarHeight => 120.r;

  MyList(
    super.controller, {
    super.key,
    super.isFixedSize,
    super.shrinkWrap,
    super.physics,
    super.padding,
    super.enableCheck,
    super.enableDrop,
    this.removeTipTitle,
    this.positionBtnTitle,
    MyRxObj_c<bool>? saveIsLoading,
    MyRxObj_c<bool>? addIsLoading,
    this.showBtnTipCount = true,
  }) {
    if (null != saveIsLoading) {
      this.saveIsLoading.value = saveIsLoading;
    } else if (null != use_onEditSave.onTap &&
        null == this.saveIsLoading.value) {
      // 有保存操作，但未指定 [saveIsLoading.value]，则自动初始化
      this.saveIsLoading.value = MyRxObj_c(false);
    }
    if (null != addIsLoading) {
      this.addIsLoading.value = addIsLoading;
    } else if (null != use_onAddTap.onTap && null == this.addIsLoading.value) {
      this.addIsLoading.value = MyRxObj_c(false);
    }
  }

  /// [onMenuTap] 的默认值
  static Future<List<MySettingListItemData_c>?> defOnMenuTap(
    List<MySettingListItemData_c> menuListBase,
    bool isEdit,
  ) async {
    return menuListBase;
  }

  static List<MySettingListItemData_c> buildMenuListBase_union<T>(
    MyList<T> mylist,
    bool isEdit,
    String? onRemoveTipTitle,
  ) {
    return [
      if (MyListCtrlBtnState_e.Hide != mylist.use_onAddTap.state)
        MySettingListItemData_c(
          leaderSvgImg: MySvgImgName_e.addition,
          infoMain: "添加",
          infoCross: "新的不来，旧的不去",
          action: const MySimpleBtn_pointRight(),
          isInfoMainLight:
              (MyListCtrlBtnState_e.Disable != mylist.use_onAddTap.state),
          onTap: (MyListCtrlBtnState_e.Disable != mylist.use_onAddTap.state)
              ? (ctrl, item, index) {
                  MyRoute_c.back();
                  mylist.onAddTapDo();
                }
              : null,
        ),
      if ((null != mylist.use_onRemoveTap ||
          MyListCtrlBtnState_e.Hide != mylist.use_onRemoveDo.state))
        MySettingListItemData_c(
          leaderSvgName: MySvgNames_e.subtract,
          infoMain: onRemoveTipTitle ?? "删除",
          infoCross: "旧的不去，新的不来",
          action: const MySimpleBtn_pointRight(),
          isInfoMainLight:
              (MyListCtrlBtnState_e.Disable != mylist.use_onRemoveDo.state),
          onTap: (MyListCtrlBtnState_e.Disable != mylist.use_onRemoveDo.state)
              ? (ctrl, item, index) {
                  mylist.controller.ensureEditOpen();
                  MyRoute_c.back();
                  mylist.onRemoveTapDo();
                }
              : null,
        ),
      if (mylist.enableDrop)
        MySettingListItemData_c(
          leaderSvgName: MySvgNames_e.top,
          infoMain: "移动到列表顶部",
          infoCross: "欲穷千里目，更上一层楼",
          onTap: (p0, p1, p2) {
            MyRoute_c.back();
            mylist.controller.ensureEditOpen();
            final checklist = mylist.controller.checkList;
            if (checklist.isEmpty) {
              MyPopup.showEasyToast("请选择要移动的歌曲");
              return;
            }
            MyListController.autoSave(
              mylist.controller,
              () {
                // 先收集选中歌曲，保持选中顺序
                final selectList = <T>[];
                for (final item in checklist) {
                  selectList.add(mylist.controller.list[item]);
                }
                // 重排序，避免后续修改影响了 checklist 中 index 的指向，然后移除
                checklist.sort((x, y) {
                  if (x < y) {
                    return -1;
                  } else if (x > y) {
                    return 1;
                  } else {
                    return 0;
                  }
                });
                for (var i = checklist.length; i-- > 0;) {
                  mylist.controller.list.removeAt(checklist[i]);
                }
                // 重新添加进去
                selectList.addAll(mylist.controller.list);
                mylist.controller.update_list(selectList, doUpdate: false);
                return MyListCtrlBehavior_e.SaveAndUpdate;
              },
            );
          },
        ),
      if (mylist.enableDrop)
        MySettingListItemData_c(
          leaderSvgName: MySvgNames_e.bottom,
          infoMain: "移动到列表底部",
          infoCross: "飞流直下三千尺，疑是银河落九天",
          onTap: (p0, p1, p2) {
            MyRoute_c.back();
            mylist.controller.ensureEditOpen();
            final checklist = mylist.controller.checkList;
            if (checklist.isEmpty) {
              MyPopup.showEasyToast("请选择要移动的歌曲");
              return;
            }
            MyListController.autoSave(
              mylist.controller,
              () {
                // 先收集选中歌曲，保持选中顺序
                final selectList = <T>[];
                for (final item in checklist) {
                  selectList.add(mylist.controller.list[item]);
                }
                // 重排序，避免后续修改影响了 checklist 中 index 的指向，然后移除
                checklist.sort((x, y) {
                  if (x < y) {
                    return -1;
                  } else if (x > y) {
                    return 1;
                  } else {
                    return 0;
                  }
                });
                for (var i = checklist.length; i-- > 0;) {
                  mylist.controller.list.removeAt(checklist[i]);
                }
                // 重新添加进去
                mylist.controller.list.addAll(selectList);
                return MyListCtrlBehavior_e.SaveAndUpdate;
              },
            );
          },
        ),
    ];
  }

  static List<Widget>? buildMenuListBase_ScrollLevelList<T>(
    MyList<T> mylist,
  ) {
    final bool enableScrollLevel = (mylist.controller.list.length > 100);
    if (enableScrollLevel) {
      final scrollLevelList = <Widget>[];
      final list = mylist.controller.list;
      // 分级粒度
      final int level = (list.length ~/ 600 + 1) * 100;
      // 分级数量
      final int maxNum = (list.length < 600 * 3) ? 5 : (list.length ~/ level);
      for (int i = 0; i < maxNum; ++i) {
        final num = level * (i + 1);
        if (num >= list.length) {
          break;
        }
        scrollLevelList.add(Padding(
          padding: const MyEdgeInsets.only(left: 30, right: 30),
          child: MyBtn(
            text: num.toString(),
            isInContentBlock: true,
            onTap: () {
              mylist.controller.scrollToIndex(
                num,
                useAnimatedType: MyAnimationUseType_e.Disable,
              );
              MyRoute_c.back();
            },
          ),
        ));
      }
      return scrollLevelList;
    }
    return null;
  }

  static List<MySettingListItemData_c> buildMenuListBase_normal<T>(
    MyList<T> mylist,
  ) {
    final scrollLevelList = buildMenuListBase_ScrollLevelList(mylist);
    return <MySettingListItemData_c>[
      if (MyListCtrlBtnState_e.Hide != mylist.use_onEditOpen.state)
        MySettingListItemData_c(
          leaderSvgImg: MySvgImgName_e.multi,
          infoMain: "多选 | 修改",
          isInfoMainLight:
              (MyListCtrlBtnState_e.Disable != mylist.use_onEditOpen.state),
          onTap: (ctrl, item, index) {
            MyRoute_c.back();
            mylist.onEditOpenDo();
          },
        ),
      MySettingListItemData_c(
        leaderSvgImg: MySvgImgName_e.up,
        infoMain: "滚动回顶部",
        infoCross: "回到梦开始的地方，但有些东西回不去了",
        onTap: (ctrl, item, index) {
          MyRoute_c.back();
          mylist.onScrollToTopDo();
        },
      ),
      if (null != scrollLevelList)
        MySettingListItemData_c(
          leaderSvgImg: MySvgImgName_e.target,
          infoMain: "滚动到",
          action: Expanded(
            flex: 2,
            child: MySizedBox(
              height: 200,
              child: MyScrollView(
                children: scrollLevelList,
              ),
            ),
          ),
        ),
      if (null != mylist.positionBtnTitle)
        MySettingListItemData_c(
          leaderSvgImg: MySvgImgName_e.target,
          infoMain: mylist.positionBtnTitle!,
          onTap: (ctrl, item, index) {
            MyRoute_c.back();
            mylist.onScrollToPostionDo();
          },
        ),
      MySettingListItemData_c(
        leaderSvgImg: MySvgImgName_e.down,
        infoMain: "滚动到底部",
        infoCross: "或许那里有新风景",
        onTap: (ctrl, item, index) {
          MyRoute_c.back();
          mylist.onScrollToDownDo();
        },
      ),
    ];
  }

  static List<MySettingListItemData_c> buildMenuListBase_editing<T>(
    MyList<T> mylist,
  ) {
    final scrollLevelList = buildMenuListBase_ScrollLevelList(mylist);
    return <MySettingListItemData_c>[
      if (MyListCtrlBtnState_e.Hide != mylist.use_onEditSave.state)
        MySettingListItemData_c(
          leaderSvgName: MySvgNames_e.right,
          infoMain: "完成修改",
          isInfoMainLight:
              (MyListCtrlBtnState_e.Disable != mylist.use_onEditSave.state),
          onTap: (ctrl, item, index) {
            MyRoute_c.back();
            mylist.onEditSaveDo();
          },
        ),
      MySettingListItemData_c(
        leaderSvgImg: MySvgImgName_e.up,
        infoMain: "滚动回顶部",
        infoCross: "回到梦开始的地方，但有些东西回不去了",
        onTap: (ctrl, item, index) {
          MyRoute_c.back();
          mylist.onScrollToTopDo();
        },
      ),
      if (null != scrollLevelList)
        MySettingListItemData_c(
          leaderSvgImg: MySvgImgName_e.target,
          infoMain: "滚动到",
          action: Expanded(
            flex: 2,
            child: MySizedBox(
              height: 200,
              child: MyScrollView(
                children: scrollLevelList,
              ),
            ),
          ),
        ),
      MySettingListItemData_c(
        leaderSvgImg: MySvgImgName_e.down,
        infoMain: "滚动到底部",
        infoCross: "或许那里有新风景",
        onTap: (ctrl, item, index) {
          MyRoute_c.back();
          mylist.onScrollToDownDo();
        },
      ),
    ];
  }

  static Widget buildCtrlBtn({
    required Widget child,
  }) {
    return Padding(
      padding: const MyEdgeInsets.only(
        left: 5,
        right: 5,
      ),
      child: child,
    );
  }

  static Widget buildCtrlTextBtn({
    required Widget child,
  }) {
    return Padding(
      padding: const MyEdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: child,
    );
  }

  Future<T1> saveLoadingFun<T1>(Future<T1> Function() doFun) async {
    saveIsLoading.value?.value = true;
    final data = await doFun.call();
    saveIsLoading.value?.value = false;
    return data;
  }

  Future<void> onEditSaveDo() async {
    final rebool = await saveLoadingFun(() => controller.editSave(
          onEditSave: use_onEditSave.onTap,
        ));
    if (false == rebool) {
      // 当 editSave 失败时，它没有update，因此需要手动执行
      controller.update();
      await MyPopup.showAlert(
        "保存失败",
        textCancel: "退出修改",
        textConfirm: " 重试 ",
        onConfirm: () {
          MyRoute_c.back();
          onEditSaveDo();
        },
        onCancel: () {
          MyRoute_c.back();
          controller.editExit();
        },
      );
    }
  }

  Future<MyListCtrlBehavior_e?> onAddTapDo() async {
    return MyListController.autoSave(
      controller,
      () => use_onAddTap.onTap?.call(),
    );
  }

  Future<MyListCtrlBehavior_e?> onRemoveTapDo() async {
    if (null != use_onRemoveTap) {
      // 指定了onRemoveTap
      return MyListController.autoSave(controller, use_onRemoveTap!);
    } else if (null != use_onRemoveDo.onTap) {
      var checkList = controller.checkList;
      var checklen = checkList.length;
      if (checklen > 0) {
        var tipNameStr = "", list = controller.list;
        if (null != use_onRemoveDoItemTip) {
          // 构造删除提示
          for (var i = 0; i < checklen; ++i) {
            tipNameStr +=
                "${i + 1}. ${use_onRemoveDoItemTip!(list[checkList[i]], checkList[i])}\n";
          }
        }
        MyListCtrlBehavior_e? rebehavior;
        await MyPopup.showAlert(
          "${removeTipTitle ?? "确认删除?"}（$checklen）",
          contentStr: tipNameStr,
          onConfirmAsync: () async {
            // 确认删除
            //先将checkList存的下标排序(从小到大)
            checkList.sort((x, y) {
              if (x < y) {
                return -1;
              } else if (x > y) {
                return 1;
              } else {
                return 0;
              }
            });
            rebehavior = await use_onRemoveDo.onTap!.call(checkList, null);
            MyRoute_c.back();
          },
        );
        return MyListController.autoSave(controller, () => rebehavior);
      } else {
        controller.ensureEditOpen();
        MyPopup.showEasyToast("请选择希望删除的列表项");
      }
    }
    return null;
  }

  void onMenuTapDo() async {
    if (null == use_onMenuTap) {
      return;
    }
    List<MySettingListItemData_c>? relist = MyList.buildMenuListBase_union(
      this,
      controller.isEdit.value,
      removeTipTitle,
    );
    if (controller.isEdit.value) {
      relist.addAll(MyList.buildMenuListBase_editing<T>(this));
      // 编辑状态
      relist = await use_onMenuTap!(
        relist,
        controller.isEdit.value,
      );
    } else {
      relist.addAll(MyList.buildMenuListBase_normal<T>(this));
      // 非编辑状态
      relist = await use_onMenuTap!(
        relist,
        controller.isEdit.value,
      );
    }
    if (null != relist) {
      controller.menuCtrl.update_list(
        relist,
        doUpdate: false,
      );
      MyPopup.showSelect(
        title: "更多",
        controller: controller.menuCtrl,
      );
    }
  }

  Future<bool> onEditOpenDo() async {
    if (false != await use_onEditOpen.onTap?.call()) {
      controller.editOpen();
      return true;
    }
    return false;
  }

  void onScrollToTopDo() {
    // 当没有下拉刷新时启用回弹
    controller.scrollToTop(
      bounce: (null == use_onReflush),
    );
  }

  void onScrollToPostionDo() {
    return use_onPositionTap.onTap?.call();
  }

  void onScrollToDownDo() {
    controller.scrollToEnd(
      bounce: (null == use_onLoadMore),
    );
  }

  Widget? buildControlContent() {
    return null;
  }

  Widget? buildBtnScrollToTop() {
    return MyList.buildCtrlBtn(
      child: MyBtn.simple(
        svgName: MySvgNames_e.doubleUp,
        onTap: onScrollToTopDo,
      ),
    );
  }

  Widget? buildBtnScrollToFocus() {
    if (MyListCtrlBtnState_e.Hide != use_onPositionTap.state) {
      return MyList.buildCtrlBtn(
        child: MyBtn.simple(
          svgName: MySvgNames_e.dotCircle,
          onTap: onScrollToPostionDo,
        ),
      );
    }
    return null;
  }

  Widget? buildBtnAdd() {
    if (MyListCtrlBtnState_e.Hide != use_onAddTap.state) {
      return MyList.buildCtrlBtn(
        child: MyBtn.loading(
          shadow: false,
          isLoading: addIsLoading.value,
          onAsyncTap: (MyListCtrlBtnState_e.Disable != use_onAddTap.state)
              ? onAddTapDo
              : null,
          svgName: MySvgNames_e.add_circle_l,
        ),
      );
    }
    return null;
  }

  Widget? buildBtnSub() {
    if (null == use_onRemoveTap &&
        MyListCtrlBtnState_e.Hide == use_onRemoveDo.state) {
      return null;
    }
    return MyList.buildCtrlTextBtn(
      child: MyBtn(
        onTap: (null != use_onRemoveTap ||
                MyListCtrlBtnState_e.Disable != use_onRemoveDo.state)
            ? onRemoveTapDo
            : null,
        text: (null != removeTipTitle)
            ? (removeTipTitle!.length <= 2)
                ? " $removeTipTitle "
                : removeTipTitle
            : " 删除 ",
      ),
    );
  }

  Widget? buildBtnSave() {
    if (MyListCtrlBtnState_e.Hide != use_onEditSave.state) {
      return MyList.buildCtrlTextBtn(
        child: MyBtn.loading(
          isLoading: saveIsLoading.value,
          onAsyncTap: (MyListCtrlBtnState_e.Disable != use_onEditSave.state)
              ? onEditSaveDo
              : null,
          text: " 完成 ",
          selected: controller.isEdit_change,
        ),
      );
    }
    return null;
  }

  Widget? buildBtnAllCheck() {
    if (false == enableCheck) {
      return null;
    }
    final isAllCheck = (controller.checkList.isNotEmpty &&
        controller.checkList.length == controller.list.length);
    return MyList.buildCtrlTextBtn(
      child: MyBtn(
        text: isAllCheck ? "取消全选" : " 全选 ",
        selected: isAllCheck,
        onTap: use_onCheckAllTap ??
            () {
              if (controller.checkList.length == controller.list.length) {
                controller.checkList.length = 0;
                controller.update();
              } else {
                controller.checkAll();
              }
            },
      ),
    );
  }

  Widget? buildBtnEditOpen() {
    if (MyListCtrlBtnState_e.Hide != use_onEditOpen.state) {
      return MyList.buildCtrlBtn(
        child: (null == saveIsLoading.value)
            ? MyBtn.simple(
                svgName: MySvgNames_e.list2,
                onTap: (MyListCtrlBtnState_e.Disable != use_onEditOpen.state)
                    ? onEditOpenDo
                    : null,
              )
            : MyBtn.loading(
                isLoading: saveIsLoading.value,
                shadow: false,
                svgName: MySvgNames_e.list2,
                onAsyncTap:
                    (MyListCtrlBtnState_e.Disable != use_onEditOpen.state)
                        ? () async => onEditOpenDo.call()
                        : null,
              ),
      );
    }
    return null;
  }

  Widget? buildBtnTextMenu() {
    return MyList.buildCtrlTextBtn(
      child: MyBtn(
        onTap: (null != use_onMenuTap) ? onMenuTapDo : null,
        text: " 更多 ",
      ),
    );
  }

  Widget? buildBtnMenu() {
    return AnimatedRotation(
      turns: (controller.isEdit.value) ? 0.25 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: MyList.buildCtrlBtn(
        child: MyBtn.simple(
          onTap: (null != use_onMenuTap) ? onMenuTapDo : null,
          svgName: MySvgNames_e.menu,
        ),
      ),
    );
  }

  /// 构造列表控制栏的左侧附加栏
  List<Widget>? buildBtnLeftCtrlAppend() {
    return null;
  }

  /// 构造列表控制栏的右侧附加栏
  List<Widget>? buildBtnRightCtrlAppend() {
    return null;
  }

  Widget buildBtnTipCount() {
    return MyList.buildCtrlBtn(
      child: MyTextMain(
        (controller.isEdit.value && controller.checkList.isNotEmpty)
            ? "${controller.checkList.length}/${controller.list.length}"
            : controller.list.length.toString(),
        style: const MyTextMainStyle(
          rFontSize: 36,
          fontWeight: MyTextCross.defFontWeight,
        ),
      ),
    );
  }

  static Widget s_buildBtnContentBlock(
    Widget child, {
    EdgeInsetsGeometry? margin,
  }) {
    return MySettingContentBlock(
      width: null,
      height: double.infinity,
      margin: margin ?? const MyEdgeInsets.only(top: 15, bottom: 15),
      padding: const MyEdgeInsets.only(left: 10, right: 10),
      backgroundColor: MyList.defCtrlBtnBackgroundColor,
      borderRadius: MyBorderRadius.circularRInt(20),
      child: child,
    );
  }

  /// 构建 控制按钮栏
  Widget buildTopControlBar() {
    controller.onEditSaveClick = onEditSaveDo;
    controller.onAddClick = onAddTapDo;
    final myBtnScrollToTop = buildBtnScrollToTop();
    final myBtnScrollToFocus = buildBtnScrollToFocus();
    final myBtnEditOpen = buildBtnEditOpen();
    final myBtnAdd = buildBtnAdd();
    final myBtnSub = buildBtnSub();
    return GetBuilder(
      init: controller,
      global: false,
      builder: (_) {
        final myControlContent = buildControlContent();
        final myBtnSave = buildBtnSave();
        final myBtnAllCheck = buildBtnAllCheck();
        final myBtnMenu = buildBtnMenu();
        final myBtnLeftAppend = buildBtnLeftCtrlAppend();
        final myBtnRightAppend = buildBtnRightCtrlAppend();
        final rowMain = Row(
          children: [
            // 左按钮栏
            s_buildBtnContentBlock(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 返回顶部按钮
                  if (null != myBtnScrollToTop) myBtnScrollToTop,
                  // 定位按钮
                  if (null != myBtnScrollToFocus) myBtnScrollToFocus,
                  // 附加栏
                  if (null != myBtnLeftAppend) ...myBtnLeftAppend,
                  if (showBtnTipCount) buildBtnTipCount(),
                ],
              ),
              margin: const MyEdgeInsets.only(top: 15, bottom: 15, right: 15),
            ),
            Expanded(
              child: (null != myControlContent)
                  ? myControlContent
                  : const SizedBox(),
            ),
            // 右按钮栏
            MyAnimatedSimpleBuilder(
              child: (controller.isEdit.value)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      key: ValueKey(controller.isEdit.value),
                      children: (null != myBtnSave)
                          // 确定保存
                          ? [
                              if (null != myBtnRightAppend) ...myBtnRightAppend,
                              myBtnSave,
                            ]
                          : [
                              if (null != myBtnRightAppend) ...myBtnRightAppend,
                              if (null != myBtnSub) myBtnSub,
                              // 多选
                              if (null != myBtnAllCheck) myBtnAllCheck,
                            ],
                    )
                  : (null != myBtnAdd || null != myBtnEditOpen)
                      ? s_buildBtnContentBlock(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            key: ValueKey(controller.isEdit),
                            children: [
                              if (null != myBtnRightAppend) ...myBtnRightAppend,
                              // 添加
                              if (null != myBtnAdd) myBtnAdd,
                              // 编辑
                              if (null != myBtnEditOpen) myBtnEditOpen,
                            ],
                          ),
                        )
                      : const SizedBox(),
              animatedBuilder: (child) {
                return AnimatedSwitcher(
                  key: const ValueKey("Switcher"),
                  reverseDuration: Duration.zero,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                );
              },
            ),
            // 更多功能按钮
            if (null != myBtnMenu) myBtnMenu,
          ],
        );
        // 编辑状态
        return MySizedBox(
          height: 140,
          child: rowMain,
        );
      },
    );
  }

  Widget builBottomControlBar() {
    final myBtnSub = buildBtnSub();
    final myBtnSave = buildBtnSave();
    final myBtnMenu = buildBtnTextMenu();
    return GetBuilder(
      init: controller,
      global: false,
      builder: (_) {
        final myBtnAllCheck = buildBtnAllCheck();
        if (null == myBtnSave ||
            false == controller.isEdit.value ||
            (null == myBtnSub && null == myBtnAllCheck)) {
          return const SizedBox();
        }
        return MySizedBox(
          height: 180,
          width: double.infinity,
          child: MyScrollView(
            physics: MyListBase.allBouncingScrollPhysics,
            children: [
              if (null != myBtnSub) myBtnSub,
              // 多选
              if (null != myBtnAllCheck) myBtnAllCheck,
              if (null != myBtnMenu) myBtnMenu,
            ],
          ),
        );
      },
    );
  }

  Widget buildListBody(BuildContext context) {
    return super.build(context);
  }

  @override
  void initFunction() {
    super.initFunction();
    use_onCheckAllTap = onCheckAllTapFun();
    use_onPositionTap = onPositionTapFun();
    use_onAddTap = onAddTapFun();
    use_onRemoveTap = onRemoveTapFun();
    use_onRemoveDoItemTip = onRemoveDoItemTipFun();
    use_onRemoveDo = onRemoveDoFun();
    use_onMenuTap = onMenuTapFun();
    use_onEditOpen = onEditOpenFun();
    use_onEditSave = onEditSaveFun();
  }

  @override
  void Function(T, int)? onLongPressFun() {
    return (item, index) async {
      if (MyListCtrlBtnState_e.Show == use_onEditOpen.state) {
        if (false != await use_onEditOpen.onTap?.call()) {
          controller.editOpen();
          HapticFeedback.vibrate();
        }
      }
    };
  }

  @override
  void Function(T, int)? onItemCheckFun() {
    return (item, index) {
      if (controller.checkList.remove(index) == false) {
        //若移除失败，即不存在
        controller.checkList.add(index);
      }
      HapticFeedback.selectionClick();
    };
  }

  void Function()? onCheckAllTapFun() {
    return null;
  }

  /// 定位按钮
  MyListCtrlBtn_c<void Function()?> onPositionTapFun() {
    return const MyListCtrlBtn_c.hide();
  }

  MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function()?> onAddTapFun() {
    return const MyListCtrlBtn_c.hide();
  }

  Future<MyListCtrlBehavior_e?> Function()? onRemoveTapFun() {
    return null;
  }

  String Function(T item, int index)? onRemoveDoItemTipFun() {
    return null;
  }

  MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function(List<int>?, List<T>?)?>
      onRemoveDoFun() {
    return const MyListCtrlBtn_c.hide();
  }

  /// 构造更多功能列表的处理函数
  /// * 如果 [onMenuTap] 不为 null，则将显示 更多功能按钮
  /// * 用户点击更多功能按钮后，将判断是否正在编辑状态：
  ///   * 是，则将编辑状态的基本功能列表传入
  ///   * 否，则将非编辑状态的基本功能列表传入
  /// * 经过 [onMenuTap] 处理返回 功能列表
  ///   * 如果返回null，则不显示功能列表
  ///   * 如果返回非null，则显示功能列表弹窗
  Future<List<MySettingListItemData_c>?> Function(
    List<MySettingListItemData_c> menuListBase,
    bool isEdit,
  )? onMenuTapFun() {
    return MyList.defOnMenuTap;
  }

  // [isShow, onTap]
  MyListCtrlBtn_c<Future<bool> Function()?> onEditOpenFun() {
    return const MyListCtrlBtn_c(onTap: null);
  }

  /// 编辑后保存事件
  MyListCtrlBtn_c<
      Future<bool> Function(
        List<T> list,
        bool isChange,
      )?> onEditSaveFun() {
    return MyListCtrlBtn_c<
        Future<bool> Function(
          List<T> list,
          bool isChange,
        )?>(onTap: null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Padding(
          padding: const MyEdgeInsets.only(left: 30, right: 30),
          child: buildTopControlBar(),
        ),
        (false == shrinkWrap)
            ? Expanded(
                // 列表内容
                child: buildListBody(context),
              )
            : buildListBody(context),
        builBottomControlBar(),
      ],
    );
  }
}

class MyListBaseWidget<T> extends MyListBase<T> {
  final Widget Function()? emptyBuilder;
  final Widget Function()? headerBuilder;

  /// 列表项信息
  final Widget Function(T item, int index) itemInfo;

  /// 列表项前置
  final Widget? Function(T item, int index)? itemLeading,

      /// 列表项标签
      itemTags,

      /// 列表项后置
      itemActions;

  final bool Function(T item, int index)? selected;
  final void Function(T item, int index)? onItemCheck;
  final void Function(T item, int index)? onItemTap;
  final void Function(T item, int index)? onLongPress;
  final MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?>? onItemMenu;
  final Future<bool> Function()? onReflush;
  final Future<IndicatorResult> Function()? onLoadMore;

  MyListBaseWidget(
    super.controller, {
    required this.itemInfo,
    super.key,
    super.itemCount,
    super.physics,
    super.isFixedSize,
    super.shrinkWrap,
    super.padding,
    super.doInitFunction,
    super.enableCheck,
    super.enableDrop,
    this.emptyBuilder,
    this.headerBuilder,
    this.selected,
    this.onItemCheck,
    this.onItemTap,
    this.onLongPress,
    this.onItemMenu,
    this.onReflush,
    this.onLoadMore,
    this.itemLeading,
    this.itemTags,
    this.itemActions,
  });

  @override
  Widget? buildItemLeading(T item, int index) {
    return itemLeading?.call(item, index);
  }

  @override
  Widget? buildItemInfo(T item, int index) {
    return itemInfo.call(item, index);
  }

  @override
  Widget? buildItemTag(T item, int index) {
    return itemTags?.call(item, index);
  }

  @override
  Widget? buildItemActions(T item, int index) {
    return itemActions?.call(item, index);
  }

  @override
  Widget? buildEmpty() {
    return emptyBuilder?.call();
  }

  @override
  Widget? buildHeader() {
    return headerBuilder?.call();
  }

  @override
  void Function(T item, int index)? onItemCheckFun() {
    return onItemCheck;
  }

  @override
  bool Function(T item, int index)? selectedFun() {
    return selected;
  }

  @override
  void Function(T item, int index)? onItemTapFun() {
    return onItemTap;
  }

  @override
  void Function(T item, int index)? onLongPressFun() {
    return onLongPress;
  }

  @override
  MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?> onItemMenuFun() {
    return (onItemMenu ?? super.onItemMenuFun());
  }

  @override
  Future<bool> Function()? onReflushFun() {
    return onReflush;
  }

  @override
  Future<IndicatorResult> Function()? onLoadMoreFun() {
    return onLoadMore;
  }
}

enum MyListCtrlBehavior_e {
  SaveAndUpdate,
  ExitAndUpdate,
  OpenAndUpdate,
  ClearCheckAndUpdate,
  Update,
  None,
}

class MyListWidget<T> extends MyList<T> {
  final bool Function(T item, int index)? selected;
  final void Function(T item, int index)? onItemTap;
  final MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?>? onItemMenu;
  final MyListEvent_c<Future<bool> Function()?>? onReflush;
  final MyListEvent_c<Future<IndicatorResult> Function()?>? onLoadMore;
  final MyListCtrlBtn_c<void Function()?>? onPositionTap;
  final MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function()?>? onAddTap;
  final Future<MyListCtrlBehavior_e?> Function()? onRemoveTap;
  final String Function(T item, int index)? onRemoveDoItemTip;
  final MyListCtrlBtn_c<
          Future<MyListCtrlBehavior_e?> Function(List<int>?, List<T>?)?>?
      onRemoveDo;
  final Future<List<MySettingListItemData_c>?> Function(
    List<MySettingListItemData_c> menuListBase,
    bool isEdit,
  )? onMenuTap;
  final MyListCtrlBtn_c<Future<bool> Function()?>? onEditOpen;
  final MyListCtrlBtn_c<
      Future<bool> Function(
        List<T> list,
        bool isChange,
      )?>? onEditSave;

  /// 列表项信息
  final Widget Function(T item, int index) itemInfo;

  /// 列表项前置
  final Widget Function(T item, int index)? itemLeading,

      /// 列表项标签
      itemTags,

      /// 列表项后置
      itemActions;

  final Widget Function(bool isEdit)? ctrlBarBuilder;
  final Widget Function()? emptyBuilder;
  final Widget? Function()? headerBuilder;

  MyListWidget(
    super.controller, {
    required this.itemInfo,
    super.key,
    super.positionBtnTitle,
    super.isFixedSize,
    super.shrinkWrap,
    super.physics,
    super.padding,
    super.removeTipTitle,
    super.enableCheck,
    super.enableDrop,
    super.showBtnTipCount,
    super.saveIsLoading,
    this.headerBuilder,
    this.emptyBuilder,
    this.itemLeading,
    this.itemTags,
    this.itemActions,
    this.ctrlBarBuilder,
    this.selected,
    this.onItemTap,
    this.onItemMenu,
    this.onReflush,
    this.onLoadMore,
    this.onPositionTap,
    this.onAddTap,
    this.onRemoveTap,
    this.onRemoveDoItemTip,
    this.onRemoveDo,
    this.onEditOpen,
    this.onEditSave,
    this.onMenuTap,
  });

  @override
  Widget? buildControlContent() {
    return ctrlBarBuilder?.call(controller.isEdit.value);
  }

  @override
  Widget? buildItemLeading(T item, int index) {
    return itemLeading?.call(item, index);
  }

  @override
  Widget? buildItemInfo(T item, int index) {
    return itemInfo.call(item, index);
  }

  @override
  Widget? buildItemTag(T item, int index) {
    return itemTags?.call(item, index);
  }

  @override
  Widget? buildItemActions(T item, int index) {
    return itemActions?.call(item, index);
  }

  @override
  Widget? buildEmpty() {
    return emptyBuilder?.call();
  }

  @override
  Widget? buildHeader() {
    return headerBuilder?.call();
  }

  @override
  bool Function(T item, int index)? selectedFun() {
    return selected;
  }

  @override
  void Function(T item, int index)? onItemTapFun() {
    return onItemTap;
  }

  @override
  MyListCtrlBtn_c<
      Future<(String?, String?, List<MySettingListItemData_c>?)> Function(
        T item,
        int index,
        List<MySettingListItemData_c> list,
      )?> onItemMenuFun() {
    return (onItemMenu ?? super.onItemMenuFun());
  }

  @override
  Future<bool> Function()? onReflushFun() {
    if (MyListEventState_e.Enable == onReflush?.state) {
      return onReflush?.onEvent;
    }
    return null;
  }

  @override
  Future<IndicatorResult> Function()? onLoadMoreFun() {
    if (MyListEventState_e.Enable == onLoadMore?.state) {
      return onLoadMore?.onEvent;
    }
    return null;
  }

  /// 定位按钮
  @override
  MyListCtrlBtn_c<void Function()?> onPositionTapFun() {
    return onPositionTap ?? super.onPositionTapFun();
  }

  @override
  MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function()?> onAddTapFun() {
    return onAddTap ?? super.onAddTapFun();
  }

  @override
  Future<MyListCtrlBehavior_e?> Function()? onRemoveTapFun() {
    return onRemoveTap ?? super.onRemoveTapFun();
  }

  @override
  String Function(T item, int index)? onRemoveDoItemTipFun() {
    return onRemoveDoItemTip ?? super.onRemoveDoItemTipFun();
  }

  @override
  MyListCtrlBtn_c<Future<MyListCtrlBehavior_e?> Function(List<int>?, List<T>?)?>
      onRemoveDoFun() {
    return onRemoveDo ?? super.onRemoveDoFun();
  }

  /// 构造更多功能列表的处理函数
  /// * 如果 [onMenuTap] 不为 null，则将显示 更多功能按钮
  /// * 用户点击更多功能按钮后，将判断是否正在编辑状态：
  ///   * 是，则将编辑状态的基本功能列表传入
  ///   * 否，则将非编辑状态的基本功能列表传入
  /// * 经过 [onMenuTap] 处理返回 功能列表
  ///   * 如果返回null，则不显示功能列表
  ///   * 如果返回非null，则显示功能列表弹窗
  @override
  Future<List<MySettingListItemData_c>?> Function(
    List<MySettingListItemData_c> menuListBase,
    bool isEdit,
  )? onMenuTapFun() {
    return onMenuTap ?? super.onMenuTapFun();
  }

  // [isShow, onTap]
  @override
  MyListCtrlBtn_c<Future<bool> Function()?> onEditOpenFun() {
    return onEditOpen ?? super.onEditOpenFun();
  }

  /// 编辑后保存事件
  @override
  MyListCtrlBtn_c<
      Future<bool> Function(
        List<T> list,
        bool isChange,
      )?> onEditSaveFun() {
    return onEditSave ?? super.onEditSaveFun();
  }
}
