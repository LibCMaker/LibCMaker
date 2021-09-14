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
LibCMaker_<LibName>/samples/ci_sample
```
and the compile commands for the different platforms in the
```
# A start point in CI
LibCMaker_<LibName>/.github/workflows/LibCMaker_CI.yml  
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

5. MSVC does not have the flags for C++11. MSVC 2015 Update 3 has ```/std:c++14``` and ```/std:c++latest```, no flags for C++ standard is used by default. MSVC 2017 has ```/std:c++14```, ```/std:c++17``` and ```/std:c++latest```, ```/std:c++14``` is used by default. If in the CMake project ```CXX_STANDARD=11``` then MSVC 2015 does not specify any C++ standard and MSVC 2017 specifies C++14. This affects to LibCMaker_Boost for the flag, which will or will not be passed to the 'b2' tool.

6. Dirent is tested only on Windows.

7. wxWidgets is tested on Linux, Windows and macOS.

8. LibCMaker_Boost does not work with OS X universal binaries, ```CMAKE_OSX_ARCHITECTURES``` must contain only one architecture.


## Known build issues

1. Boost is building without ICU for the Windows x64 static because of the failed test running with the following configurations: [Boost 1.68.0 | Boost 1.69.0], [ICU 58.2 | ICU 61.1 | ICU 63.1], [MSVC 2017 19.16.27023.1 | MSVC 2017 19.16.27026.1 | MSVC 2015 19.0.24241.7].

2. If Boost is building with MSVC 2015, then in the Boost.Build rule ```using msvc : [version] : [c++-compile-command] : [compiler options] ;``` can not be explicitly specified "c++-compile-command", build will be failed. This affects to LibCMaker_Boost, when one compiler detected by CMake is used for other CMake subprojects, and the compiler detected by the 'b2' tool is used for Boost (only in the case of using MSVC 2015). But they should be the same in the case of MSVC 2015.

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
 [LibCMaker_AGG](https://github.com/LibCMaker/LibCMaker_AGG) <br> [AGG site](http://www.antigrain.com/) | Disabled | GTest
[LibCMaker_Boost](https://github.com/LibCMaker/LibCMaker_Boost) <br> [Boost site](https://www.boost.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_Boost/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_Boost/actions/workflows/LibCMaker_CI.yml) | GTest, ICU
 [LibCMaker_Cairo](https://github.com/LibCMaker/LibCMaker_Cairo) <br> [Cairo site](https://www.cairographics.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_Cairo/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_Cairo/actions/workflows/LibCMaker_CI.yml) | GTest, zlib, libpng, Dirent (only for Windows), Expat, FreeType, FontConfig, Pixman
 [LibCMaker_Dirent](https://github.com/LibCMaker/LibCMaker_Dirent) <br> [Dirent site](https://github.com/tronkko/dirent) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_Dirent/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_Dirent/actions/workflows/LibCMaker_CI.yml) | Only for Windows, GTest
 [LibCMaker_Expat](https://github.com/LibCMaker/LibCMaker_Expat) <br> [Expat site](https://libexpat.github.io/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_Expat/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_Expat/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_fmt](https://github.com/LibCMaker/LibCMaker_fmt) <br> [{fmt} site](https://github.com/fmtlib/fmt) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_fmt/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_fmt/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_FontConfig](https://github.com/LibCMaker/LibCMaker_FontConfig) <br> [FontConfig site](https://www.fontconfig.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_FontConfig/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_FontConfig/actions/workflows/LibCMaker_CI.yml) | GTest, Dirent (only for Windows), Expat, FreeType
 [LibCMaker_FreeType](https://github.com/LibCMaker/LibCMaker_FreeType) <br> [FreeType site](https://www.freetype.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_FreeType/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_FreeType/actions/workflows/LibCMaker_CI.yml) | GTest, HarfBuzz
 [LibCMaker_GoogleTest](https://github.com/LibCMaker/LibCMaker_GoogleTest) <br> [GoogleTest site](https://github.com/google/googletest) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_GoogleTest/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_GoogleTest/actions/workflows/LibCMaker_CI.yml) |
 [LibCMaker_HarfBuzz](https://github.com/LibCMaker/LibCMaker_HarfBuzz) <br> [HarfBuzz site](http://www.harfbuzz.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_HarfBuzz/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_HarfBuzz/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_ICU](https://github.com/LibCMaker/LibCMaker_ICU) <br> [ICU site](http://site.icu-project.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_ICU/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_ICU/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_POCO](https://github.com/LibCMaker/LibCMaker_POCO) <br> [POCO site](https://pocoproject.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_POCO/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_POCO/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_Pixman](https://github.com/LibCMaker/LibCMaker_Pixman) <br> [Pixman site](http://www.pixman.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_Pixman/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_Pixman/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_spdlog](https://github.com/LibCMaker/LibCMaker_spdlog) <br> [spdlog site](https://github.com/gabime/spdlog) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_spdlog/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_spdlog/actions/workflows/LibCMaker_CI.yml) | GTest, {fmt}
 [LibCMaker_SQLite3](https://github.com/LibCMaker/LibCMaker_SQLite3) <br> [SQLite3 site](https://www.sqlite.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_SQLite3/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_SQLite3/actions/workflows/LibCMaker_CI.yml) | GTest, ICU
 [LibCMaker_SQLiteModernCPP](https://github.com/LibCMaker/LibCMaker_SQLiteModernCPP) <br> [SQLiteModernCPP site](https://github.com/SqliteModernCpp/sqlite_modern_cpp) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_SQLiteModernCPP/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_SQLiteModernCPP/actions/workflows/LibCMaker_CI.yml) | GTest, ICU, SQLite3
 [LibCMaker_STLCache](https://github.com/LibCMaker/LibCMaker_STLCache) <br> [STL::Cache site](https://github.com/akashihi/stlcache) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_STLCache/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_STLCache/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_libpng](https://github.com/LibCMaker/LibCMaker_libpng) <br> [libpng site](http://www.libpng.org/pub/png/libpng.html) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_libpng/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_libpng/actions/workflows/LibCMaker_CI.yml) | GTest, zlib
 [LibCMaker_litehtml](https://github.com/LibCMaker/LibCMaker_litehtml) <br> [litehtml site](http://www.litehtml.com/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_litehtml/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_litehtml/actions/workflows/LibCMaker_CI.yml) | GTest, gumbo (embedded)
 [LibCMaker_wxWidgets](https://github.com/LibCMaker/LibCMaker_wxWidgets) <br> [wxWidgets site](https://www.wxwidgets.org/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_wxWidgets/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_wxWidgets/actions/workflows/LibCMaker_CI.yml) | GTest
 [LibCMaker_zlib](https://github.com/LibCMaker/LibCMaker_zlib) <br> [zlib site](https://zlib.net/) | [![LibCMaker CI](https://github.com/LibCMaker/LibCMaker_zlib/actions/workflows/LibCMaker_CI.yml/badge.svg)](https://github.com/LibCMaker/LibCMaker_zlib/actions/workflows/LibCMaker_CI.yml) | GTest
