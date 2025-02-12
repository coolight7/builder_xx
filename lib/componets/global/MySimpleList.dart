// ignore_for_file: file_names, constant_identifier_names, camel_case_types, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/manager/MyRxCtrlManager.dart';
import 'package:refreshed/refreshed.dart';
import 'package:builder_xx/componets/global/MyContentBlock.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import '/manager/MyRoute.dart';
import '/manager/MyTheme.dart';
import 'MyBtn.dart';
import 'MyList.dart';
import 'MyLoadingShimmer.dart';
import 'MySvg.dart';
import 'MySwitch.dart';
import 'MyText.dart';
import 'MyMarkdown.dart';
import 'MyPopup.dart';

class MySimpleListController<T>
    extends MyRxControllerAdapt<MySimpleListController<T>> {
  /// 是否显示全面加载动画
  bool isAllShimmer;

  List<T> list;

  MySimpleListController(
    this.list, {
    super.enableAutoDelete,
    this.isAllShimmer = false,
    super.onInitFun,
    super.onCloseFun,
  });

  void update_list(
    List<T> in_list, {
    bool doUpdate = true,
  }) {
    list = in_list;
    if (doUpdate) {
      update();
    }
  }

  void setIsAllShimmer(
    bool isable, {
    bool doUpdate = true,
  }) {
    isAllShimmer = isable;
    if (doUpdate) {
      update();
    }
  }
}

class MySimpleList<T> extends StatelessWidget {
  static double get minItemHeight => 200.r;

  final EdgeInsetsGeometry padding;
  final MySimpleListController<T> controller;
  final int? itemCount;
  final void Function(
    MySimpleListController<T> controller,
    T item,
    int index,
  )? onItemTap, onItemLongPress;
  final Widget Function(T item, int index)? itemInfo;
  final Widget Function(T item, int index, Widget child)? selectItemBuilder;
  final Widget? Function(T item, int index)? itemLeader, itemAction;
  final bool Function(T item, int index)? isSelect;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const MySimpleList(
    this.controller, {
    super.key,
    this.padding = const MyEdgeInsets.only(
      top: 50,
      bottom: 50,
      left: 30,
      right: 30,
    ),
    this.onItemTap,
    this.onItemLongPress,
    this.itemLeader,
    this.itemInfo,
    this.itemAction,
    this.itemCount,
    this.isSelect,
    this.selectItemBuilder,
    this.physics = MyListBase.allBouncingScrollPhysics,
    this.shrinkWrap = false,
  });

  Widget buildSelectItemDetail(T item, int index, Widget child) {
    if (null == selectItemBuilder) {
      return child;
    }
    return selectItemBuilder!.call(item, index, child);
  }

  Widget? buildItemLeading(T item, int index) {
    return itemLeader?.call(
      item,
      index,
    );
  }

  Widget? buildItemAction(T item, int index) {
    return itemAction?.call(item, index);
  }

  Widget? buildItem(T item, int index) {
    final itemLeaderWidget = buildItemLeading(item, index);
    final action = buildItemAction(item, index);
    Widget reChild = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MySimpleList.minItemHeight,
        ),
        child: Row(
          children: [
            if (null != itemLeaderWidget) itemLeaderWidget,
            if (null != itemInfo)
              Expanded(
                child: itemInfo!(item, index),
              ),
            if (null != action) action,
          ],
        ));
    if (true ==
        isSelect?.call(
          item,
          index,
        )) {
      reChild = buildSelectItemDetail(item, index, reChild);
    }
    if (null != onItemTap || null != onItemLongPress) {
      reChild = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onItemTap?.call(
            controller,
            item,
            index,
          ),
          onLongPress: () => onItemLongPress?.call(
            controller,
            item,
            index,
          ),
          child: reChild,
        ),
      );
    }
    return reChild;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      global: false,
      init: controller,
      builder: (ctrl) {
        if (controller.isAllShimmer) {
          return MyShimmerSimpleList(
            key: const ValueKey("MySimpleList-loading"),
            physics: physics,
            padding: padding,
            shrinkWrap: shrinkWrap,
          );
        }
        final children = <Widget>[];
        for (int index = 0; index < ctrl.list.length; ++index) {
          final child = buildItem(controller.list[index], index);
          if (null != child) {
            children.add(child);
          }
        }
        return ListView(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          children: children,
        );
      },
    );
  }
}

