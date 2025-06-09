import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/09
///

class DemoWidget extends StatefulWidget {
  const DemoWidget({super.key});

  @override
  State<DemoWidget> createState() => _DemoWidgetState();
}

class _DemoWidgetState extends State<DemoWidget> {
  Future<(cv.Mat, cv.Mat)> heavyTaskAsync(cv.Mat im, {int count = 1000}) async {
    late cv.Mat gray, blur;
    for (var i = 0; i < count; i++) {
      gray = await cv.cvtColorAsync(im, cv.COLOR_BGR2GRAY);
      blur = await cv.gaussianBlurAsync(im, (7, 7), 2, sigmaY: 2);
      if (i != count - 1) {
        gray.dispose(); // manually dispose
        blur.dispose(); // manually dispose
      }
    }
    return (gray, blur);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Text(cv.getBuildInformation()));
  }
}
