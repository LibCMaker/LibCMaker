# LibCMaker

LibCMaker is the build system based on the CMake.

At the moment, the assembly of all libraries is tested for Linux, Windows, Android, macOS and iOS (also see notes below).

The repository contains a common LibCMaker build scripts.

## Some explanations

At the stage of the configuring of the main project by CMake, the following steps are performed:

1. The library sources are downloading from the official library sources.

2. The library is compiling.

3. The library is installing.

4. The library is finding by the CMake command ```find_package(<LibName>)``` in the main CMake project.

For the examples of the usage please see the samples in the
```
<LibName>_LibCMaker/samples/ci_sample
```
and the compile commands for the different platforms in the
```
# A start point in CI
<LibName>_LibCMaker/.github/workflows/LibCMaker_CI.yml  
# Main build script
LibCMaker/ci/ci_build.sh
# Scripts for platforms
LibCMaker/ci/ci_build_<platform name>.sh
# Script for run ci_build.sh locally
LibCMaker/samples/run-build-LibCMaker-ci-sample.sh
```

## Notes and requirements

1. LibCMaker requires CMake 3.15+ for iOS ("Xcode" generator) and CMake 3.9+ for others.

2. ICU requires CMake 3.11+ for "Visual Studio" generator, CMake 3.12+ for "Xcode" generator and 3.4+ for others.

3. wxWidgets requires CMake 3.5+ for MSVC and MinGW-w64, CMake 3.12+ for "Xcode" generator, CMake 3.10+ is recommended by developers of wxWidgets.

4. Android NDK r18+ does not have ```std::experimental``` namespace for C++14. This affects to Boost and SQLiteModernCPP. In this case Boost can be comppiled with C++11 and C++17, SQLiteModernCPP can be compiled only with C++17. C++17 requires CMake 3.8+ and ```CXX_STANDARD=17```.

5. MSVC does not have the flags for C++11. MSVC 2015 Update 3 has ```/std:c++14``` and ```/std:c++latest```, no flags for C++ standard is used by default. MSVC 2017 has ```/std:c++14```, ```/std:c++17``` and ```/std:c++latest```, ```/std:c++14``` is used by default. If in the CMake project ```CXX_STANDARD=11``` then MSVC 2015 does not specify any C++ standard and MSVC 2017 specifies C++14. This affects to Boost_LibCMaker for the flag, which will or will not be passed to the 'b2' tool.

6. Dirent is tested only on Windows.

7. wxWidgets is tested on Linux, Windows and macOS.

8. Boost_LibCMaker does not work with OS X universal binaries, ```CMAKE_OSX_ARCHITECTURES``` must contain only one architecture.


## Known build issues

1. Boost is building without ICU for the Windows x64 static because of the failed test running with the following configurations: [Boost 1.68.0 | Boost 1.69.0], [ICU 58.2 | ICU 61.1 | ICU 63.1], [MSVC 2017 19.16.27023.1 | MSVC 2017 19.16.27026.1 | MSVC 2015 19.0.24241.7].

2. If Boost is building with MSVC 2015, then in the Boost.Build rule ```using msvc : [version] : [c++-compile-command] : [compiler options] ;``` can not be explicitly specified "c++-compile-command", build will be failed. This affects to Boost_LibCMaker, when one compiler detected by CMake is used for other CMake subprojects, and the compiler detected by the 'b2' tool is used for Boost (only in the case of using MSVC 2015). But they should be the same in the case of MSVC 2015.

3. Boost.Container building is skipped on macOS and iOS for CMake generator "Unix Makefiles".


## Notes about CMake

