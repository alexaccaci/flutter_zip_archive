import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_zip_archive_platform_interface.dart';

/// An implementation of [FlutterZipArchivePlatform] that uses method channels.
class MethodChannelFlutterZipArchive extends FlutterZipArchivePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_zip_archive');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> zip(String src, String dest, String password) async {
    return await methodChannel.invokeMethod<String>(
        'zip', <String, dynamic>{"src": src, "dest": dest, "password": password});
  }
}
