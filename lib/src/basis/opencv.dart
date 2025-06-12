import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_opencv_demo/src/basis/pubs.dart';
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
  // final image = await loadAssetImage("lib/assets/chessboard.png"); // 6,9
  // final patternSize = (6, 9);
  // final image = await loadAssetImage("lib/assets/left07.jpg"); //7,6
  // final patternSize = (7,6);

  final image = await loadAssetImage("lib/assets/grid.png");
  final patternSize = (10, 10);

  final width = image.width;
  final height = image.height;
  // Error: One of the arguments' values is out of range (Both width and height of the pattern should have bigger than 2) in findChessboardCorners
  final (success, corners) = cv.findChessboardCorners(image, patternSize);

  //cv.cornerSubPix(image, corners, (7, 7), (width, height));

  print(
    "${screenSize} ${screenSizePixel} [$width*$height]success: $success corners[${corners.length}]: $corners",
  );
  final radius = width / screenSizePixel.width;
  if (success) {
    return cv
        .drawChessboardCorners(image, patternSize, corners, true)
        .toImageBytes();

    /*return await drawImage(width, height, (canvas) async {
      canvas.drawImage(await image.toUiImage(), Offset.zero, Paint());
      for (final point in corners) {
        canvas.drawCircle(
          Offset(point.x, point.y),
          radius * 10,
          Paint()..color = Colors.red,
        );
      }
      */ /*canvas.drawLine(
        Offset(10, 10),
        Offset(100, 100),
        Paint()..color = Colors.red,
      );*/ /*
    }).then((image) => image.toBytes());*/
  } else {
    return image.toImageBytes();
  }
}

/// 测试相机标定
/*Future<Uint8List> testCalibrateCamera() async {
  cv.calibrateCamera(objectPoints, imagePoints, imageSize, cameraMatrix, distCoeffs)
}*/

/// 探测锐角
Future<Uint8List> testGoodFeaturesToTrack() async {
  final image = await loadAssetImage("lib/assets/grid.png");

  // 转换为灰度图
  final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

  //OpenCV(4.11.0) Error: Assertion failed (qualityLevel > 0 && minDistance >= 0 && maxCorners >= 0) in goodFeaturesToTrack
  final corners = cv.goodFeaturesToTrack(gray, 100, 0.5, 15);

  final width = image.width;
  final height = image.height;
  print(
    "${screenSize} ${screenSizePixel} [$width*$height]corners[${corners.length}]: $corners",
  );

  final radius = width / screenSizePixel.width;
  return await drawImage(width, height, (canvas) async {
    canvas.drawImage(await image.toUiImage(), Offset.zero, Paint());
    for (final point in corners) {
      canvas.drawCircle(
        Offset(point.x, point.y),
        radius * 10,
        Paint()..color = Colors.red,
      );
    }
  }).then((image) => image.toBytes());
}

/// 测试FAST 角点检测
Future<Uint8List> testFastFeatureDetector() async {
  final image = await loadAssetImage("lib/assets/grid.png");
  final detector = cv.FastFeatureDetector.create(threshold: 50);
  final keyPoints = detector.detect(image);

  final output = cv.Mat.empty();
  cv.drawKeyPoints(
    image,
    keyPoints,
    output,
    cv.Scalar.fromRgb(255, 0, 0),
    cv.DrawMatchesFlag.DRAW_RICH_KEYPOINTS,
  );

  return output.toImageBytes();
}

/// 分类器识别, 人脸位置探测
Future<Uint8List> testCascadeClassifier() async {
  // 分类器
  final faceFile = await saveAssetFileToCache(
    "lib/assets/haarcascades/haarcascade_frontalface_default.xml",
  );
  final eyeFile = await saveAssetFileToCache(
    "lib/assets/haarcascades/haarcascade_eye.xml",
  );
  final faceCascade = cv.CascadeClassifier.fromFile(faceFile.path);
  final eyeCascade = cv.CascadeClassifier.fromFile(eyeFile.path);

  //人头像图
  var image = await loadAssetImage("lib/assets/lena.jpg");
  image = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

  final width = image.width;
  final height = image.height;
  print("${screenSize} ${screenSizePixel} [$width*$height]");

  final faces = faceCascade.detectMultiScale(image);
  final eyes = eyeCascade.detectMultiScale(image);

  return await drawImage(width, height, (canvas) async {
    canvas.drawImage(await image.toUiImage(), Offset.zero, Paint());
    for (final face in faces) {
      canvas.drawRect(
        Rect.fromLTWH(
          face.x.toDouble(),
          face.y.toDouble(),
          face.width.toDouble(),
          face.height.toDouble(),
        ),
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke,
      );
    }
    for (final eye in eyes) {
      canvas.drawRect(
        Rect.fromLTWH(
          eye.x.toDouble(),
          eye.y.toDouble(),
          eye.width.toDouble(),
          eye.height.toDouble(),
        ),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke,
      );
    }
  }).then((image) => image.toBytes());
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
