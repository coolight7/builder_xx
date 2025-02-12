// ignore_for_file: file_names, non_constant_identifier_names, camel_case_types, constant_identifier_names

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/componets/global/MyContentBlock.dart';
import 'package:builder_xx/componets/global/MyList.dart';
import 'package:builder_xx/componets/global/MyScreenUtil.dart';
import 'package:builder_xx/componets/global/MyText.dart';
import 'package:builder_xx/manager/MyOverlayManager.dart';
import 'package:builder_xx/manager/MyRoute.dart';
import 'package:builder_xx/manager/MyTheme.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'package:builder_xx/util/MyGlobalUtil.dart';
import 'package:string_util_xx/string_util_xx.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';

import 'MyBtn.dart';
import 'MyGestureDetector.dart';
import 'MyPopup.dart';
import 'MySvg.dart';

class MyIndexBarCateDateItem_c<T> {
  List<T> list;

  /// [list]在原本的列表中是否是连续存在的
  bool isContinuous;

  MyIndexBarCateDateItem_c({
    required this.list,
    required this.isContinuous,
  });
}

/// 索引指示器
/// * 用于列表快速定位
class MyIndexBar extends StatefulWidget {
  static const defCateNum = "7";
  static const defCateOther = "#";
  static const defLimitMinListNum = 7;

  /// 默认索引列表
  static final defFullTagList = s_createDefTagList().keys.toList();
  static const defSimpleTagList = [defCateNum, defCateOther];

  /// 主索引列表
  final List<String> taglist;
  final void Function(int index, String tag)? onTagTap;
  final void Function()? onTapStart;
  final void Function(int index, String tag)? onTapDone;

  /// 额外的头部索引
  final List<String>? headerTagList;

  /// 额外的底部索引
  final List<String>? footerTagList;
  final void Function(int index, String tag)? onHeaderTagTap;
  final void Function(int index, String tag)? onFooterTagTap;
  final Widget? Function(int index, String tag)? buildTagOverlay;

  /// 是否接收键盘控制
  final bool handleKeyboard;

  const MyIndexBar({
    super.key,
    required this.taglist,
    this.onTagTap,
    this.onTapStart,
    this.onTapDone,
    this.headerTagList,
    this.onHeaderTagTap,
    this.footerTagList,
    this.onFooterTagTap,
    this.buildTagOverlay,
    this.handleKeyboard = true,
  });

  static Widget s_buildDetail({
    required Widget indexBar,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        child,
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: Utilxx_c.defEmptyFunction_1,
            onVerticalDragUpdate: Utilxx_c.defEmptyFunction_1,
            onVerticalDragEnd: Utilxx_c.defEmptyFunction_1,
            onVerticalDragDown: Utilxx_c.defEmptyFunction_1,
            onVerticalDragCancel: Utilxx_c.defEmptyFunction_0,
            child: indexBar,
          ),
        ),
      ],
    );
  }

  static Map<String, MyIndexBarCateDateItem_c<T>> s_createDefTagList<T>() {
    final reData = <String, MyIndexBarCateDateItem_c<T>>{
      defCateNum: MyIndexBarCateDateItem_c(list: [], isContinuous: true),
      defCateOther: MyIndexBarCateDateItem_c(list: [], isContinuous: true),
    };
    // 添加字母集合
    for (int i = StringUtilxx_c.CODE_A; i <= StringUtilxx_c.CODE_Z; ++i) {
      reData[String.fromCharCode(i)] = MyIndexBarCateDateItem_c(
        list: [],
        isContinuous: true,
      );
    }
    // 断言类别数量
    assert(reData.length == (1 + 1 + 26));
    return reData;
  }

  static Map<String, MyIndexBarCateDateItem_c<T>> s_createTagListByWord<T>(
    List<T> datalist,
    String Function(T data) getStr, {
    bool removeEmpty = false,
  }) {
    final reData = s_createDefTagList<T>();
    // 标记分类是否已经中断/结束
    // * [true] 该分类还未添加过，或者正在连续添加中
    // * [false] 该分类已经添加过，并且已经完成连续的部分，后续若再出现属于该分类的值，
    // 则可以认为该分类的值分布是不连续的。
    final continuesMark = reData.map((key, value) {
      return MapEntry(key, true);
    });
    // 记录上一个[item]的分类
    String? previousCate;
    for (final item in datalist) {
      final str = getStr(item);
      final firstChar = StringUtilxx_c.getFirstCharPinyinFirstChar(str);
      String? itemCate;
      if (null != firstChar && firstChar.isNotEmpty) {
        final code = firstChar.codeUnitAt(0);
        if (StringUtilxx_c.isCode_num(code)) {
          // 是数字
          itemCate = defCateNum;
        } else if (StringUtilxx_c.isCode_AZaz(code)) {
          // 是字母
          itemCate = String.fromCharCode(StringUtilxx_c.toCode_AZ(code));
        }
      }
      // 属于其他字符
      itemCate ??= defCateOther;
      // 添加进分类
      reData[itemCate]?.list.add(item);
      reData[itemCate]?.isContinuous = continuesMark[itemCate] ?? false;
      if (null != previousCate && previousCate != itemCate) {
        // 当前分类和上一个[item]的分类不同
        // 标记该分类连续部分添加完成
        continuesMark[previousCate] = false;
      }
      previousCate = itemCate;
    }
    if (removeEmpty) {
      // 移除空的
      reData.removeWhere((key, value) {
        return value.list.isEmpty;
      });
    }
    return reData;
  }

  @override
  State<MyIndexBar> createState() => _MyIndexBarState();
}

