// ignore_for_file: file_names, camel_case_types, constant_identifier_names, non_constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:builder_xx/util/MySrc.dart';

class MySrcImage_c extends MySrc_c<MySrcInfo_c> {
  MySrcImage_c({
    super.src = "",
    MySrcInfo_c? info,
  }) : super(info: info ?? MySrcInfo_c());

  factory MySrcImage_c.fromString(String in_str, MySrcInfo_c info) {
    final src = MySrcImage_c(
      info: info,
    );
    src.oFromString(in_str);
    return src;
  }

  factory MySrcImage_c.fromMySrc(MySrc_c in_src) {
    return MySrcImage_c(
      src: in_src.src,
      info: in_src.info,
    );
  }

  static MySrcImage_c? fromStringOrNull(
    String? in_str,
    MySrcInfo_c info,
  ) {
    if (null == in_str) {
      return null;
    }
    return MySrcImage_c.fromString(in_str, info);
  }

  /// 若[src]非[String]或是空字符串，则返回[null]
  static MySrcImage_c? tryBuildImageSrc(dynamic src, MySrcType_e type) {
    if (src is String && src.isNotEmpty) {
      return MySrcImage_c(
        info: MySrcInfo_c(
          type: type,
        ),
        src: src,
      );
    }
    return null;
  }

  /// 若[src]不符合要求，则返回一个空资源，且其类型为[MySrcType_e.Undefined]
  static MySrcImage_c buildImageSrc(dynamic src, MySrcType_e type) {
    return tryBuildImageSrc(src, type) ?? MySrcImage_c();
  }

  static MySrcImage_c? fromMySrcOrNull(MySrc_c? in_src) {
    if (null == in_src) {
      return null;
    }
    return MySrcImage_c.fromMySrc(in_src);
  }

  MySrc_c<MySrcInfo_c> toMySrc() {
    return MySrc_c<MySrcInfo_c>(
      src: src,
      info: info,
    );
  }

  @override
  MySrcImage_c copyWith({
    String? src,
    MySrcInfo_c? info,
  }) {
    return MySrcImage_c(
      src: src ?? this.src,
      info: info ?? this.info.copyWith(),
    );
  }
}

class MyImageBase extends StatelessWidget {
  static const noDecorationRect = BoxDecoration();
  static const noDecorationCircle = BoxDecoration(
    shape: BoxShape.circle,
  );
  static const timeLimit = Duration(seconds: 17); // 加载超时时间
  static const int clearMemoryCacheLimitNum = 30;

  const MyImageBase({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
