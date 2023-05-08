#ifndef FLUTTER_PLUGIN_FLUTTER_ZIP_ARCHIVE_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_ZIP_ARCHIVE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_zip_archive {

class FlutterZipArchivePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterZipArchivePlugin();

  virtual ~FlutterZipArchivePlugin();

  // Disallow copy and assign.
  FlutterZipArchivePlugin(const FlutterZipArchivePlugin&) = delete;
  FlutterZipArchivePlugin& operator=(const FlutterZipArchivePlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_zip_archive

#endif  // FLUTTER_PLUGIN_FLUTTER_ZIP_ARCHIVE_PLUGIN_H_
