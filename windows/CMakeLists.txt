# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

message(STATUS "Using CMake version ${CMAKE_VERSION}")

# Compatibility options
option(MZ_COMPAT "Enables compatibility layer" ON)
# Compression library options
option(MZ_ZLIB "Enables ZLIB compression" ON)
option(MZ_BZIP2 "Enables BZIP2 compression" OFF)
option(MZ_LZMA "Enables LZMA & XZ compression" OFF)
option(MZ_ZSTD "Enables ZSTD compression" OFF)
# Encryption support options
option(MZ_PKCRYPT "Enables PKWARE traditional encryption" ON)
option(MZ_WZAES "Enables WinZIP AES encryption" ON)
option(MZ_OPENSSL "Enables OpenSSL for encryption" OFF)
option(MZ_BCRYPT "Enables Win32 Crypto API Next Generation" OFF)
option(MZ_LIBBSD "Builds with libbsd crypto random" OFF)
option(MZ_SIGNING "Enables zip signing support" OFF)
# Character conversion options
option(MZ_ICONV "Enables iconv for string encoding conversion" OFF)
# Code generation options
option(MZ_COMPRESS_ONLY "Only support compression" OFF)
option(MZ_DECOMPRESS_ONLY "Only support decompression" OFF)
option(MZ_FILE32_API "Builds using posix 32-bit file api" OFF)

enable_language(C)

# Project-level configuration.
set(PROJECT_NAME "flutter_zip_archive")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_zip_archive_plugin")


# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "flutter_zip_archive_plugin.cpp"
  "flutter_zip_archive_plugin.h"
  "minizip/mz.h"
  "minizip/mz_crypt.h"
  "minizip/mz_os.h"
  "minizip/mz_strm.h"
  "minizip/mz_strm_buf.h"
  "minizip/mz_strm_mem.h"
  "minizip/mz_strm_split.h"
  "minizip/mz_strm_os.h"
  "minizip/mz_zip.h"
  "minizip/mz_zip_rw.h"
  "minizip/mz_strm_pkcrypt.h"
  "minizip/mz_strm_wzaes.h"
  "minizip/mz_strm_zlib.h"
  "minizip/mz_crypt.c"
  "minizip/mz_os.c"
  "minizip/mz_strm.c"
  "minizip/mz_strm_buf.c"
  "minizip/mz_strm_mem.c"
  "minizip/mz_strm_split.c"
  "minizip/mz_zip.c"
  "minizip/mz_zip_rw.c"
  "minizip/mz_os_win32.c"
  "minizip/mz_strm_os_win32.c"
  "minizip/mz_strm_pkcrypt.c"
  "minizip/mz_strm_wzaes.c"
  "minizip/mz_crypt_win32.c"
  "minizip/mz_strm_zlib.c"
  "zlib/zlib.h"
  "zlib/zconf.h"
  "zlib/crc32.h"
  "zlib/deflate.h"
  "zlib/gzguts.h"
  "zlib/inffast.h"
  "zlib/inffixed.h"
  "zlib/inflate.h"
  "zlib/inftrees.h"
  "zlib/trees.h"
  "zlib/zutil.h"
  "zlib/adler32.c"
  "zlib/compress.c"
  "zlib/crc32.c"
  "zlib/deflate.c"
  "zlib/gzclose.c"
  "zlib/gzlib.c"
  "zlib/gzread.c"
  "zlib/gzwrite.c"
  "zlib/inflate.c"
  "zlib/infback.c"
  "zlib/inftrees.c"
  "zlib/inffast.c"
  "zlib/trees.c"
  "zlib/uncompr.c"
  "zlib/zutil.c"
  )

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
        "include/flutter_zip_archive/flutter_zip_archive_plugin_c_api.h"
        "flutter_zip_archive_plugin_c_api.cpp"
        ${PLUGIN_SOURCES}
        )

set(MINIZIP_DEF)

# Platform specific
if(WIN32)
    list(APPEND MINIZIP_DEF -D_CRT_SECURE_NO_DEPRECATE)
    set(MZ_LIBBSD OFF)
    set(MZ_ICONV OFF)
endif()

# Setup predefined macros
if(MZ_COMPRESS_ONLY)
    list(APPEND MINIZIP_DEF -DMZ_ZIP_NO_DECOMPRESSION)
endif()
if(MZ_DECOMPRESS_ONLY)
    list(APPEND MINIZIP_DEF -DMZ_ZIP_NO_COMPRESSION)
endif()
if(NOT MZ_PKCRYPT AND NOT MZ_WZAES)
    list(APPEND MINIZIP_DEF -DMZ_ZIP_NO_ENCRYPTION)
endif()
if(MZ_SIGNING)
    list(APPEND MINIZIP_DEF -DMZ_ZIP_SIGNING)
endif()
if(MZ_ZLIB)
    list(APPEND MINIZIP_DEF -DHAVE_ZLIB)
endif()

# Include traditional PKWare encryption
if(MZ_PKCRYPT)
    list(APPEND MINIZIP_DEF -DHAVE_PKCRYPT)
endif()

# Include WinZIP AES encryption
if(MZ_WZAES)
    list(APPEND MINIZIP_DEF -DHAVE_WZAES)
endif()

# Set compiler options
if(MZ_CODE_COVERAGE)
    if(NOT MSVC)
        message(STATUS "Code coverage enabled")
        add_compile_options(-O0 -g -fprofile-arcs -ftest-coverage)
        if(CMAKE_C_COMPILER_ID MATCHES "(Apple)?[Cc]lang")
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
        elseif(CMAKE_C_COMPILER_ID MATCHES "GNU")
            link_libraries(gcov)
        endif()
        set_property(DIRECTORY PROPERTY
                GCC_INSTRUMENT_PROGRAM_FLOW_ARCS YES
                GCC_GENERATE_TEST_COVERAGE_FILES YES)
    else()
        set(MZ_CODE_COVERAGE OFF)
    endif()
else()
    if(MSVC)
        add_compile_options($<$<CONFIG:Debug>:/W3>)
    else()
        add_compile_options($<$<CONFIG:Debug>:-Wall>)
    endif()
endif()

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL ${MINIZIP_DEF})

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin PUBLIC crypt32.lib)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(flutter_zip_archive_bundled_libraries
  ""
  PARENT_SCOPE
)