1. If the ```cmake_minimum_required()``` command has a version lower than 3.0, CMake does not set ```@rpath``` in the shared libraries on macOS, see [CMP0042](https://cmake.org/cmake/help/latest/policy/CMP0042.html). About RPATH with CMake see [RPATH handling](https://gitlab.kitware.com/cmake/community/wikis/doc/cmake/RPATH-handling).

2. CMake 3.14 contains a bug on iOS for ```CMAKE_FIND_ROOT_PATH_*``` variables. Use CMake 3.15+ for iOS.

3. CMake 3.8 - 3.11 sets the compiler flag ```-std=gnu++1z``` for C++17 for GCC and Clang, CMake 3.12+ sets the compiler flag ```-std=gnu++17```.

4. Target property LINK_WHAT_YOU_USE does not work for MINGW (```Error running 'ldd': The system cannot find the file specified```) and for generator "Unix Makefiles" on APPLE (```ld: unknown option: --no-as-needed```).


## Notes about Android emulator

1. 'arm64-v8a' emulator (any API level) does not start on Linux and Windows with success, boot animation is not ending.

2. 'armeabi-v7a' API 16 emulator on Linux executes programs regularly with "Illegal instruction". API 24 on Linux works fine.

3. 'x86' API 24 emulator does not start on Linux with success. API 23 on Linux works fine.

4. Emulator has ```tar``` commad since API 23, ```adb shell tar```, it is used in the testing.


## Notes about CI building and testing

1. The simple tests with Google Test are compiling and running (Linux, Windows, macOS, Android with emulator, iOS with simulator) for testing the library work on the target platform.

-- TODO: Is not actually 2. SQLite3 is building on CI with ICU on Linux, Windows and macOS only. But technically the building is possible for Android and iOS too, see the Boost building with ICU.

-- TODO: Is not actually 3. FreeType may be built with HarfBuzz for Cairo and FontConfig too. But is not releasing on CI. See the FreeType building with HarfBuzz.


## CI build configurations

All libraries are tested with GitHub Actions.

Following configurations are:

1. Linux -- Ubuntu Bionic 18.04, CMake 3.21.2, Make, Matrix: [GCC 11 | Clang 12], [Debug | Release], [shared | static].

2. macOS -- Mac OS X 10.15, CMake 3.21.2, Xcode 12.4, Apple Clang 12, Matrix: CMake generator ["Xcode" | "Unix Makefiles"], [Debug | Release], [shared | static].

3. Windows, MSVC -- Windows Server 2016, CMake 3.21.2, MSVC 2017, Matrix: [Debug | Release], [x64 | x32 | WinXP], [shared | static].

4. Windows, MinGW-w64 -- Windows Server 2016, CMake 3.21.2, MinGW-w64 9.0.0, Matrix: [ GCC 11 | Clang 12 ], [Debug | Release], [x86_64 | i686], [shared | static].

5. Android on Linux -- Ubuntu Bionic 18.04, CMake 3.21.2, Android NDK r23, Clang 12.0.5, Ninja, Matrix: [Debug | Release], [shared + c++_shared | static + c++_static], [armeabi-v7a + API 16 | arm64-v8a + API 21 | x86 + API 16 | x86_64 + API 21].

6. Android on Windows -- Windows Server 2016, CMake 3.21.2, Android NDK r22 (with NDK r23 on Windows, CMake can not find a compiler), Clang 12.0.5, Ninja, Matrix: [Debug | Release], [shared + c++_shared | static + c++_static], [armeabi-v7a + API 16 | arm64-v8a + API 21 | x86 + API 16 | x86_64 + API 21].

7. iOS -- Mac OS X 10.15, CMake 3.21.2, Xcode 12.4, Apple Clang 12, SDK iPhoneSimulator<TODO version>, platform SIMULATOR64, CMake generator "Xcode", Matrix: [Debug | Release], [shared | static].


## CI build status

 *Library*   | *GitHub Actions* <br> Linux <br> macOS <br> Windows_MSVC <br> Windows_MinGW_w64 <br> Android_on_Linux <br> Android_on_Windows <br> iOS | *Built with dependencies*
 ----------- | ---------------------------------------------------------------------------------------------------------------------------------------- | -------------------------
 [GoogleTest_LibCMaker](https://github.com/LibCMaker/GoogleTest_LibCMaker) <br> [GoogleTest site](https://github.com/google/googletest) | [![LibCMaker CI](https://github.com/LibCMaker/GoogleTest_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/GoogleTest_LibCMaker/actions/workflows/LibCMaker_CI.yml) |
 [ICU_LibCMaker](https://github.com/LibCMaker/ICU_LibCMaker) <br> [ICU site](https://icu.unicode.org/) | [![LibCMaker CI](https://github.com/LibCMaker/ICU_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/ICU_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [POCO_LibCMaker](https://github.com/LibCMaker/POCO_LibCMaker) <br> [POCO site](https://pocoproject.org/) | [![LibCMaker CI](https://github.com/LibCMaker/POCO_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/POCO_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [RmlUi_LibCMaker](https://github.com/LibCMaker/RmlUi_LibCMaker) <br> [RmlUi site](https://github.com/mikke89/RmlUi) | [![LibCMaker CI](https://github.com/LibCMaker/RmlUi_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/RmlUi_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, Skia
 [SDL3_LibCMaker](https://github.com/LibCMaker/SDL3_LibCMaker) <br> [SDL3 site](https://libsdl.org/) | [![LibCMaker CI](https://github.com/LibCMaker/SDL3_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/SDL3_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, Skia
 [SQLiteCpp_LibCMaker](https://github.com/LibCMaker/SQLiteCpp_LibCMaker) <br> [SQLite3 site](https://www.sqlite.org/) <br> [SQLiteCpp site](https://github.com/SRombauts/SQLiteCpp) | [![LibCMaker CI](https://github.com/LibCMaker/SQLiteCpp_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/SQLiteCpp_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, ICU
 [Skia_LibCMaker](https://github.com/LibCMaker/Skia_LibCMaker) <br> [Skia site](https://skia.org/) | [![LibCMaker CI](https://github.com/LibCMaker/Skia_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Skia_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, (Embedded: DNG SDK, Expat, FreeType, HarfBuzz, ICU, libjpeg, piex, libpng, libsvg, libwebp, zlib)
 [fmt_LibCMaker](https://github.com/LibCMaker/fmt_LibCMaker) <br> [{fmt} site](https://github.com/fmtlib/fmt) | [![LibCMaker CI](https://github.com/LibCMaker/fmt_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/fmt_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [litehtml_LibCMaker](https://github.com/LibCMaker/litehtml_LibCMaker) <br> [litehtml site](http://www.litehtml.com/) | [![LibCMaker CI](https://github.com/LibCMaker/litehtml_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/litehtml_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, gumbo (embedded)
 [spdlog_LibCMaker](https://github.com/LibCMaker/spdlog_LibCMaker) <br> [spdlog site](https://github.com/gabime/spdlog) | [![LibCMaker CI](https://github.com/LibCMaker/spdlog_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/spdlog_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, {fmt}
 ------- | ------- | -------
 [AGG_LibCMaker](https://github.com/LibCMaker/AGG_LibCMaker) <br> [AGG site](http://www.antigrain.com/) | Disabled | GTest
 [Boost_LibCMaker](https://github.com/LibCMaker/Boost_LibCMaker) <br> [Boost site](https://www.boost.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/Boost_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Boost_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, ICU
 [Cairo_LibCMaker](https://github.com/LibCMaker/Cairo_LibCMaker) <br> [Cairo site](https://www.cairographics.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/Cairo_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Cairo_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, zlib, libpng, Dirent (only for Windows), Expat, FreeType, FontConfig, Pixman
 [Dirent_LibCMaker](https://github.com/LibCMaker/Dirent_LibCMaker) <br> [Dirent site](https://github.com/tronkko/dirent) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/Dirent_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Dirent_LibCMaker/actions/workflows/LibCMaker_CI.yml) | Only for Windows, GTest
 [Expat_LibCMaker](https://github.com/LibCMaker/Expat_LibCMaker) <br> [Expat site](https://libexpat.github.io/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/Expat_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Expat_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [FontConfig_LibCMaker](https://github.com/LibCMaker/FontConfig_LibCMaker) <br> [FontConfig site](https://www.fontconfig.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/FontConfig_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/FontConfig_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, Dirent (only for Windows), Expat, FreeType
 [FreeType_LibCMaker](https://github.com/LibCMaker/FreeType_LibCMaker) <br> [FreeType site](https://www.freetype.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/FreeType_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/FreeType_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, HarfBuzz
 [HarfBuzz_LibCMaker](https://github.com/LibCMaker/HarfBuzz_LibCMaker) <br> [HarfBuzz site](http://www.harfbuzz.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/HarfBuzz_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/HarfBuzz_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [Pixman_LibCMaker](https://github.com/LibCMaker/Pixman_LibCMaker) <br> [Pixman site](http://www.pixman.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/Pixman_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/Pixman_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [STLCache_LibCMaker](https://github.com/LibCMaker/STLCache_LibCMaker) <br> [STL::Cache site](https://github.com/akashihi/stlcache) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/STLCache_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/STLCache_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [libpng_LibCMaker](https://github.com/LibCMaker/libpng_LibCMaker) <br> [libpng site](http://www.libpng.org/pub/png/libpng.html) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/libpng_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/libpng_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest, zlib
 [wxWidgets_LibCMaker](https://github.com/LibCMaker/wxWidgets_LibCMaker) <br> [wxWidgets site](https://www.wxwidgets.org/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/wxWidgets_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/wxWidgets_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
 [zlib_LibCMaker](https://github.com/LibCMaker/zlib_LibCMaker) <br> [zlib site](https://zlib.net/) | Disabled [![LibCMaker CI](https://github.com/LibCMaker/zlib_LibCMaker/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/zlib_LibCMaker/actions/workflows/LibCMaker_CI.yml) | GTest
