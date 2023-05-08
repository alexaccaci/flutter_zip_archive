import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zip_archive/flutter_zip_archive.dart';
import 'package:flutter_zip_archive/flutter_zip_archive_platform_interface.dart';
import 'package:flutter_zip_archive/flutter_zip_archive_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterZipArchivePlatform
    with MockPlatformInterfaceMixin
    implements FlutterZipArchivePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> zip(String src, String dest, String password)  => Future.value('43');
}

void main() {
  final FlutterZipArchivePlatform initialPlatform = FlutterZipArchivePlatform.instance;

  test('$MethodChannelFlutterZipArchive is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterZipArchive>());
  });

  test('getPlatformVersion', () async {
    FlutterZipArchive flutterZipArchivePlugin = FlutterZipArchive();
    MockFlutterZipArchivePlatform fakePlatform = MockFlutterZipArchivePlatform();
    FlutterZipArchivePlatform.instance = fakePlatform;

    expect(await flutterZipArchivePlugin.getPlatformVersion(), '42');
  });
}
