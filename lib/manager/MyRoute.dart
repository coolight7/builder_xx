// ignore_for_file: camel_case_types, constant_identifier_names, file_names, non_constant_identifier_names

import 'package:builder_xx/manager/MyRxCtrlManager.dart';
import 'package:refreshed/refreshed.dart';

class MyRoute_c {
  static String get currentRoute => Get.currentRoute;

  static void back<T>({T? result}) {
    assert(null != navigator);
    navigator?.pop<T>(result);
  }

  static Future<T?>? toNamed<T>(
    String page, {
    dynamic arguments,
    String? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    final manager = MyRxCtrlManager_c.to;
    int? pageId;
    if (manager.autoHandlePageEvent) {
      pageId = manager.pageInto();
    }
    final data = await Get.toNamed(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
    if (manager.autoHandlePageEvent) {
      manager.pageBack(pageId);
    }
    if (data is T?) {
      return data;
    }
    return null;
  }
}
