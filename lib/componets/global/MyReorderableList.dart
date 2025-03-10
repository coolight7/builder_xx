// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: implementation_imports, file_names

import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/src/material/debug.dart';
import 'package:flutter/src/material/material.dart';

/// A list whose items the user can interactively reorder by dragging.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=3fB1mxOsqJE}
///
/// This sample shows by dragging the user can reorder the items of the list.
/// The [onReorder] parameter is required and will be called when a child
/// widget is dragged to a new position.
///
/// {@tool dartpad}
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.0.dart **
/// {@end-tool}
///
/// By default, on [TargetPlatformVariant.desktop] platforms each item will
/// have a drag handle added on top of it that will allow the user to grab it
/// to move the item. On [TargetPlatformVariant.mobile], no drag handle will be
/// added, but when the user long presses anywhere on the item it will start
/// moving the item. Displaying drag handles can be controlled with
/// [ReorderableListView.buildDefaultDragHandles].
///
/// All list items must have a key.
///
/// This example demonstrates using the [ReorderableListView.proxyDecorator] callback
/// to customize the appearance of a list item while it's being dragged.
///
/// {@tool dartpad}
/// While a drag is underway, the widget returned by the [ReorderableListView.proxyDecorator]
/// callback serves as a "proxy" (a substitute) for the item in the list. The proxy is
/// created with the original list item as its child. The [ReorderableListView.proxyDecorator]
/// callback in this example is similar to the default one except that it changes the
/// proxy item's background color.
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.1.dart **
/// {@end-tool}
///
/// This example demonstrates using the [ReorderableListView.proxyDecorator] callback to
/// customize the appearance of a [Card] while it's being dragged.
///
/// {@tool dartpad}
/// The default [proxyDecorator] wraps the dragged item in a [Material] widget and animates
/// its elevation. This example demonstrates how to use the [ReorderableListView.proxyDecorator]
/// callback to update the dragged card elevation without inserted a new [Material] widget.
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.2.dart **
/// {@end-tool}
class MyReorderableList extends StatefulWidget {
  /// Creates a reorderable list from a pre-built list of widgets.
  ///
  /// This constructor is appropriate for lists with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the list view instead of just
  /// those children that are actually visible.
  ///
  /// See also:
  ///
  ///   * [ReorderableListView.builder], which allows you to build a reorderable
  ///     list where the items are built as needed when scrolling the list.
  MyReorderableList({
    super.key,
    required List<Widget> children,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.proxyDecorator,
    this.padding,
    this.header,
    this.footer,
    this.itemDragHandle,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
  })  : assert(
          children.every((Widget w) => w.key != null),
          'All children of this widget must have a key.',
        ),
        itemBuilder = ((BuildContext context, int index) => children[index]),
        itemCount = children.length;

  /// Creates a reorderable list from widget items that are created on demand.
  ///
  /// This constructor is appropriate for list views with a large number of
  /// children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// The `itemBuilder` callback will be called only with indices greater than
  /// or equal to zero and less than `itemCount`.
  ///
  /// The `itemBuilder` should always return a non-null widget, and actually
  /// create the widget instances when called. Avoid using a builder that
  /// returns a previously-constructed widget; if the list view's children are
  /// created in advance, or all at once when the [ReorderableListView] itself
  /// is created, it is more efficient to use the [ReorderableListView]
  /// constructor. Even more efficient, however, is to create the instances
  /// on demand using this constructor's `itemBuilder` callback.
  ///
  /// This example creates a list using the
  /// [ReorderableListView.builder] constructor. Using the [IndexedWidgetBuilder], The
  /// list items are built lazily on demand.
  /// {@tool dartpad}
  ///
  /// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.reorderable_list_view_builder.0.dart **
  /// {@end-tool}
  /// See also:
  ///
  ///   * [ReorderableListView], which allows you to build a reorderable
  ///     list with all the items passed into the constructor.
  const MyReorderableList.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.proxyDecorator,
    this.padding,
    this.header,
    this.footer,
    this.itemDragHandle,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
  }) : assert(itemCount >= 0);

  /// {@macro flutter.widgets.reorderable_list.itemBuilder}
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.onReorderStart}
  final void Function(int index)? onReorderStart;

  /// {@macro flutter.widgets.reorderable_list.onReorderEnd}
  final void Function(int index)? onReorderEnd;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// coolight
  /// 列表项的拖动按钮
  final Widget? itemDragHandle;

  /// {@macro flutter.widgets.reorderable_list.padding}
  final EdgeInsets? padding;

  /// A non-reorderable header item to show before the items of the list.
  ///
  /// If null, no header will appear before the list.
  final Widget? header;

  /// A non-reorderable footer item to show after the items of the list.
  ///
  /// If null, no footer will appear after the list.
  final Widget? footer;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}

  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [scrollController] is null.
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.EdgeDraggingAutoScroller.velocityScalar}
  ///
  /// {@macro flutter.widgets.SliverReorderableList.autoScrollerVelocityScalar.default}
  final double? autoScrollerVelocityScalar;

  @override
  State<MyReorderableList> createState() => _ReorderableListViewState();
}

