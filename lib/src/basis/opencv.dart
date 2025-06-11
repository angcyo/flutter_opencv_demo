import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv_demo/src/basis/ui.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

import 'basis.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/11
///
/// https://github.com/rainyl/opencv_dart
/// https://github.com/opencv/opencv

extension MatEx on cv.Mat {
  /// 转换成ui.Image
  Future<ui.Image> toUiImage() {
    return decodeImageFromList(toImageBytes());
  }

  /// 转为图片字节数据
  Uint8List toImageBytes([String ext = ".png"]) {
    final pair = cv.imencode(ext, this);
    return pair.$2;
  }
}

/// 从文件中加载图片
cv.Mat loadFileImage(String path) {
  final image = cv.imread(path);
  return image;
}

/// 从Assets中加载图片
Future<cv.Mat> loadAssetImage(String key) async {
  final bytes = await loadAssetBytes(key);
  return cv.imdecode(bytes, cv.IMREAD_COLOR);
}

//--

/// 棋盘角落坐标
Future<Uint8List> testChessboardCorners() async {
  final image = await loadAssetImage("lib/assets/chessboard.png"); // 6,9
  final patternSize = (6, 9);
  //final image = await loadAssetImage("lib/assets/left07.jpg"); //7,6
  //final patternSize = (7,6);
  final width = image.width;
  final height = image.height;
  // Error: One of the arguments' values is out of range (Both width and height of the pattern should have bigger than 2) in findChessboardCorners
  final (success, corners) = cv.findChessboardCorners(image, patternSize);
  print(
    "${screenSize} ${screenSizePixel} [$width*$height]success: $success corners[${corners.length}]: $corners",
  );
  final radius = width / screenSizePixel.width;
  if (success) {
    return await drawImage(width, height, (canvas) async {
      canvas.drawImage(await image.toUiImage(), Offset.zero, Paint());
      for (final point in corners) {
        canvas.drawCircle(
          Offset(point.x, point.y),
          radius * 10,
          Paint()..color = Colors.red,
        );
      }
      /*canvas.drawLine(
        Offset(10, 10),
        Offset(100, 100),
        Paint()..color = Colors.red,
      );*/
    }).then((image) => image.toBytes());
  } else {
    return image.toImageBytes();
  }
}

/// 测试入口
Future<Uint8List> test() async {
  //final image = await loadAssetImage("lib/assets/chessboard.png");
  final image = await loadAssetImage("lib/assets/left07.jpg");
  final width = image.width;
  final height = image.height;
  final (success, corners) = cv.findChessboardCorners(image, (7, 6));
  //debugger();
  print(
    "[$width*$height]success: $success corners[${corners.length}]: $corners",
  );
  return image.toImageBytes();
}
