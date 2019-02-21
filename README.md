# LibCMaker

LibCMaker is the build system based on the CMake.

At the moment, the assembly of all libraries is tested for Linux, Windows and Android (also see notes below).

The repository contains a common LibCMaker build scripts.

## Some explanations

At the stage of the configuring of the main project by CMake, the following steps are performed:

1. The library sources are downloading from the official library sources.

2. Library is compiling.

3. Library is installing.

4. Library is finding by the CMake command find_package(<LibName>) in the main CMake project.

For the examples of the usage please see the samples in the
```
LibCMaker_<LibName>/samples/TestCompileWith<LibName>
```
and the compile commands for the different platforms in the
```
LibCMaker_<LibName>/.travis.yml
```

## Notes

1. Dirent is tested only on Windows.

2. wxWidgets is tested only on Linux and on Windows.

3. SQLiteModernCPP requires CMake 3.8+ and CXX_STANDARD=17+ for Android NDK r18+.


## Known build issues

1. The shared Windows build for AGG is not released.

2. If Boost is building with the ICU for Android and Windows, then the message "has_icu......yes" is not displayed due to the patch of the file '(boost-src)/libs/regex/build/Jamfile.v2'.

3. Boost is building without ICU on Travis CI for the static Windows x64 due to the failed test running on Travis CI with the following configuration: Boost 1.68.0, ICU 61.1 or 58.2, Windows Server 1803, MSVC 19.16.27023.1. Test running is successful on the machine with Windows 7 Pro SP1 x64 (6.1.7601) and MSVC 19.16.27023.1.


## Build status

All libraries with Travis CI are tested in the following configurations:

Linux -- Ubuntu Xenial 16.04, CMake 3.4.0, Make, Matrix: [GCC 5.4.0 | Clang 7.0.0], [Debug | Release], [shared | static].

Windows -- Windows Server version 1803, CMake 3.11.0, MSVC 2017, Release, Matrix: [x64 | x32 | WinXP], [shared | static].

Android -- Ubuntu Xenial 16.04, CMake 3.6.0, Android NDK r19, Clang 8.0.2, Ninja, Release, Matrix: [shared + c++_shared | static + c++_static], [armeabi-v7a + API 16 | arm64-v8a + API 21 | x86 + API 16 | x86_64 + API 21].

The simple tests with Google Test are compiling and running for testing the library work on the target platform (test running is not released for Android, only compiling of tests).


 Library   | Status   | Built with dependencies
 --------- | -------- | -------------------------
 [LibCMaker_AGG](https://github.com/LibCMaker/LibCMaker_AGG) <br> [AGG site](http://www.antigrain.com/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_AGG.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_AGG) | GTest
 [LibCMaker_Boost](https://github.com/LibCMaker/LibCMaker_Boost) <br> [Boost site](https://www.boost.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Boost.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Boost) | GTest, ICU
 [LibCMaker_Dirent](https://github.com/LibCMaker/LibCMaker_Dirent) <br> [Dirent site](https://github.com/tronkko/dirent) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Dirent.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Dirent) | GTest
 [LibCMaker_Expat](https://github.com/LibCMaker/LibCMaker_Expat) <br> [Expat site](https://libexpat.github.io/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Expat.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Expat) | GTest
 [LibCMaker_FontConfig](https://github.com/LibCMaker/LibCMaker_FontConfig) <br> [FontConfig site](https://www.fontconfig.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_FontConfig.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_FontConfig) | GTest, Dirent (Windows only), Expat, FreeType
 [LibCMaker_FreeType](https://github.com/LibCMaker/LibCMaker_FreeType) <br> [FreeType site](https://www.freetype.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_FreeType.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_FreeType) | GTest, HarfBuzz
 [LibCMaker_GoogleTest](https://github.com/LibCMaker/LibCMaker_GoogleTest) <br> [GoogleTest site](https://github.com/google/googletest) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_GoogleTest.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_GoogleTest) |
 [LibCMaker_HarfBuzz](https://github.com/LibCMaker/LibCMaker_HarfBuzz) <br> [HarfBuzz site](http://www.harfbuzz.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_HarfBuzz.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_HarfBuzz) | GTest
 [LibCMaker_ICU](https://github.com/LibCMaker/LibCMaker_ICU) <br> [ICU site](http://site.icu-project.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_ICU.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_ICU) | GTest
 [LibCMaker_SQLite3](https://github.com/LibCMaker/LibCMaker_SQLite3) <br> [SQLite3 site](https://www.sqlite.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_SQLite3.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_SQLite3) | GTest, ICU (only Linux and Windows)
 [LibCMaker_SQLiteModernCPP](https://github.com/LibCMaker/LibCMaker_SQLiteModernCPP) <br> [SQLiteModernCPP site](https://github.com/SqliteModernCpp/sqlite_modern_cpp) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_SQLiteModernCPP.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_SQLiteModernCPP) | GTest, SQLite3
 [LibCMaker_STLCache](https://github.com/LibCMaker/LibCMaker_STLCache) <br> [STL::Cache site](https://github.com/akashihi/stlcache) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_STLCache.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_STLCache) | GTest
 [LibCMaker_wxWidgets](https://github.com/LibCMaker/LibCMaker_wxWidgets) <br> [wxWidgets site](https://www.wxwidgets.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_wxWidgets.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_wxWidgets) | GTest
