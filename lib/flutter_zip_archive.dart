
import 'flutter_zip_archive_platform_interface.dart';

class FlutterZipArchive {
  Future<String?> getPlatformVersion() {
    return FlutterZipArchivePlatform.instance.getPlatformVersion();
  }
  Future<String?> zip(String src, String dest, String password) {
    return FlutterZipArchivePlatform.instance.zip(src,dest,password);
  }
}
