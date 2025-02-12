import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:builder_xx/manager/MyRoute.dart';
import 'package:util_xx/Loggerxx.dart';
import 'package:refreshed/refreshed.dart';

abstract class MyRxControllerBase extends GetxController {
  static int _defManagerId = 1;
  static int get _createManagerId {
    return _defManagerId++;
  }

  final int _managerId = _createManagerId;

  /// 删除控制器
  void delete() {
    try {
      onDelete();
    } catch (e) {
      Loggerxx.to().severe(LogxxItem(
        prefix: "MyListControllerBase.delete",
        msg: [e.toString()],
      ));
    }
  }

  @override
  int get hashCode => _managerId;

  @override
  bool operator ==(Object other) {
    return (hashCode == other.hashCode);
  }
}

abstract class MyRxControllerAdapt<CtrlType extends MyRxControllerBase>
    extends MyRxControllerBase {
  /// 是否启用自动删除控制器，这将在页面进出时自动删除一些控制器
  /// * 对于需要常驻使用的控制器应当指定为false
  final bool enableAutoDelete;
  final void Function(CtrlType ctrl)? onInitFun, onCloseFun;

  MyRxControllerAdapt({
    this.enableAutoDelete = true,
    this.onInitFun,
    this.onCloseFun,
  }) {
    if (enableAutoDelete) {
      MyRxCtrlManager_c.to.putInit(this);
    }
  }

  @override
  void onInit() {
    /// 当控制器被页面组件挂载使用时触发，因此配合[MyListCtrlManager_c]可判断出某一
    /// 创建了什么控制器，并在进出页面时自动销毁控制器
    super.onInit();
    if (enableAutoDelete) {
      MyRxCtrlManager_c.to.put(this);
    }
    onInitFun?.call(this as CtrlType);
  }

  @override
  void onClose() {
    onCloseFun?.call(this as CtrlType);
    super.onClose();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (isClosed) {
      if (kDebugMode) {
        print("[$_managerId]正在更新已销毁的控制器");
      }
      return;
    }
    super.update(ids, condition);
  }
}

class MyRxCtrlManagerItem_c {
  static int _defManagerId = 1;
  static int get _createManagerId {
    return _defManagerId++;
  }

  final int _managerId = _createManagerId;

  final list = <int, MyRxControllerBase>{};
  final initList = <int, MyRxControllerBase>{};

  void add(MyRxControllerBase ctrl) {
    list[ctrl._managerId] = ctrl;
  }

  void removeItem(int id) {
    list.remove(id);
  }

  void deleteItem(int id) {
    final item = list[id];
    if (null != item) {
      item.delete();
    }
    list.remove(id);
  }

  void addInit(MyRxControllerBase ctrl) {
    initList[ctrl._managerId] = ctrl;
  }

  void removeInitItem(int id) {
    initList.remove(id);
  }

  void clear() {
    for (final item in list.values) {
      item.delete();
    }
    list.clear();
    // 清理残留的[initList]
    // for (final item in initList.values) {
    //   item.delete();
    // }
    initList.clear();
  }

  void removeInitListBy(Map<int, MyRxControllerBase> in_initlist) {
    for (final key in in_initlist.keys) {
      initList.remove(key);
    }
  }
}

/// 自动销毁一些控制器
class MyRxCtrlManager_c {
  static late final MyRxCtrlManager_c to;

  final pageStack = Queue<MyRxCtrlManagerItem_c>();
  final tempInitCtrlList = <MyRxControllerBase>[];

  /// 是否由[my_builder]处理自身产生的进出页面事件
  final bool autoHandlePageEvent;

  MyRxCtrlManager_c({
    this.autoHandlePageEvent = true,
  });

  static void init(MyRxCtrlManager_c ctrl) {
    to = ctrl;
  }

  int pageInto() {
    final item = MyRxCtrlManagerItem_c();
    pageStack.add(item);
    return item._managerId;
  }

  void pageBack(int? id) {
    if (null == id) {
      return;
    }
    if (pageStack.isEmpty) {
      Loggerxx.to().warning(LogxxItem(
        prefix: "MyListCtrlManager_c.pageBack",
        msg: ["页面管理记录与实际不符", "记录为空", "实际${MyRoute_c.currentRoute}"],
      ));
      return;
    }
    // 查找
    MyRxCtrlManagerItem_c? backItem;
    for (final item in pageStack) {
      if (item._managerId == id) {
        // 清理[backItem]中的[initList]和[item]中[list]相同的部分
        backItem?.removeInitListBy(item.list);
        item.clear();
        pageStack.remove(item);
        break;
      }
      backItem = item;
    }
    if (pageStack.isEmpty) {
      // 如果回到首页，则清理[tempInitCtrlList]
      for (final item in tempInitCtrlList) {
        item.delete();
      }
      tempInitCtrlList.clear();
    }
  }

  void put(MyRxControllerBase ctrl) {
    if (pageStack.isNotEmpty) {
      pageStack.last.add(ctrl);
    } else {
      Loggerxx.to().warning(LogxxItem(
        prefix: "MyListCtrlManager_c.put",
        msg: ["控制器${ctrl._managerId}游离于管理之外", StackTrace.current.toString()],
      ));
    }
  }

  void putInit(MyRxControllerBase ctrl) {
    if (pageStack.isNotEmpty) {
      pageStack.last.addInit(ctrl);
    } else {
      tempInitCtrlList.add(ctrl);
    }
  }

  void remove(MyRxControllerBase ctrl) {}

  void delete(MyRxControllerBase ctrl) {}
}
