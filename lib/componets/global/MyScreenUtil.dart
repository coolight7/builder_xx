// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MySizedBox extends SizedBox {
  static const defSpaceBox = MySizedBox(
    height: 50,
    width: 50,
  );
  static const defSpaceWidthBox = MySizedBox(width: 50);
  static const defSpaceHeightBox = MySizedBox(height: 50);

  const MySizedBox({
    super.key,
    super.height,
    super.width,
    super.child,
  });

  BoxConstraints get additionalConstraints {
    return BoxConstraints.tightFor(
      width: width?.r,
      height: height?.r,
    );
  }

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      additionalConstraints: additionalConstraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = additionalConstraints;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final DiagnosticLevel level;
    if ((width == double.infinity && height == double.infinity) ||
        (width == 0.0 && height == 0.0)) {
      level = DiagnosticLevel.hidden;
    } else {
      level = DiagnosticLevel.info;
    }
    properties.add(DoubleProperty(
      'width',
      width?.r,
      defaultValue: null,
      level: level,
    ));
    properties.add(DoubleProperty(
      'height',
      height?.r,
      defaultValue: null,
      level: level,
    ));
  }
}

class MyRadius extends Radius {
  final int rSize;

  @override
  double get x => rSize.r.truncateToDouble();
  @override
  double get y => rSize.r.truncateToDouble();

  const MyRadius(this.rSize) : super.circular(0);
}

class MyBorderRadius extends BorderRadius {
  const MyBorderRadius(MyRadius super.rSize) : super.all();

  MyBorderRadius.circular(double size)
      : super.circular(size.truncateToDouble());

  MyBorderRadius.circularRInt(int rSize)
      : super.circular(rSize.r.truncateToDouble());
}

class MyOffset extends Offset {
  final int rDx;
  final int rDy;

  static const MyOffset zero = MyOffset(0, 0);

  @override
  double get dx => rDx.r;

  @override
  double get dy => rDy.r;

  @override
  bool get isInfinite => rDx >= double.infinity || rDy >= double.infinity;

  @override
  bool get isFinite => rDx.isFinite && rDy.isFinite;

  const MyOffset(this.rDx, this.rDy) : super(0, 0);
}

class MyBoxShadow extends BoxShadow {
  final int rSpreadRadius;
  final int rBlurRadius;

  @override
  double get spreadRadius => rSpreadRadius.r;
  @override
  double get blurRadius => rBlurRadius.r;

  const MyBoxShadow({
    super.blurStyle,
    super.color,
    super.offset,
    int spreadRadius = 0,
    int blurRadius = 0,
  })  : rSpreadRadius = spreadRadius,
        rBlurRadius = blurRadius;
}

class MyEdgeInsets extends EdgeInsets {
  final int rLeft;
  final int rRight;
  final int rBottom;
  final int rTop;

  @override
  double get left => rLeft.r;
  @override
  double get top => rTop.r;
  @override
  double get right => rRight.r;
  @override
  double get bottom => rBottom.r;

  const MyEdgeInsets.all(int rSize)
      : rLeft = rSize,
        rRight = rSize,
        rBottom = rSize,
        rTop = rSize,
        super.all(0.0);

  const MyEdgeInsets.only({
    int left = 0,
    int right = 0,
    int bottom = 0,
    int top = 0,
  })  : rLeft = left,
        rRight = right,
        rBottom = bottom,
        rTop = top,
        super.all(0.0);
}

class MyShadow extends Shadow {
  const MyShadow({
    super.color,
    super.blurRadius,
    MyOffset offset = MyOffset.zero,
  }) : super(
          offset: offset,
        );

  @override
  double get blurRadius => super.blurRadius.r;
}
