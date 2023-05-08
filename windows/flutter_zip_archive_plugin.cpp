#include "flutter_zip_archive_plugin.h"
#include "minizip/mz.h"
#include "minizip/mz_os.h"
#include "minizip/mz_strm.h"
#include "minizip/mz_strm_buf.h"
#include "minizip/mz_strm_split.h"
#include "minizip/mz_zip.h"
#include "minizip/mz_zip_rw.h"


// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <stdio.h>


namespace flutter_zip_archive {

// Looks for |key| in |map|, returning the associated value if it is present, or
// a nullptr if not.
const char* ValueOrNull(const flutter::EncodableMap& map, const char* key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it == map.end()) {
    return NULL;
  }
  const std::string* val = std::get_if<std::string>(&it->second);
  return (*val).c_str();
}

// static
void FlutterZipArchivePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_zip_archive",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterZipArchivePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterZipArchivePlugin::FlutterZipArchivePlugin() {}

FlutterZipArchivePlugin::~FlutterZipArchivePlugin() {}

void FlutterZipArchivePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("zip") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    const char* src = ValueOrNull(*args, "src");
    const char* dest = ValueOrNull(*args, "dest");
    const char* pass = ValueOrNull(*args, "password");
    void *writer = NULL;
    int32_t err = MZ_OK;

    mz_zip_writer_create(&writer);
    mz_zip_writer_set_password(writer, pass);
    mz_zip_writer_set_compress_method(writer, MZ_COMPRESS_METHOD_DEFLATE);
    mz_zip_writer_set_compress_level(writer, MZ_COMPRESS_LEVEL_DEFAULT);
    err = mz_zip_writer_open_file(writer, dest, 0, 0);
    if (err != MZ_OK) {
        mz_zip_writer_delete(&writer);
        result->Error("Could not open zip file for writing.");
        return;
    }
    err = mz_zip_writer_add_path(writer, src, NULL, 0, 0);
    mz_zip_writer_close(writer);
    mz_zip_writer_delete(&writer);
    if (err != MZ_OK)
        result->Error("Failed to add file to the archive.");
    else
        result->Success(flutter::EncodableValue("Success"));
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_zip_archive