class MySettingListItemData_c {
  final String? leaderSvgName, leaderSvgImg;

  /// 列表项标题
  final String infoMain;

  /// 列表项说明
  String? infoCross;

  /// 尾部组件
  final Widget? action;

  final bool ignoreActionPointer;

  /// 将 [action] 显示在 [infoMain] 同行
  final bool isInfoMainAction;

  /// 是否用明显颜色显示info
  final bool isInfoMainLight;
  final void Function(
    MySimpleListController<MySettingListItemData_c> p0,
    MySettingListItemData_c p1,
    int p2,
  )? onTap;

  MySettingListItemData_c({
    this.leaderSvgName,
    this.leaderSvgImg,
    required this.infoMain,
    this.infoCross,
    this.action,
    this.onTap,
    this.ignoreActionPointer = false,
    this.isInfoMainAction = false,
    this.isInfoMainLight = true,
  });

  MySettingListItemData_c.switchBool({
    this.leaderSvgName,
    this.leaderSvgImg,
    required this.infoMain,
    this.infoCross,
    this.action,
    this.onTap,
    this.ignoreActionPointer = true,
    this.isInfoMainAction = false,
    this.isInfoMainLight = true,
  });

  static bool defIsInfoMainAction(final String? infoCross) {
    return (null != infoCross && infoCross.length > 30);
  }

  static MySettingListItemData_c
      buildSwitchBoolGetBuilder<T extends GetxController>({
    required String infoMain,
    required bool Function(T ctrl) checked,
    required void Function(T ctrl) onTap,
    bool Function(T ctrl)? loading,
    String? leaderSvgImg,
    String? leaderSvgName,
    String? infoCross,
    Object? id,
    T? init,
  }) {
    late T controller;
    return MySettingListItemData_c(
      leaderSvgImg: leaderSvgImg,
      leaderSvgName: leaderSvgName,
      infoMain: infoMain,
      infoCross: infoCross,
      isInfoMainAction: defIsInfoMainAction(infoCross),
      action: Center(
        child: GetBuilder<T>(
          id: id,
          init: init,
          global: (null == init),
          builder: (ctrl) {
            controller = ctrl;
            return MySwitchBool(
              checked: checked(ctrl),
              onTap: (inbool) => onTap(ctrl),
              loading: loading?.call(ctrl) ?? false,
            );
          },
        ),
      ),
      onTap: (p0, p1, p2) => onTap(controller),
    );
  }

  factory MySettingListItemData_c.buildSwitchBoolObx({
    required String infoMain,
    required Rx<bool> checked,
    String? leaderSvgName,
    String? infoCross,
    void Function(bool enable)? onTap,
  }) {
    return MySettingListItemData_c(
      leaderSvgName: leaderSvgName,
      infoMain: infoMain,
      infoCross: infoCross,
      isInfoMainAction: defIsInfoMainAction(infoCross),
      action: Center(
        child: Obx(() => MySwitchBool(
              checked: checked.value,
              onTap: (_) {
                checked.toggle();
                onTap?.call(checked.value);
              },
            )),
      ),
      onTap: (p0, p1, p2) {
        checked.toggle();
        onTap?.call(checked.value);
      },
    );
  }

