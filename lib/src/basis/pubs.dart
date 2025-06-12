import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'basis.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/12
///

/// 获取缓存目录
Future<Directory> getCacheDir() => getTemporaryDirectory();

/// 获取一个缓存文件路径
Future<File> getCacheFile(String fileName) async =>
    File('${(await getCacheDir()).path}/$fileName');

/// 将assets文件保存到缓存目录上, 并返回缓存的文件路径
Future<File> saveAssetFileToCache(String assetFilePath) async {
  final file = await getCacheFile(assetFilePath.split('/').last);
  return file.writeAsBytes(await loadAssetBytes(assetFilePath));
}