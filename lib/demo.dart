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

  void test_image() async {
    /*final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final path = img.path;
      final mat = cv.imread(path);
      print("cv.imread: width: ${mat.cols}, height: ${mat.rows}, path: $path");
      debugPrint("mat.data.length: ${mat.data.length}");
      // heavy computation
      final (gray, blur) = await heavyTaskAsync(mat, count: 1);
      setState(() {
        images = [
          cv.imencode(".png", mat).$2,
          cv.imencode(".png", gray).$2,
          cv.imencode(".png", blur).$2,
        ];
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Text(cv.getBuildInformation()));
  }
}
