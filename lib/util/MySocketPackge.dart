// ignore_for_file: file_names, camel_case_types

import 'dart:io' as io;
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';

/// 封装/分包socket消息包
class MySocketPackge_c<T> {
  final io.Socket socket;
  final _mutableData = <int>[];
  final T? Function(String str) onMsgFromString;
  final String Function(T msg) onMsgToString;

  MySocketPackge_c({
    required this.socket,
    required this.onMsgFromString,
    required this.onMsgToString,
  });

  static Future<MySocketPackge_c<T>?> connect<T>(
    int port, {
    String addr = "0.0.0.0",
    required T? Function(String str) onMsgFromString,
    required String Function(T msg) onMsgToString,
    Duration? timeout,
  }) async {
    try {
      return MySocketPackge_c<T>(
        socket: await io.Socket.connect(
          addr,
          port,
          timeout: timeout,
        ),
        onMsgToString: onMsgToString,
        onMsgFromString: onMsgFromString,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  void sendUint8List(Uint8List data) {
    // 约定二进制格式为：
    // [(int32)data.len][data]
    int len = data.length;
    // 将 len 作为 int32 向 [Uint8List] 为4个byte的数组（大端）
    final lenList = Uint8List.fromList([
      (len & (0xFF000000)) >> 24,
      (len & (0x00FF0000)) >> 16,
      (len & (0x0000FF00)) >> 8,
      len & (0x000000FF),
    ]);
    socket.add([
      ...lenList,
      ...data,
    ]);
  }

  void sendString(String data) {
    final list = convert.utf8.encode(data);
    sendUint8List(list);
  }

  void send(T data) {
    sendString(onMsgToString.call(data));
  }

  void listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    socket.listen(
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
      (data) {
        _mutableData.addAll(data);
        while (true) {
          final packageLen = _getPackageLength(_mutableData);
          if (_mutableData.length >= (packageLen + 4)) {
            try {
              final str = convert.utf8.decode(
                _mutableData.sublist(4, packageLen + 4),
                allowMalformed: true,
              );
              final reMsg = onMsgFromString.call(str);
              if (null == reMsg) {
                // 转换失败，清空数据
                _mutableData.clear();
                return;
              } else {
                try {
                  onData?.call(reMsg);
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
              _mutableData.clear();
              return;
            }
            //清空处理过的数据流
            _mutableData.replaceRange(0, packageLen + 4, []);
            if (_mutableData.length <= 4) {
              break;
            }
          } else {
            break;
          }
        }
      },
    );
  }

  void close() {
    socket.close();
  }

  static int _getPackageLength(List<int> data) {
    return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
  }
}