  static MySettingListItemData_c
      buildSwitchTextGetBuilder<T extends GetxController, T1>({
    required String infoMain,
    required T1 Function(T ctrl) getValue,
    required String Function(T1 value) toName,
    required List<T1> data,
    required void Function(T ctrl, T1 value) onSelect,
    String? infoCross,
    String Function(T1 value)? toDepict,
    T1? defaultValue,
    String? popupDepict,
    String? leaderSvgName,
    String? leaderSvgImg,
    Object? builderId,
    (Widget, T) Function()? onBuildAction,
  }) {
    T? controller;
    Widget? action;
    if (null != onBuildAction) {
      (action, controller) = onBuildAction.call();
    }
    return MySettingListItemData_c(
      leaderSvgName: leaderSvgName,
      leaderSvgImg: leaderSvgImg,
      infoMain: infoMain,
      infoCross: infoCross,
      isInfoMainAction: defIsInfoMainAction(infoCross),
      action: action ??
          GetBuilder<T>(
            id: builderId,
            builder: (ctrl) {
              controller = ctrl;
              return MyTextCross(
                toName.call(
                  getValue.call(ctrl),
                ),
              );
            },
          ),
      onTap: (ctrl, item, index) async {
        if (null == controller) {
          return;
        }
        final reval = await MyPopup.showSelectSimple<T1>(
          title: infoMain,
          selectValue: getValue.call(controller!),
          defaultValue: defaultValue,
          depict: popupDepict,
          toInfoMain: toName,
          toInfoCross: toDepict,
          data: data,
        );
        if (null != reval) {
          onSelect.call(controller!, reval);
        }
      },
    );
  }

  factory MySettingListItemData_c.buildPageRoute({
    required String infoMain,
    required String routeName,
    String? leaderSvgName,
    String? leaderSvgImg,
    String? infoCross,
  }) {
    return MySettingListItemData_c(
      leaderSvgName: leaderSvgName,
      leaderSvgImg: leaderSvgImg,
      infoMain: infoMain,
      infoCross: infoCross,
      action: const MySimpleBtn_pointRight(),
      onTap: (p0, p1, p2) {
        MyRoute_c.toNamed(routeName);
      },
    );
  }
}

