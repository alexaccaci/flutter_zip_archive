#include "include/flutter_zip_archive/flutter_zip_archive_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_zip_archive_plugin.h"

void FlutterZipArchivePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_zip_archive::FlutterZipArchivePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
