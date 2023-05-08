import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_zip_archive_method_channel.dart';

abstract class FlutterZipArchivePlatform extends PlatformInterface {
  /// Constructs a FlutterZipArchivePlatform.
  FlutterZipArchivePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterZipArchivePlatform _instance = MethodChannelFlutterZipArchive();

  /// The default instance of [FlutterZipArchivePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterZipArchive].
  static FlutterZipArchivePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterZipArchivePlatform] when
  /// they register themselves.
  static set instance(FlutterZipArchivePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> zip(String src, String dest, String password) {
    throw UnimplementedError('zip() has not been implemented.');
  }
}
