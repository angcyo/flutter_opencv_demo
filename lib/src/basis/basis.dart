import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/11
///
/// [BuildContext]扩展方法
extension BuildContextEx on BuildContext {
  /// 推送一个Widget
  void pushWidget(Widget widget) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) => widget));
  }
}

/// 图片扩展方法
extension UiImageEx on ui.Image {
  /// 换换成图片字节数据
  Future<Uint8List> toBytes([
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  ]) async {
    return await toByteData(
      format: format,
    ).then((value) => value!.buffer.asUint8List());
  }
}

/// 读取assets中的图片
Future<ImageProvider> loadAssetImage(String path) async {
  return AssetImage(path);
}

/// 读取assets中的图片字节数据
Future<Uint8List> loadAssetBytes(String key) async {
  return (await rootBundle.load(key)).buffer.asUint8List();
}

/// 使用Canvas绘制图片
/// @return 返回ui.Image
Future<ui.Image> drawImage(
  int width,
  int height,
  FutureOr Function(ui.Canvas canvas) onDraw,
) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  await onDraw(canvas);
  final ui.Picture picture = recorder.endRecording();
  return picture.toImage(width, height);
}
