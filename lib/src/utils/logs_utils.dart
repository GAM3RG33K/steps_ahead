import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:steps_ahead/constants.dart';

class Log {
  static void d({
    required String message,
    String? tag,
  }) {
    if (!kDebugMode) return;
    tag ??= _defaultLogTag;
    log('DEBUG ------> $tag:\t$message');
  }

  static void i({
    required String message,
    String? tag,
  }) {
    tag ??= _defaultLogTag;
    log('INFO ------> $tag:\t$message');
  }

  static void e({
    required dynamic error,
    String? message,
    StackTrace? stackTrace,
    String? tag,
  }) {
    tag ??= _defaultLogTag;

    String message0 = message ?? '';
    if (error != null) {
      message0 += '\n------> E: ${error.toString()}';
    }
    if (stackTrace != null) {
      message0 += '\n------> S: $stackTrace';
    }
    log('ERROR ------> $tag:\t$message0');
  }

  static String get _defaultLogTag {
    return kProjectName;
  }
}
