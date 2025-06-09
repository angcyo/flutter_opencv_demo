# flutter_opencv_demo

A new Flutter opencv_dart project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# opencv_dart

https://pub.dev/packages/opencv_dart

https://github.com/rainyl/opencv_dart

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
				  + "-framework",
				  + "\"DartCvIOS\"",
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
