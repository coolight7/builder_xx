// ignore_for_file: file_names,

import 'package:flutter/material.dart';

class MyListMask extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const MyListMask({
    super.key,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          stops: const [0, 0.05, 0.1, 0.9, 0.95, 1],
          colors: const [
            Color.fromRGBO(255, 255, 255, 0),
            Color.fromRGBO(255, 255, 255, 0.6),
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(255, 255, 255, 0.6),
            Color.fromRGBO(255, 255, 255, 0),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
