// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:util_xx/util_xx.dart';

class MyGestureDetector extends GestureDetector {
  static final bool enableModifyMouseShowType = Platformxx_c.isDesktop;

  MyGestureDetector({
    super.key,
    super.behavior = HitTestBehavior.opaque,
    super.onTap,
    super.child,
  });

  @override
  Widget build(BuildContext context) {
    final reWidget = super.build(context);
    if (enableModifyMouseShowType) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: reWidget,
      );
    } else {
      return reWidget;
    }
  }
}

class MyGestureDetectorSimple extends StatelessWidget {
  final HitTestBehavior? behavior;
  final void Function()? onTap;
  final Widget? child;

  const MyGestureDetectorSimple({
    super.key,
    this.behavior = HitTestBehavior.opaque,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MyGestureDetector(
      behavior: behavior,
      onTap: onTap,
      child: child,
    );
  }
}
