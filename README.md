# MapsForge-ios
An iOS port of the Java based MapsForge OSM mapping library using J2ObjC and native code.

*This is a fork of an original work of Matthew Hall you can see here https://github.com/Crazy50/MapsForge-ios.*
*MapsForge is a library to render vector map tiles on Java platforms. You can see here https://github.com/mapsforge/mapsforge.*

## Dependencies

You will need some dependancies to make this works:
* J2OBJC (https://github.com/google/j2objc). Unpackage it and compile using `make dist`. Please make sure you have Maven installed (https://maven.apache.org/).
* XCode 7. Some bugs could block you in XCode 6.

You'll wave to add Maven in your $PATH and the J2OBJC directory in the variable $J2OBJC_DIR !

## Compilation Guide

1. Download or clone the Github project.
2. Get the last stable version of MapsForge (https://github.com/mapsforge/mapsforge). This project supports the 0.5.2 stable build. Copy the folder into the lib/mapsforge directory of this Github project.
3. Be sure your J2OBJC directory is specified in the variable $J2OBJC_DIR.
4. Build the project.
5. You'll find the library `.a`and the headers file in the build folder.

## How to add the library into another project

1. Copy the `.a`library and the headers into the new project.
2. In *Build Phases*, add the `.a` library file to *Link Binaries With Librairies*.
3. In *Build Settings*, search the *Header Search Path* and add `$(SRCROOT)/YourProjectName/YourLibraryFolder/`. Set this recursive.
4. Build your project. You can make references to headers of the library by calling `mapsforge-ios/org/mapsforge/path/to/the/file.h`.

Beware if you are using J2OBJC for other librairies or for your current project, the library headers already contains java headers for your convenience. If you already specify J2OBJC headers, you can change the *Header Search Path* and set `$(SRCROOT)/YourProjectName/YourLibraryFolder/mapsforge-ios` to only include the library headers and not the J2OBJC headers.
