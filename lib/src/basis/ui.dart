import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/11
///
/// 耗时统计
mixin StopwatchMixin {
  /// 耗时文本
  String? stopwatchText;

  /// 耗时统计
  Future wrapStopwatch(String tag, FutureOr Function() block) async {
    //debugger();
    final stopwatch = Stopwatch()..start();

    //耗时操作
    String? error;
    try {
      await block();
    } catch (e) {
      print(e);
      error = e.toString();
    }

    stopwatch.stop();
    stopwatchText =
        '[$tag]耗时: ${stopwatch.elapsedMilliseconds} 毫秒\n${error ?? ""}';

    final it = this;
    if (it is State) {
      (it as dynamic).setState(() {});
    }

    //print("...end");
  }
}
