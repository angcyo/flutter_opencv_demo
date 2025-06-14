import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_opencv_demo/src/basis/opencv.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

import '../basis/ui.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/11
///
class Calib3dDemo extends StatefulWidget {
  const Calib3dDemo({super.key});

  @override
  State<Calib3dDemo> createState() => _Calib3dDemoState();
}

class _Calib3dDemoState extends State<Calib3dDemo> with StopwatchMixin {
  Uint8List? tempImageBytes;
  List<Uint8List>? tempImageBytesList;

  @override
  Widget build(BuildContext context) {
    //cv.findChessboardCorners(image, patternSize)

    return Scaffold(
      appBar: AppBar(title: const Text('Calib3dDemo')),
      body: SingleChildScrollView(
        physics: kScrollPhysics,
        child: Column(
          children: [
            //const Center(child: Text('Calib3dDemo')),
            //Image.asset("lib/assets/chessboard.png"),
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: [
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("获取棋盘角点", () async {
                      tempImageBytes = await testChessboardCorners();
                    });
                  },
                  child: Text("获取棋盘角点"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("探测锐角", () async {
                      tempImageBytes = await testGoodFeaturesToTrack();
                    });
                  },
                  child: Text("探测锐角"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("测试FAST角点检测", () async {
                      tempImageBytes = await testFastFeatureDetector();
                    });
                  },
                  child: Text("测试FAST角点检测"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("人脸检测", () async {
                      tempImageBytes = await testCascadeClassifier();
                    });
                  },
                  child: Text("人脸检测"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("相机标定", () async {
                      tempImageBytesList = await testCalibrateCamera();
                    });
                  },
                  child: Text("相机标定"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("测试透视变换(perspective)", () async {
                      tempImageBytesList = await testPerspectiveTransform();
                    });
                  },
                  child: Text("测试透视变换(perspective)"),
                ),
                FilledButton(
                  onPressed: () {
                    wrapStopwatch("测试Homography透视(perspective)", () async {
                      tempImageBytesList = await testHomographyPerspective();
                    });
                  },
                  child: Text("测试Homography透视(perspective)"),
                ),
                FilledButton(
                  onPressed: () {
                    tempImageBytes = null;
                    tempImageBytesList = null;
                    setState(() {});
                  },
                  child: Text("clear"),
                ),
                FilledButton(
                  onPressed: () async {
                    //tempImageBytes = await test();
                    tempImageBytes = await testChessboardCorners();
                    setState(() {});
                  },
                  child: Text("test"),
                ),
              ],
            ),
            if (tempImageBytes != null)
              Image.memory(tempImageBytes!, fit: BoxFit.fill),
            if (tempImageBytesList != null)
              Wrap(
                children: [
                  for (var item in tempImageBytesList!)
                    SizedBox(
                      width: screenSize.width / 2,
                      child: Image.memory(item, fit: BoxFit.fill),
                    ),
                ],
              ),
            if (stopwatchText != null) Text(stopwatchText!),
            SafeArea(top: false, child: SizedBox(height: 0)),
          ],
        ),
      ),
    );
  }
}