class MySettingList extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final MySimpleListController<MySettingListItemData_c> controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool inContent;
  final bool Function(MySettingListItemData_c item, int index)? isSelect;
  final void Function(
    MySimpleListController<MySettingListItemData_c>,
    MySettingListItemData_c,
    int,
  )? onItemLongPress;

  const MySettingList(
    this.controller, {
    required this.inContent,
    super.key,
    this.onItemLongPress,
    this.padding,
    this.isSelect,
    this.physics = MyListBase.allBouncingScrollPhysics,
    this.shrinkWrap = false,
  });

  const MySettingList.inContent(
    this.controller, {
    super.key,
    this.isSelect,
    this.onItemLongPress,
  })  : inContent = true,
        shrinkWrap = true,
        padding = EdgeInsets.zero,
        physics = const NeverScrollableScrollPhysics();

  /// 默认列表注解构建
  static Widget defInfoExplainBuilder({required String text}) {
    return Center(
      child: MyTextCross(
        text,
      ),
    );
  }

  static Widget buildItemLeadingSvg(
    String svgName,
    double size,
    int index,
  ) {
    final color = MyColors_e.getListLeadSvgColor(index);
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const MyBorderRadius(MyRadius(30)),
          ),
          child: Center(
            child: MySvg(
              size: size / 12 * 7,
              svgName: svgName,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildItemLeadSvgImg(
    String svgImg,
    double size,
    Decoration decoration,
  ) {
    return SizedBox(
      height: size,
      width: size,
      child: DecoratedBox(
        decoration: decoration,
        child: Center(
          child: MySvgImage(
            size: size / 8 * 5,
            svgName: svgImg,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    final size = 120.r;
    final svgImgStyle = BoxDecoration(
      color: (inContent
              ? theme.contentDecoration.svgInContentBackgroundColor
              : theme.contentDecoration.svgBackgroundColor) ??
          theme.backgroundColorCross,
      borderRadius: const MyBorderRadius(MyRadius(30)),
    );
    return MySimpleList(
      controller,
      isSelect: isSelect,
      physics: physics,
      padding: padding ??
          (inContent
              ? EdgeInsets.zero
              : const MyEdgeInsets.only(left: 50, right: 50)),
      shrinkWrap: shrinkWrap,
      itemLeader: (MySettingListItemData_c item, int index) {
        if (true == item.leaderSvgName?.isNotEmpty) {
          return Padding(
            padding: const MyEdgeInsets.only(right: 30),
            child: buildItemLeadingSvg(
              item.leaderSvgName!,
              size,
              index,
            ),
          );
        } else if (true == item.leaderSvgImg?.isNotEmpty) {
          return Padding(
            padding: const MyEdgeInsets.only(right: 30),
            child: Center(
              child: buildItemLeadSvgImg(
                item.leaderSvgImg!,
                size,
                svgImgStyle,
              ),
            ),
          );
        } else {
          return null;
        }
      },
      itemInfo: (MySettingListItemData_c item, int index) {
        final infoMainWidget = (item.isInfoMainLight)
            ? MyTextMain.thin(
                item.infoMain,
                textAlign: TextAlign.left,
              )
            : MyTextCross(
                item.infoMain,
                textAlign: TextAlign.left,
                style: const MyTextCrossStyle(
                  rFontSize: 50,
                ),
              );
        return Padding(
          padding: const MyEdgeInsets.only(
            top: 30,
            bottom: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item.isInfoMainAction
                  ? Row(
                      children: [
                        Expanded(
                          child: infoMainWidget,
                        ),
                        item.action ?? const SizedBox(),
                      ],
                    )
                  : Padding(
                      padding: const MyEdgeInsets.only(right: 30),
                      child: infoMainWidget,
                    ),
              if (true == item.infoCross?.isNotEmpty)
                Padding(
                  padding: item.isInfoMainAction
                      ? const MyEdgeInsets.only(
                          top: 10,
                        )
                      : const MyEdgeInsets.only(
                          top: 10,
                          right: 30,
                        ),
                  child: MyTextCross.multiLine(
                    item.infoCross!,
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
        );
      },
      itemAction: (MySettingListItemData_c item, int index) {
        // 按钮提示
        if (item.isInfoMainAction) {
          return null;
        } else {
          if (item.ignoreActionPointer) {
            return IgnorePointer(
              child: item.action,
            );
          } else {
            return item.action;
          }
        }
      },
      onItemTap: (
        MySimpleListController<MySettingListItemData_c> ctrl,
        MySettingListItemData_c item,
        int index,
      ) {
        item.onTap?.call(ctrl, item, index);
      },
      onItemLongPress: onItemLongPress,
      selectItemBuilder: (item, index, child) {
        return MySettingContentBlock(
          padding: const MyEdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.zero,
          borderRadius: const MyBorderRadius(MyRadius(30)),
          backgroundColor:
              inContent ? theme.backgroundColor : theme.backgroundColorCross,
          child: Row(
            children: [
              Container(
                height: MySimpleList.minItemHeight / 2,
                width: 16.r,
                decoration: BoxDecoration(
                  color: MyColors_e.blue_tianyi,
                  borderRadius: MyBorderRadius.circularRInt(10),
                ),
              ),
              const MySizedBox(width: 30),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class MySimpleBtn_pointRight extends StatelessWidget {
  const MySimpleBtn_pointRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MySvg(
        svgName: MySvgNames_e.pointRight,
        size: MyBtn.defSize / 2,
        color: MyGlobalStoreBase.theme_s.mytheme.btnSimpleContentColor,
      ),
    );
  }
}

class MySimpleBtn_right extends StatelessWidget {
  const MySimpleBtn_right({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MySvg(
        svgName: MySvgNames_e.right,
        size: MyBtn.defSize / 2,
        color: MyGlobalStoreBase.theme_s.mytheme.btnSimpleContentColor,
      ),
    );
  }
}

class MySimpleBtn_error extends StatelessWidget {
  const MySimpleBtn_error({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MySvg(
        svgName: MySvgNames_e.cancel,
        size: MyBtn.defSize / 2,
        color: MyGlobalStoreBase.theme_s.mytheme.btnDisableContentColor,
      ),
    );
  }
}

class MySimpleBtn_help extends StatelessWidget {
  final String title;
  final String markdown;

  const MySimpleBtn_help({
    super.key,
    required this.title,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyBtn.simple(
        svgName: MySvgNames_e.help,
        onTap: () {
          MyPopup.showBottomSheet(
            title: title,
            contentBuilder: () => MyMarkdown(data: markdown),
          );
        },
      ),
    );
  }
}

class MySimpleBtn_reflush extends StatelessWidget {
  final void Function()? onTap;

  const MySimpleBtn_reflush({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyBtn.simple(
        svgImg: MySvgImgName_e.reset,
        onTap: onTap,
      ),
    );
  }
}