enum _AutoScrollState_e {
  None,
  Up,
  Down,
}

class _MyIndexBarState extends State<MyIndexBar> {
  static const double defItemHeight = 60;
  static const defFontSize = 38;

  /// 单个触发自动滚动范围占比，一般有上下两个，因此 [defAutoScrollExtent] 需要在 [0, 1/2]
  static const defAutoScrollExtent = 1 / 4;

  late final OverlayEntry overlayEntity;
  final scrollCtrl = ScrollController();
  final widgetKey = GlobalKey<State<StatefulWidget>>();
  final showTagWidget = MyRxObj_c<bool>(false);

  /// 当前按住的下标
  final tapingIndex = MyRxObj_c<int?>(null);

  /// 合并展示
  late List<String> useTagList;

  late final tapEvent = EventxxThrottle_c<int>(
    time: const Duration(milliseconds: 300),
    fastFirstRun: true,
    dofastFirstRunEnd: true,
    onListen: handleTapEvent,
  );

  /// widget的位置和高度
  double positionY = 0, barHeight = 0;

  /// 点击位置
  double? tapPointY;

  /// 自动滚动状态
  _AutoScrollState_e autoScrollState = _AutoScrollState_e.None;

  /// 操作后自动将目标滚动居中
  Timer? scrollToCenter;

