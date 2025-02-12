// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names

import 'dart:ui';

class MyJsonObj_c {
  MyJsonObj_c._();

  static Map<String, dynamic> toJson_Offset(Offset offset) {
    return <String, dynamic>{
      "dx": offset.dx,
      "dy": offset.dy,
    };
  }

  static Map<String, dynamic> toJson_Size(Size size) {
    return <String, dynamic>{
      "width": size.width,
      "height": size.height,
    };
  }

  static Offset? fromJson_Offset(Map<String, dynamic> json) {
    try {
      return Offset(json["dx"], json["dy"]);
    } catch (_) {
      return null;
    }
  }

  static Size? fromJson_Size(Map<String, dynamic> json) {
    try {
      return Size(json["width"], json["height"]);
    } catch (_) {
      return null;
    }
  }
}
