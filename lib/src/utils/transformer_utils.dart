import 'dart:convert';

import 'package:flutter/material.dart';

String formatDate(DateTime d) {
  return d.toIso8601String();
}

String getPrettyJSONString(jsonObject) {
  const encoder = JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}

extension StringColorExtenstion on String? {
  int? get toHexInt {
    final code = this;
    if (code == null) return null;
    return int.parse(code, radix: 16);
  }

  Color? get toColor {
    final code = this;
    if (code == null) return null;

    if (code.toLowerCase() == "black") {
      return Colors.black;
    } else if (code.toLowerCase() == "red") {
      return Colors.red;
    } else if (code.toLowerCase() == "yellow") {
      return Colors.yellow;
    } else if (code.toLowerCase() == "blue") {
      return Colors.blue;
    } else if (code.toLowerCase() == "white") {
      return Colors.white;
    } else if (code.toLowerCase() == "green") {
      return Colors.green;
    } else if (code.toLowerCase() == "grey") {
      return Colors.grey;
    } else if (code.toLowerCase() == "orange") {
      return Colors.orange;
    } else {
      return _parseHexColor(code);
    }
  }
}

Color? _parseHexColor(String code) {
  code = code.replaceAll('#', '');

  if (code.length == 3) {
    code = '${code[0]}${code[0]}${code[1]}${code[1]}${code[2]}${code[2]}';
  }

  var colorValue = int.tryParse(code, radix: 16);
  if (colorValue != null) {
    if (code.length == 6) {
      return Color(colorValue | 0xFF000000);
    } else {
      var alphaValue = ((colorValue & 0xFF000000) >> 24);
      colorValue &= 0x00FFFFFF;
      return Color.fromRGBO(
          (colorValue & 0xFF0000) >> 16,
          (colorValue & 0x00FF00) >> 8,
          (colorValue & 0x0000FF),
          alphaValue / 255);
    }
  }

  return null;
}

extension ColorExtenstion on Color? {
  Color? mergeWith(
    Color newColor, {
    double mixRatio = 0.5,
    double t = 0.1,
  }) {
    final code = this;
    if (code == null) return null;

    Color? mixedColor = Color.lerp(
      this!.withOpacity(mixRatio),
      newColor.withOpacity(1 - mixRatio),
      t,
    );
    return mixedColor;
  }
}
