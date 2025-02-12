// ignore_for_file: file_names, camel_case_types, constant_identifier_names, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:builder_xx/componets/global/MyList.dart';

class MyScrollView extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Axis scrollDirection;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final bool center;
  final ScrollController? controller;

  const MyScrollView({
    super.key,
    this.padding,
    this.scrollDirection = Axis.horizontal,
    this.physics = MyListBase.allBouncingScrollPhysics,
    this.center = true,
    this.controller,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final child = (Axis.horizontal == scrollDirection)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
    final scrollChild = SingleChildScrollView(
      physics: physics,
      padding: padding,
      scrollDirection: scrollDirection,
      controller: controller,
      child: center
          ? Center(
              child: child,
            )
          : child,
    );
    return center
        ? Center(
            child: scrollChild,
          )
        : scrollChild;
  }
}
