// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'MyText.dart';
import '../../manager/MyTheme.dart';

class MyTimePicker extends StatelessWidget {
  final Duration initTime;
  final CupertinoTimerPickerMode mode;
  final void Function(Duration) onTimerDurationChanged;
  final int minuteInterval;
  final int secondInterval;
  final AlignmentGeometry alignment;

  // TODO: linux 渲染异常闪烁
  const MyTimePicker({
    super.key,
    required this.onTimerDurationChanged,
    this.initTime = Duration.zero,
    this.mode = CupertinoTimerPickerMode.hms,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: MyTextMainStyle(),
        ),
      ),
      child: CupertinoTimerPicker(
        initialTimerDuration: initTime,
        mode: mode,
        minuteInterval: minuteInterval,
        secondInterval: secondInterval,
        alignment: alignment,
        backgroundColor: MyColors_e.transparent,
        onTimerDurationChanged: onTimerDurationChanged,
      ),
    );
  }
}
