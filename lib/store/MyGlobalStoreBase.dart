// ignore_for_file: camel_case_types, constant_identifier_names, file_names, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:refreshed/refreshed.dart';
import 'package:builder_xx/store/MySettingStoreBase.dart';
import 'package:util_xx/Eventxx.dart';
import 'package:util_xx/Streamxx.dart';

import 'MyStore.dart';
import 'MyThemeStoreBase.dart';

class MyGlobalStoreBase extends MyStore {
  static late final MyThemeStoreBase theme_s;
  static late final MyGlobalStoreBase global_s;
  static late final MySettingStoreBase setting_s;

  static final rebuildAppEvent = Streamxx_c<Null>(value: null);
  static final _rebuildAppThrottle = EventxxThrottle_c<Null>(
    time: const Duration(milliseconds: 300),
    onListen: (_) {
      Get.forceAppUpdate();
      rebuildAppEvent.notify(null);
    },
  );

  MyGlobalStoreBase();

  /// ## 重新构建整个app
  /// * 默认情况下会利用[rebuildAppEvent]降低触发频率，因此调用后重构App存在一定延迟。
  /// * [immediately] 是否立即触发
  static void appRebuild({
    bool immediately = false,
  }) {
    if (immediately) {
      Get.forceAppUpdate();
      rebuildAppEvent.notify(null);
    } else {
      _rebuildAppThrottle.notify(null);
    }
  }

  /// 退出应用
  static void appClose() {
    exit(0);
  }
}

mixin MyTickerProviderStateMixin on MyStore implements TickerProvider {
  Set<Ticker>? tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    tickers ??= <_MyWidgetTicker>{};
    final result = _MyWidgetTicker(
      onTick,
      this,
      debugLabel: kDebugMode ? "created by ${describeIdentity(this)}" : null,
    );
    tickers!.add(result);
    return result;
  }

  void _removeTicker(_MyWidgetTicker ticker) {
    assert(tickers != null, "You must add a ticker before removing it.");
    assert(
      tickers!.contains(ticker),
      "You must add a ticker before removing it.",
    );
    tickers!.remove(ticker);
  }

  void setTickerEnable(bool enable) {
    if (tickers != null) {
      if (kDebugMode) {
        print("Store Tickers set Enable: $enable");
      }
      for (final Ticker ticker in tickers!) {
        ticker.muted = !enable;
      }
    }
  }

  /// Callback invoked when the dependencies of this widget change.
  void didChangeDependencies(BuildContext context) {
    final bool enable = TickerMode.of(context);
    setTickerEnable(enable);
  }

  @override
  void onClose() {
    assert(
      () {
        if (tickers != null) {
          for (final Ticker ticker in tickers!) {
            if (ticker.isActive) {
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary("$this was disposed with an active Ticker."),
                ErrorDescription(
                  "$runtimeType created a Ticker via its GetTickerProviderStateMixin, but at the time "
                  "dispose() was called on the mixin, that Ticker was still active. All Tickers must "
                  "be disposed before calling super.dispose().",
                ),
                ErrorHint(
                  "Tickers used by AnimationControllers "
                  "should be disposed by calling dispose() on the AnimationController itself. "
                  "Otherwise, the ticker will leak.",
                ),
                ticker.describeForError("The offending ticker was"),
              ]);
            }
          }
        }
        return true;
      }(),
      "",
    );
    super.onClose();
  }
}

class _MyWidgetTicker extends Ticker {
  _MyWidgetTicker(
    super._onTick,
    this._creator, {
    super.debugLabel,
  });

  final MyTickerProviderStateMixin _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}