class _ReorderableListViewState extends State<MyReorderableList> {
  Widget _itemBuilder(BuildContext context, int index) {
    final Widget item = widget.itemBuilder(context, index);
    assert(() {
      if (item.key == null) {
        throw FlutterError(
          'Every item of ReorderableListView must have a key.',
        );
      }
      return true;
    }());

    final Key itemGlobalKey =
        _ReorderableListViewChildGlobalKey(item.key!, this);
    // coolight: 构造列表项的拖动指示器
    final Widget? itemDragHandleWidget = widget.itemDragHandle;
    if (null != itemDragHandleWidget) {
      return Stack(
        key: itemGlobalKey,
        children: <Widget>[
          item,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ReorderableDragStartListener(
              index: index,
              child: itemDragHandleWidget,
            ),
          ),
        ],
      );
    }

    return KeyedSubtree(
      key: itemGlobalKey,
      child: item,
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasOverlay(context));

    // If there is a header or footer we can't just apply the padding to the list,
    // so we break it up into padding for the header, footer and padding for the list.
    final EdgeInsets padding = widget.padding ?? EdgeInsets.zero;
    late final EdgeInsets headerPadding;
    late final EdgeInsets footerPadding;
    late final EdgeInsets listPadding;

    if (widget.header == null && widget.footer == null) {
      headerPadding = EdgeInsets.zero;
      footerPadding = EdgeInsets.zero;
      listPadding = padding;
    } else if (widget.header != null || widget.footer != null) {
      switch (widget.scrollDirection) {
        case Axis.horizontal:
          if (widget.reverse) {
            headerPadding = EdgeInsets.fromLTRB(
                0, padding.top, padding.right, padding.bottom);
            listPadding = EdgeInsets.fromLTRB(
                widget.footer != null ? 0 : padding.left,
                padding.top,
                widget.header != null ? 0 : padding.right,
                padding.bottom);
            footerPadding = EdgeInsets.fromLTRB(
                padding.left, padding.top, 0, padding.bottom);
          } else {
            headerPadding = EdgeInsets.fromLTRB(
                padding.left, padding.top, 0, padding.bottom);
            listPadding = EdgeInsets.fromLTRB(
                widget.header != null ? 0 : padding.left,
                padding.top,
                widget.footer != null ? 0 : padding.right,
                padding.bottom);
            footerPadding = EdgeInsets.fromLTRB(
                0, padding.top, padding.right, padding.bottom);
          }
        case Axis.vertical:
          if (widget.reverse) {
            headerPadding = EdgeInsets.fromLTRB(
                padding.left, 0, padding.right, padding.bottom);
            listPadding = EdgeInsets.fromLTRB(
                padding.left,
                widget.footer != null ? 0 : padding.top,
                padding.right,
                widget.header != null ? 0 : padding.bottom);
            footerPadding = EdgeInsets.fromLTRB(
                padding.left, padding.top, padding.right, 0);
          } else {
            headerPadding = EdgeInsets.fromLTRB(
                padding.left, padding.top, padding.right, 0);
            listPadding = EdgeInsets.fromLTRB(
                padding.left,
                widget.header != null ? 0 : padding.top,
                padding.right,
                widget.footer != null ? 0 : padding.bottom);
            footerPadding = EdgeInsets.fromLTRB(
                padding.left, 0, padding.right, padding.bottom);
          }
      }
    }

    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        if (widget.header != null)
          SliverPadding(
            padding: headerPadding,
            sliver: SliverToBoxAdapter(child: widget.header),
          ),
        SliverPadding(
          padding: listPadding,
          sliver: SliverReorderableList(
            itemBuilder: _itemBuilder,
            itemExtent: widget.itemExtent,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            onReorderStart: widget.onReorderStart,
            onReorderEnd: widget.onReorderEnd,
            proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
            autoScrollerVelocityScalar: widget.autoScrollerVelocityScalar,
          ),
        ),
        if (widget.footer != null)
          SliverPadding(
            padding: footerPadding,
            sliver: SliverToBoxAdapter(child: widget.footer),
          ),
      ],
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableListViewChildGlobalKey extends GlobalObjectKey {
  const _ReorderableListViewChildGlobalKey(this.subKey, this.state)
      : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ReorderableListViewChildGlobalKey &&
        other.subKey == subKey &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, state);
}
