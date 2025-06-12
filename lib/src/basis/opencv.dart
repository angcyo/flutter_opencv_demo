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
///
/// https://docs.opencv.org/4.11.0/d9/d0c/group__calib3d.html#ga93efa9b0aa890de240ca32b11253dd4a
Future<Uint8List> testChessboardCorners() async {
  // final image = await loadAssetImage("lib/assets/chessboard.png"); // 6,9
  // final patternSize = (6, 9);
  //final image = await loadAssetImage("lib/assets/left07.jpg"); //7,6
  //final patternSize = (7, 6);
  //final image = await loadAssetImage("lib/assets/left04.jpg"); //9,6
  //final patternSize = (9, 6);
  //final image = await loadAssetImage("lib/assets/left05.jpg"); //9,6
  //final patternSize = (9, 6);
  //final image = await loadAssetImage("lib/assets/left09.jpg"); //9,6
  //final patternSize = (9, 6);
  final image = await loadAssetImage("lib/assets/left11.jpg"); //9,6
  final patternSize = (9, 6);

  //final image = await loadAssetImage("lib/assets/grid.png");
  //final patternSize = (10, 10);

  final width = image.width;
  final height = image.height;
  // Error: One of the arguments' values is out of range (Both width and height of the pattern should have bigger than 2) in findChessboardCorners
  final (success, corners) = cv.findChessboardCorners(image, patternSize);

  //cv.cornerSubPix(image, corners, (7, 7), (width, height));

  print(
    "$screenSize $screenSizePixel [$width*$height]success: $success corners[${corners.length}]: $corners",
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
/// https://docs.opencv.org/4.11.0/d9/d0c/group__calib3d.html
/// https://docs.opencv.org/4.11.0/d9/d0c/group__calib3d.html#ga687a1ab946686f0d85ae0363b5af1d7b
/// https://docs.opencv.org/4.11.0/dc/dbb/tutorial_py_calibration.html
Future<List<Uint8List>> testCalibrateCamera() async {
  final imageKeys = [
    "left01.jpg",
    "left02.jpg",
    "left03.jpg",
    //"left04.jpg", //9,6
    //"left05.jpg", //9,6
    "left06.jpg",
    "left07.jpg",
    "left08.jpg",
    //"left09.jpg", //9,6
    //"left11.jpg", //9,6
    "left12.jpg",
    "left13.jpg",
    "left14.jpg",
  ];
  final patternSize = (7, 6);
  final imageSize = (640, 480);

  final resultImages = <Uint8List>[];

  //objpoints = [] # 3d point in real world space
  //imgpoints = [] # 2d points in image plane.

  List<List<cv.Point3f>> objectPoints = [];
  List<List<cv.Point2f>> imagePoints = [];

  for (final imageKey in imageKeys) {
    //原图
    final image = await loadAssetImage("lib/assets/$imageKey");
    //灰度化
    final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

    final width = image.width;
    final height = image.height;
    // Error: One of the arguments' values is out of range (Both width and height of the pattern should have bigger than 2) in findChessboardCorners
    final (success, corners) = cv.findChessboardCorners(gray, patternSize);

    //cv.cornerSubPix(image, corners, (7, 7), (width, height));

    print(
      "$screenSize $screenSizePixel [$width*$height]success: $success corners[${corners.length}]: $corners",
    );

    if (success) {
      final corners2 = cv.cornerSubPix(gray, corners, patternSize, (0, 0));

      List<cv.Point3f> objectPoints2 = [];

      for (var r = 0; r < patternSize.$2; r++) {
        for (var c = 0; c < patternSize.$1; c++) {
          objectPoints2.add(cv.Point3f(r * 10, c * 10, 0));
        }
      }
      objectPoints.add(objectPoints2);
      imagePoints.add(corners2.toList());

      //--
      var index = 0;
      for (var item in corners2) {
        cv.putText(
          image,
          "$index",
          cv.Point(item.x.toInt(), item.y.toInt()),
          0,
          0.5,
          cv.Scalar.fromRgb(255, 0, 0),
        );
        index++;
      }
      final bytes = cv
          .drawChessboardCorners(image, patternSize, corners2, success)
          .toImageBytes();

      print("corners2[${corners2.length}]: $corners2");

      resultImages.add(bytes);
    }
  }

  print("objectPoints:$objectPoints");

  //Calibration 校准
  final (rmsErr, cameraMatrix, distCoeffs, rvecs, tvecs) = cv.calibrateCamera(
    cv.Contours3f.fromList(objectPoints),
    cv.Contours2f.fromList(imagePoints),
    imageSize,
    cv.Mat.empty(),
    cv.Mat.empty(),
  );

  print("cameraMatrix:$cameraMatrix distCoeffs:$distCoeffs");

  //外部参数
  //cameraMatrix row:0 [2581.090997341589, 0.0, 171.50912847939773]
  //cameraMatrix row:1 [0.0, 19901.884251272128, 1198.9473867455404]
  //cameraMatrix row:2 [0.0, 0.0, 1.0]
  cameraMatrix.forEachRow((row, values) {
    print("cameraMatrix row:$row $values");
  });

  //失真系数
  //distCoeffs row:0 [-46.0553240737217, 1280.838621620429, 0.335834781625168, 0.9000246408904069, -11745.693298991113]
  distCoeffs.forEachRow((row, values) {
    print("distCoeffs row:$row $values");
  });

  //debugger();
  /*final (rval, validPixROI) = cv.getOptimalNewCameraMatrix(
    cameraMatrix,
    distCoeffs,
    imageSize,
    1,
    newImgSize: imageSize,
  );
  //rval row:0 [765.2722238923136, 0.0, 429.19259733028036]
  //rval row:1 [0.0, 989.7426417336067, 514.8037771434226]
  //rval row:2 [0.0, 0.0, 1.0]
  rval.forEachRow((row, values) {
    print("rval row:$row $values");
  });
  //validPixROI:Rect(0, 0, 0, 0)
  print("validPixROI:$validPixROI");*/

  //undistort 去畸变
  final image = await loadAssetImage("lib/assets/left12.jpg");
  final dst = cv.undistort(
    image,
    cameraMatrix,
    distCoeffs /*newCameraMatrix: rval*/,
  );

  //
  resultImages.add(image.toImageBytes());
  resultImages.add(dst.toImageBytes());

  //Re-projection Error  重投影误差
  /*var meanError = 0;
  for (var i = 0; i < objectPoints.length; i++) {
    final imgpoints2 = cv.projectPoints(
      cv.VecPoint3f.fromList(objectPoints[i]),
      rvecs[i],
      tvecs[i],
      cameraMatrix,
      distCoeffs,
    );
    final error = cv.norm(
      imagePoints[i],
      imgpoints2,
      cv.NORM_L2,
    );
    meanError += error / objectPoints[i].length;
  }
  */ /*for i in range(len(objpoints)):
  imgpoints2, _ = cv.projectPoints(objpoints[i], rvecs[i], tvecs[i], mtx, dist)
  error = cv.norm(imgpoints[i], imgpoints2, cv.NORM_L2)/len(imgpoints2)
  mean_error += error*/ /*
  print("total error: {}".format(mean_error / len(objpoints)))*/

  return resultImages;
}

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
    "$screenSize $screenSizePixel [$width*$height]corners[${corners.length}]: $corners",
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

  final faces = faceCascade.detectMultiScale(image);
  final eyes = eyeCascade.detectMultiScale(image);

  print(
    "$screenSize $screenSizePixel [$width*$height] faces: $faces eyes: $eyes",
  );

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
