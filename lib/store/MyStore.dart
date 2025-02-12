// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:refreshed/refreshed.dart';

class MyStore extends GetxController {
  @protected
  bool hasInitDo = false;

  MyStore();

  Future<void> initDo({
    bool hasDo = true,
  }) async {
    hasInitDo = hasDo;
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (null != ids || hasInitDo) {
      super.update(ids, condition);
    }
  }
}
