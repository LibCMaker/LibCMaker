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
LibCMaker_<LibName>/.appveyor.yml
```

## Notes and requirements.

1. LibCMaker requires CMake 3.8+ for macOS ("Xcode" and "Unix Makefiles" generators), CMake 3.15+ for iOS ("Xcode" generators) and CMake 3.4+ for others.

2. ICU requires CMake 3.11+ for "Visual Studio" generator, CMake 3.12+ for "Xcode" generator and 3.4+ for others.

3. wxWidgets requires CMake 3.5+ for MSVC and MinGW-w64, CMake 3.12+ for "Xcode" generator, CMake 3.10+ is recommended by developers of wxWidgets.

4. Android NDK r18+ does not have 'std::experimental' namespace for C++14. This affects to Boost and SQLiteModernCPP. In this case Boost can be comppiled with C++11 and C++17, SQLiteModernCPP can be compiled only with C++17. C++17 requires CMake 3.8+ and CXX_STANDARD=17.

5. MSVC does not have the flags for C++11. MSVC 2015 Update 3 has /std:c++14 and /std:c++latest, no flags for C++ standard is used by default. MSVC 2017 has /std:c++14, /std:c++17 and /std:c++latest, /std:c++14 is used by default. If in the CMake project CXX_STANDARD=11 then MSVC 2015 does not specify any C++ standard and MSVC 2017 specifies C++14. This affects to LibCMaker_Boost for the flag, which will or will not be passed to the 'b2' tool.

6. Dirent is tested only on Windows.

7. wxWidgets is tested on Linux, Windows and macOS.

8. LibCMaker_Boost does not work with OS X universal binaries, CMAKE_OSX_ARCHITECTURES must contain only one architecture.


## Known build issues

1. If Boost is building with the ICU for Android and Windows, then the message "has_icu......yes" is not displayed due to the patch of the file '(boost-src)/libs/regex/build/Jamfile.v2'.

2. Boost is building without ICU on Travis CI and AppVeyor for the Windows x64 static because of the failed test running with the following configurations: [Boost 1.68.0 | Boost 1.69.0], [ICU 58.2 | ICU 61.1 | ICU 63.1], [MSVC 2017 19.16.27023.1 | MSVC 2017 19.16.27026.1 | MSVC 2015 19.0.24241.7], [Windows Server 1803 | Windows 10.0.14393].

3. If Boost is building with MSVC 2015, then in the Boost.Build rule ```using msvc : [version] : [c++-compile-command] : [compiler options] ;``` can not be explicitly specified "c++-compile-command", build will be failed. This affects to LibCMaker_Boost, when one compiler detected by CMake is used for other CMake subprojects, and the compiler detected by the 'b2' tool is used for Boost (only in the case of using MSVC 2015). But they should be the same in the case of MSVC 2015.


## Notes about CMake

1. If the ```cmake_minimum_required()``` command has a version lower than 3.0, CMake does not set ```@rpath``` in the shared libraries on macOS, see [CMP0042](https://cmake.org/cmake/help/latest/policy/CMP0042.html). About RPATH with CMake see [RPATH handling](https://gitlab.kitware.com/cmake/community/wikis/doc/cmake/RPATH-handling).

2. CMake 3.14 contains a bug on iOS for CMAKE_FIND_ROOT_PATH_* variables. Use CMake 3.15+ for iOS.


## Build status

All libraries are tested with Travis CI and AppVeyor.


Following configurations are in Travis CI (2019-02-23):

1. Linux -- Ubuntu Xenial 16.04, CMake 3.4.0, Make, Matrix: [GCC 5.4.0 | Clang 7.0.0], [Debug | Release], [shared | static].

2. Android -- Ubuntu Xenial 16.04, CMake 3.6.0, Android NDK r19, Clang 8.0.2, Ninja, Release, Matrix: [shared + c++_shared | static + c++_static], [armeabi-v7a + API 16 | arm64-v8a + API 21 | x86 + API 16 | x86_64 + API 21].

3. [Disabled, used AppVeyor] Windows -- Windows Server 1803, CMake 3.11.0, MSVC 2017, MSVC 19.16.27023.1, Release, Matrix: [x64 | x32 | WinXP], [shared | static].

4. macOS -- Mac OS X 10.14.4, CMake 3.8.0 and 3.12.0 (see 'Notes and requirements'), Xcode 10.2.1, Apple Clang 10.0.1, Matrix: CMake generator ["Xcode" | "Unix Makefiles"], [Debug | Release], [shared | static].

5. iOS -- Mac OS X 10.14.4, CMake 3.15.0, Xcode 10.2.1, Apple Clang 10.0.1, SDK iPhoneSimulator12.2, platform SIMULATOR64, CMake generator "Xcode", Matrix: [Debug | Release], [shared | static].

Following configurations are in AppVeyor (2019-02-23):

1. Windows 10.0.14393, CMake 3.11.0, MSVC 2017, MSVC 19.16.27026.1, Release, Matrix: [x64 | x32 | WinXP], [shared | static].

2. Windows 10.0.14393, CMake 3.4.0, MinGW-w64 x86_64-7.2.0-posix-seh-rt_v5-rev1, GCC GNU 7.2.0, Release, x64, Matrix: [shared | static].

3. Windows 6.3.9600, CMake 3.11.0, MSVC 2015, MSVC 19.0.24241.7, Release, x64, Matrix: [shared | static].


The simple tests with Google Test are compiling and running for testing the library work on the target platform (test running is not released for Android, only compiling of the tests).


 *Library*   | *Travis CI* <br> Linux <br> Android <br> macOS <br> iOS   | *AppVeyor* <br> MSVC 2017 <br> MinGW-w64 <br> MSVC 2015   | *Built with dependencies*
 ----------- | --------------------------------------------------------- | --------------------------------------------------------- | ---------------------------
 [LibCMaker_AGG](https://github.com/LibCMaker/LibCMaker_AGG) <br> [AGG site](http://www.antigrain.com/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_AGG.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_AGG) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_AGG?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-agg/branch/master) | GTest
 [LibCMaker_Boost](https://github.com/LibCMaker/LibCMaker_Boost) <br> [Boost site](https://www.boost.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Boost.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Boost) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_Boost?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-boost/branch/master) | GTest, ICU
 [LibCMaker_Dirent](https://github.com/LibCMaker/LibCMaker_Dirent) <br> [Dirent site](https://github.com/tronkko/dirent) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Dirent.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Dirent) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_Dirent?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-dirent/branch/master) | GTest
 [LibCMaker_Expat](https://github.com/LibCMaker/LibCMaker_Expat) <br> [Expat site](https://libexpat.github.io/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_Expat.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_Expat) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_Expat?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-expat/branch/master) | GTest
 [LibCMaker_FontConfig](https://github.com/LibCMaker/LibCMaker_FontConfig) <br> [FontConfig site](https://www.fontconfig.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_FontConfig.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_FontConfig) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_FontConfig?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-fontconfig/branch/master) | GTest, Dirent (Windows only), Expat, FreeType
 [LibCMaker_FreeType](https://github.com/LibCMaker/LibCMaker_FreeType) <br> [FreeType site](https://www.freetype.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_FreeType.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_FreeType) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_FreeType?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-freetype/branch/master) | GTest, HarfBuzz
 [LibCMaker_GoogleTest](https://github.com/LibCMaker/LibCMaker_GoogleTest) <br> [GoogleTest site](https://github.com/google/googletest) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_GoogleTest.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_GoogleTest) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_GoogleTest?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-googletest/branch/master) |
 [LibCMaker_HarfBuzz](https://github.com/LibCMaker/LibCMaker_HarfBuzz) <br> [HarfBuzz site](http://www.harfbuzz.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_HarfBuzz.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_HarfBuzz) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_HarfBuzz?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-harfbuzz/branch/master) | GTest
 [LibCMaker_ICU](https://github.com/LibCMaker/LibCMaker_ICU) <br> [ICU site](http://site.icu-project.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_ICU.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_ICU) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_ICU?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-icu/branch/master) | GTest
 [LibCMaker_SQLite3](https://github.com/LibCMaker/LibCMaker_SQLite3) <br> [SQLite3 site](https://www.sqlite.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_SQLite3.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_SQLite3) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_SQLite3?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-sqlite3/branch/master) | GTest, ICU (only Linux, Windows, macOS)
 [LibCMaker_SQLiteModernCPP](https://github.com/LibCMaker/LibCMaker_SQLiteModernCPP) <br> [SQLiteModernCPP site](https://github.com/SqliteModernCpp/sqlite_modern_cpp) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_SQLiteModernCPP.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_SQLiteModernCPP) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_SQLiteModernCPP?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-sqlitemoderncpp/branch/master) | GTest, SQLite3
 [LibCMaker_STLCache](https://github.com/LibCMaker/LibCMaker_STLCache) <br> [STL::Cache site](https://github.com/akashihi/stlcache) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_STLCache.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_STLCache) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_STLCache?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-stlcache/branch/master) | GTest
 [LibCMaker_wxWidgets](https://github.com/LibCMaker/LibCMaker_wxWidgets) <br> [wxWidgets site](https://www.wxwidgets.org/) | [![Build Status](https://travis-ci.com/LibCMaker/LibCMaker_wxWidgets.svg?branch=master)](https://travis-ci.com/LibCMaker/LibCMaker_wxWidgets) | [![Build status](https://ci.appveyor.com/api/projects/status/github/LibCMaker/LibCMaker_wxWidgets?branch=master&svg=true)](https://ci.appveyor.com/project/NikitaFeodonit/libcmaker-wxwidgets/branch/master) | GTest
