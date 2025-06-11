import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

//-

/// [RenderView]
RenderView get renderView =>
    RendererBinding.instance.renderViews.firstOrNull ??
    WidgetsBinding.instance.renderView;

MediaQueryData get platformMediaQueryData =>
    MediaQueryData.fromView(renderView.flutterView);

/// 获取屏幕的大小
/// dp 单位
Size get screenSize => WidgetsBinding.instance.renderViews.first.size;

Size get screenSizePixel =>
    screenSize * platformMediaQueryData.devicePixelRatio;

//--

/// 默认的滚动物理特性/滚动行为
const kScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