  @override
  void initState() {
    assert(defAutoScrollExtent <= 1 / 2);
    createUseTagList();
    overlayEntity = OverlayEntry(builder: (_) {
      return Obx(() {
        if (showTagWidget.value) {
          final index = tapingIndex.value;
          if (null != index) {
            if (null != widget.buildTagOverlay) {
              return widget.buildTagOverlay!.call(
                    index,
                    useTagList[index],
                  ) ??
                  const SizedBox();
            }
            return Center(
              child: MySettingContentBlock(
                height: 250.r,
                width: 250.r,
                margin: EdgeInsets.zero,
                boxShadow: MyGlobalStoreBase.theme_s.isLight()
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
                      ],
                child: MySettingContentBlock.inContent(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: MyTextMain(
                      useTagList[index],
                      style: const MyTextMainStyle(
                        rFontSize: 70,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
        return const SizedBox();
      });
    });
    Timer(const Duration(milliseconds: 100), () {
      MyOverlayManager.insert(overlayEntity);
    });
    scrollCtrl.addListener(() {
      if (useTagList.isNotEmpty && null != tapPointY) {
        final index =
            (scrollCtrl.offset + tapPointY! - positionY) ~/ defItemHeight.r;
        notifyTapIndex(
          index,
          false,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    try {
      overlayEntity.remove();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MyIndexBar oldWidget) {
    createUseTagList();
    super.didUpdateWidget(oldWidget);
  }

  void createUseTagList() {
    useTagList = [
      if (null != widget.headerTagList) ...widget.headerTagList!,
      ...widget.taglist,
      if (null != widget.footerTagList) ...widget.footerTagList!,
    ];
  }

  (String? tag, int index) getTag(
    int? index, {
    bool autoReset = false,
  }) {
    if (null == index) {
      index = 0;
    } else if (index < 0) {
      if (autoReset) {
        index = 0;
      } else {
        return (null, index);
      }
    }
    if (index < useTagList.length) {
      return (useTagList[index], index);
    } else if (autoReset && useTagList.isNotEmpty) {
      return (useTagList.last, useTagList.length - 1);
    }
    // 下标越界
    return (null, index);
  }

  void handleTapEvent(int index) {
    final (tag, _) = getTag(index);
    if (null == tag) {
      return;
    }
    do {
      int headerLength = 0;
      if (null != widget.headerTagList) {
        if (index < widget.headerTagList!.length) {
          widget.onHeaderTagTap?.call(index, tag);
          break;
        } else {
          headerLength = widget.headerTagList!.length;
        }
      }
      index -= headerLength;
      if (index < widget.taglist.length) {
        widget.onTagTap?.call(index, tag);
        break;
      }
      index -= widget.taglist.length;
      if (null != widget.footerTagList &&
          index < widget.footerTagList!.length) {
        widget.onFooterTagTap?.call(index, tag);
        break;
      }
    } while (false);
  }

  bool notifyTapIndex(int index, bool isMust) {
    String? tag;
    (tag, index) = getTag(index, autoReset: true);
    if (null != tag && (isMust || tapingIndex.value != index)) {
      tapingIndex.value = index;
      tapEvent.notify(index);
      HapticFeedback.selectionClick();
      return true;
    }
    return false;
  }

  void setAutoScroll(_AutoScrollState_e state) {
    if (state == autoScrollState) {
      return;
    }
    autoScrollState = state;
    final scrollOffset = scrollCtrl.offset;
    switch (state) {
      case _AutoScrollState_e.None:
        scrollCtrl.jumpTo(scrollOffset);
      case _AutoScrollState_e.Up:
        if (scrollOffset > 0) {
          scrollCtrl.animateTo(
            0,
            duration: Duration(milliseconds: (scrollOffset * 2).toInt()),
            curve: Curves.linear,
          );
        }
      case _AutoScrollState_e.Down:
        final maxLen = scrollCtrl.position.maxScrollExtent;
        if (scrollOffset < maxLen) {
          scrollCtrl.animateTo(
            maxLen,
            duration: Duration(
              milliseconds: ((maxLen - scrollOffset) * 2).toInt(),
            ),
            curve: Curves.linear,
          );
        }
    }
  }

  bool handleTap(
    final double pointY, {
    bool resetAutoScroll = true,
    final double? pointDy,
  }) {
    tapPointY = pointY;
    if (useTagList.isEmpty) {
      return false;
    }
    final randerBox = widgetKey.currentContext?.findRenderObject();
    if (null != randerBox) {
      final rander = randerBox as RenderBox;
      final translation = rander.getTransformTo(null).getTranslation();
      // 进度条位置
      positionY = translation.y;
      // 进度条宽高
      barHeight = rander.size.height;
      final sub = pointY - positionY;
      final realY = scrollCtrl.offset + sub;
      // index 不一定在正确范围内
      final index = realY ~/ defItemHeight.r;
      if (notifyTapIndex(index, false)) {
        if (resetAutoScroll) {
          if (null != pointDy) {
            final upLimit = barHeight * defAutoScrollExtent + positionY;
            final downLimit = barHeight * (1 - defAutoScrollExtent) + positionY;
            if (pointY <= upLimit) {
              // 在上滑范围内
              if (pointDy <= 0) {
                setAutoScroll(_AutoScrollState_e.Up);
                return true;
              }
            } else if (pointY >= downLimit) {
              // 下滑范围内
              if (pointDy >= 0) {
                setAutoScroll(_AutoScrollState_e.Down);
                return true;
              }
            }
          }
          // 不滚动
          setAutoScroll(_AutoScrollState_e.None);
        }
        return true;
      }
    }
    return false;
  }

  void createScrollToCenter(int index) {
    removeScrollToCenter();
    var offset = index * defItemHeight.r - barHeight / 2;
    if (offset > 0) {
      final maxOffset = scrollCtrl.position.maxScrollExtent;
      if (offset > maxOffset) {
        offset = maxOffset;
      }
      scrollToCenter = Timer(const Duration(milliseconds: 500), () {
        scrollCtrl.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
        );
      });
    }
  }

  void removeScrollToCenter() {
    scrollToCenter?.cancel();
    scrollToCenter = null;
  }

  Widget buildTagItemWidget(int index) {
    Widget? contentWidget;
    final isSelect = (tapingIndex.value == index);
    if (isSelect) {
      contentWidget = MyTextMain(
        useTagList[index],
        style: const MyTextMainStyle(
          rFontSize: _MyIndexBarState.defFontSize,
        ),
      );
    } else {
      contentWidget = MyTextCross(
        useTagList[index],
        style: const MyTextCrossStyle(
          rFontSize: _MyIndexBarState.defFontSize,
        ),
      );
    }
    return MySizedBox(
      height: defItemHeight,
      child: Center(
        child: contentWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barWidget = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Obx(() {
        return ListView(
          physics: const NeverScrollableScrollPhysics(
            parent: MyListBase.allBouncingScrollPhysics,
          ),
          scrollDirection: Axis.vertical,
          controller: scrollCtrl,
          itemExtent: defItemHeight.r,
          children: List.generate(useTagList.length, buildTagItemWidget),
        );
      }),
    );
    // 构造
    return Listener(
      key: widgetKey,
      behavior: HitTestBehavior.opaque,
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          removeScrollToCenter();
          scrollCtrl.jumpTo(scrollCtrl.offset + event.scrollDelta.dy);
        }
      },
      onPointerDown: (details) {
        removeScrollToCenter();
        widget.onTapStart?.call();
        handleTap(details.position.dy, resetAutoScroll: false);
        showTagWidget.value = true;
      },
      onPointerMove: (event) {
        handleTap(event.position.dy, pointDy: event.delta.dy);
        showTagWidget.value = true;
      },
      onPointerUp: (details) {
        final (tag, index) = getTag(tapingIndex.value, autoReset: true);
        if (null != tag) {
          widget.onTapDone?.call(index, tag);
          // 放手后自动滚动到目标
          createScrollToCenter(index);
        }
        showTagWidget.value = false;
        tapingIndex.value = null;
        tapPointY = null;
        // 取消自动滚动
        setAutoScroll(_AutoScrollState_e.None);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: barWidget,
      ),
    );
  }
}

/// 分类索引指示器
class MyIndexBarCategorize<T> extends StatelessWidget {
  static const defTagSearch = "?";
  static const defTagAll = "*";

  final void Function(int index, String tag)? onTagTap;
  final void Function(T item, bool doPlay)? onOverlayItemTap;
  final Map<String, MyIndexBarCateDateItem_c<T>>? categorize;
  final void Function()? onLoadSongsCate, onOpenSearch;

  /// 自定义简单标签展示取值
  final String? Function(int index, String tag)? buildTagOverlayTip;

  /// 自定义简单标签展示歌曲时的名称取值
  final String Function(T item) buildTagOverlayTipShowName;
  final (String title, String? depict) Function(T item) buildTagOverlayShowText;
  final String buildTagOverlayItemBtnSvgName;

  /// 构建弹窗展示分类内容的列表时列表项右边的按钮
  final Widget? Function(int index, T item)? buildPopupAction;

  const MyIndexBarCategorize({
    super.key,
    this.categorize,
    this.onLoadSongsCate,
    this.onTagTap,
    this.onOverlayItemTap,
    this.onOpenSearch,
    required this.buildTagOverlayTipShowName,
    required this.buildTagOverlayShowText,
    this.buildTagOverlayTip,
    this.buildPopupAction,
    this.buildTagOverlayItemBtnSvgName = MySvgNames_e.playMedia,
  });

  bool hasLoadSongsCate() {
    return (null != categorize);
  }

  void defOnTagTap(int index, String tag) {
    final cate = categorize?[tag];
    if (null != cate) {
      final list = cate.list;
      if (list.isNotEmpty && (true == cate.isContinuous || list.length == 1)) {
        onOverlayItemTap?.call(list.first, false);
      }
    }
  }

  List<String> buildHeaderTagList() {
    final relist = [
      if (null != onOpenSearch) defTagSearch,
      if (false == hasLoadSongsCate()) defTagAll,
    ];
    return relist;
  }

  Widget defBuildPopupAction(int index, T item) {
    return MyGestureDetector(
      onTap: () {
        MyRoute_c.back();
        onOverlayItemTap?.call(item, true);
      },
      child: MySettingContentBlock(
        width: null,
        margin: const MyEdgeInsets.only(left: 30),
        padding: const MyEdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100.r,
              ),
              child: MyTextCross("${index + 1}"),
            ),
            MyBtn.simple(
              svgName: buildTagOverlayItemBtnSvgName,
              showDisableColor: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int barPadding = 100;
    var height = (1.sh - 700) / 700;
    if (height > 1) {
      height = 1;
    } else if (height < 0) {
      height = 0;
    }
    barPadding += (height * 100).toInt();
    return Padding(
      padding: MyEdgeInsets.only(top: barPadding + 20, bottom: barPadding),
      child: MySizedBox(
        width: 50,
        child: MyIndexBar(
          taglist: categorize?.keys.toList() ?? MyIndexBar.defSimpleTagList,
          onTagTap: onTagTap ?? defOnTagTap,
          onTapStart: () {
            // 移除提示
            MyPopup.closeEasy(animation: false);
            // 加载分类
            if (false == hasLoadSongsCate()) {
              onLoadSongsCate?.call();
            }
          },
          headerTagList: buildHeaderTagList(),
          buildTagOverlay: (index, tag) {
            var tipStr = buildTagOverlayTip?.call(index, tag);
            if (null == tipStr) {
              switch (tag) {
                case defTagSearch:
                  tipStr = "『搜索』";
                case defTagAll:
                  tipStr = "『选择』";
                default:
                  final cateList = categorize?[tag]?.list;
                  final selectCateSize = cateList?.length;
                  if (null != selectCateSize) {
                    if (selectCateSize == 1) {
                      final song = cateList!.first;
                      tipStr = buildTagOverlayTipShowName.call(song);
                    } else if (selectCateSize > 0) {
                      final song = cateList!.first;
                      tipStr =
                          "『$selectCateSize』${buildTagOverlayTipShowName.call(song)}";
                    } else {
                      tipStr = "『无』";
                    }
                  }
              }
            }
            return Center(
              child: MySettingContentBlock(
                height: 350.r,
                width: 350.r,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                boxShadow: MyGlobalStoreBase.theme_s.isLight()
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
                      ],
                child: Column(
                  children: [
                    Expanded(
                      child: MySettingContentBlock.inContent(
                        margin: const MyEdgeInsets.only(
                          top: 70,
                          left: 70,
                          right: 70,
                        ),
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: MyTextMain(
                            tag,
                            style: const MyTextMainStyle(
                              rFontSize: 110,
                            ),
                          ),
                        ),
                      ),
                    ),
                    MySizedBox(
                      height: 70,
                      child: (null != tipStr)
                          ? Padding(
                              padding: const MyEdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Center(
                                child: MyTextMain(
                                  tipStr,
                                  style: const MyTextMainStyle(
                                    rFontSize: 42,
                                    fontWeight: MyTextCross.defFontWeight,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
          onTapDone: (index, tag) {
            switch (tag) {
              case defTagSearch:
                onOpenSearch?.call();
                return;
              case defTagAll:
                return;
            }
            if (null == onOverlayItemTap || false == hasLoadSongsCate()) {
              return;
            }
            final cate = categorize![tag];
            final list = cate?.list;
            if (null == list || list.isEmpty) {
              MyPopup.showEasyInfo("『$tag』分类没有歌曲");
              return;
            }
            if (cate!.isContinuous || list.length == 1) {
              /// 同[defOnTagTap]
              /// * 该分类的值分布是连续的，不需要弹窗，直接跳转第一个
              /// * 该分类仅包含一个值；实际上仅一个值时也就是连续的
              onOverlayItemTap?.call(list.first, false);
              return;
            }
            // 检查是否连续
            final controller = MyListController(list);
            MyPopup.showBottomSheet(
              title: "$tag『共${list.length}首』",
              sizeBuilder: MyPopup.bottomSheetMaxSize,
              contentBuilder: () {
                return MyListBaseWidget(
                  controller,
                  itemInfo: (item, index) {
                    final (title, depict) = buildTagOverlayShowText(item);
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextMain.thin(title),
                              if (true == depict?.isNotEmpty)
                                Padding(
                                  padding: const MyEdgeInsets.only(top: 10),
                                  child: MyTextCross(depict!),
                                ),
                            ],
                          ),
                        ),
                        buildPopupAction?.call(index, item) ??
                            defBuildPopupAction(index, item),
                      ],
                    );
                  },
                  onItemTap: (item, index) {
                    MyRoute_c.back();
                    onOverlayItemTap?.call(item, false);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
