# flutter_opencv_demo

- [OpenCV Releases](https://opencv.org/releases/)
- [chessboard.png](https://github.com/opencv/opencv/blob/4.12.0/samples/data/chessboard.png)

# opencv_dart

https://pub.dev/packages/opencv_dart

https://github.com/rainyl/opencv_dart

## Android `minSdk 24`

`tools:overrideLibrary="dev.rainyl.opencv_dart"`

```diff
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
+   xmlns:tools="http://schemas.android.com/tools">
+  
+    <!-- 添加 tools:overrideLibrary 属性 -->
+    <uses-sdk tools:overrideLibrary="dev.rainyl.opencv_dart" />
  ...
</manifest>
```

## iOS

- 需要`ruby` > `3.0+`. `brew install ruby`

### 更新`ruby`

`ruby 3.4.4 (2025-05-14 revision a38531fd3f) +PRISM [arm64-darwin24]`

```shell
brew update
brew upgrade ruby

source ~/.zshrc && ruby -v
```
https://cocoapods.org/

```
sudo gem update cocoapods

pod --version
1.16.2

pod install
```

### 添加 `Other Linker Flags`

`TARGETS`->`Runner`->`Build Settings`->`Linking - General`->`Other Linker Flags`

添加 `-framework` `DartCvIOS`.

```diff
OTHER_LDFLAGS = (
					"$(inherited)",
					"-ObjC",
					"-l\"c++\"",
					"-framework",
					"\"AVFoundation\"",
					"-framework",
					"\"Accelerate\"",
					"-framework",
					"\"AssetsLibrary\"",
					"-framework",
					"\"CoreGraphics\"",
					"-framework",
					"\"CoreImage\"",
					"-framework",
					"\"CoreMedia\"",
					"-framework",
					"\"CoreVideo\"",
+				    "-framework",
+				    "\"DartCvIOS\"",
					"-framework",
					"\"Foundation\"",
					"-framework",
					"\"QuartzCore\"",
					"-framework",
					"\"UIKit\"",
					"-framework",
					"\"image_picker_ios\"",
				);
```
