// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyList.dart';
import 'package:shimmer/shimmer.dart';

import 'MyScreenUtil.dart';

class MyShimmerItem extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shape;

  const MyShimmerItem({
    super.key,
    required this.width,
    required this.height,
    this.shape = const RoundedRectangleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return Shimmer.fromColors(
      baseColor: theme.shimmerBaseColor ?? const Color(0x80000000),
      highlightColor: theme.shimmerHighlightColor ?? const Color(0x33000000),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: theme.shimmerDecorationColor ?? const Color(0x4D000000),
          shape: shape,
        ),
      ),
    );
  }
}

/// 无动画加载占位
class MyShimmerStaticItem extends StatelessWidget {
  const MyShimmerStaticItem({
    super.key,
  });

  static Widget buildDefShimmer() {
    return const MyShimmerStaticItem();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.shimmerHighlightColor ?? const Color(0x4D000000),
      ),
    );
  }
}

class MyShimmerList extends StatelessWidget {
  final ScrollPhysics? physics;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final Widget? header;
  final bool shrinkWrap;

  const MyShimmerList({
    super.key,
    this.itemCount = 4,
    this.physics,
    this.padding,
    this.header,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return Shimmer.fromColors(
      baseColor: theme.shimmerBaseColor ?? const Color(0x80000000),
      highlightColor: theme.shimmerHighlightColor ?? const Color(0x33000000),
      child: ListView(
        physics: physics,
        padding: padding,
        itemExtent: MyListBase.defListBoxItemHeight,
        shrinkWrap: shrinkWrap,
        addAutomaticKeepAlives: false,
        children: [
          if (null != header) header!,
          ...List.filled(itemCount, const _BuildMyShimmerListItem()),
        ],
      ),
    );
  }
}

class _BuildMyShimmerListItem extends StatelessWidget {
  const _BuildMyShimmerListItem();

  @override
  Widget build(BuildContext context) {
    final itemHeight = MyListBase.defListBoxItemHeight;
    final boxColor = MyGlobalStoreBase.theme_s.mytheme.shimmerDecorationColor ??
        const Color(0x4D000000);
    return SizedBox(
      height: itemHeight,
      width: double.infinity,
      child: Row(
        children: [
          // 图片占位
          MySizedBox(
            width: 160,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: const MyBorderRadius(MyRadius(35)),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 信息占位
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: itemHeight / 3,
                      width: constraints.maxWidth / 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: const MyBorderRadius(MyRadius(15)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: itemHeight / 3,
                      width: constraints.maxWidth / 4 * 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: const MyBorderRadius(MyRadius(15)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            height: itemHeight / 2,
            width: itemHeight / 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: const MyBorderRadius(MyRadius(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyShimmerSimpleList extends StatelessWidget {
  final ScrollPhysics? physics;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const MyShimmerSimpleList({
    super.key,
    this.itemCount = 4,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return Shimmer.fromColors(
      baseColor: theme.shimmerBaseColor ?? const Color(0x80000000),
      highlightColor: theme.shimmerHighlightColor ?? const Color(0x33000000),
      child: ListView(
        physics: physics,
        padding: padding,
        itemExtent: MyListBase.defListBoxItemHeight,
        addAutomaticKeepAlives: false,
        shrinkWrap: shrinkWrap,
        children: List.filled(itemCount, const _BuildMyShimmerSimpleListItem()),
      ),
    );
  }
}

class _BuildMyShimmerSimpleListItem extends StatelessWidget {
  const _BuildMyShimmerSimpleListItem();

  @override
  Widget build(BuildContext context) {
    final itemHeight = MyListBase.defListBoxItemHeight;
    final boxColor = MyGlobalStoreBase.theme_s.mytheme.shimmerDecorationColor ??
        const Color(0x4D000000);
    return SizedBox(
      height: itemHeight,
      width: double.infinity,
      child: Row(
        children: [
          MySizedBox(
            width: 160,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: const MyBorderRadius(MyRadius(35)),
              ),
            ),
          ),
          const MySizedBox(width: 50),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: itemHeight / 3,
                      width: constraints.maxWidth / 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: const MyBorderRadius(MyRadius(15)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: itemHeight / 3,
                      width: constraints.maxWidth / 5 * 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: const MyBorderRadius(MyRadius(15)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyShimmerBase extends StatelessWidget {
  final int rSize;
  final Widget? child;
  final List<BoxShadow>? boxShadow;

  const MyShimmerBase({
    super.key,
    this.boxShadow,
    required this.rSize,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = rSize.r;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size / 2,
            height: size / 2,
            decoration: BoxDecoration(
              boxShadow: boxShadow ??
                  const [
                    BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                      blurRadius: 16,
                      spreadRadius: 0.1,
                    )
                  ],
              shape: BoxShape.circle,
            ),
          ),
          if (null != child) child!,
        ],
      ),
    );
  }
}
