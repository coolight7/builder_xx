// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

class MyOverlayManager {
  static OverlayState? getState() {
    final context = Get.overlayContext;
    if (null != context) {
      return Overlay.of(context);
    }
    return null;
  }

  static bool insert(
    OverlayEntry entry, {
    OverlayEntry? below,
    OverlayEntry? above,
  }) {
    final state = getState();
    if (null != state) {
      state.insert(entry, below: below, above: above);
      return true;
    }
    return false;
  }
}
