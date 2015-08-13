# MapsForge-ios
An iOS port of the Java based MapsForge OSM mapping library using J2ObjC and native code.

*MapsForge is a library to render vector map tiles from OSM on Java platforms. You can see here https://github.com/mapsforge/mapsforge.*

## Support

Application supports the MapsForge build 0.5.1 (https://github.com/mapsforge/mapsforge/tree/0.5.1).

## Dependencies

You will need some dependancies to make this works:
* J2OBJC (https://github.com/google/j2objc). Unpackage it and compile using `make dist`. Please make sure you have Maven installed (https://maven.apache.org/).
* XCode 7. Some bugs could block you in XCode 6.

You'll wave to add Maven in your $PATH !

## Compilation Guide

1. Download or clone the Github project.
2. Get the last stable version of MapsForge (https://github.com/mapsforge/mapsforge). This project supports the 0.5.1 stable build. Copy the folder into the lib/mapsforge directory on this Github project.
3. Download J2OBJC, compile it and copy the `dist` directory into your HOME/j2objc. This leads to `/Users/<your_username>/j2objc`. Remember to copy the whole directory, not only the executable.
4. Build the project.
5. You'll find the library `.a`and the headers file in the build folder. Search for `libmapsforge-ios.a`and `mapsforge-ios-headers`.

## How to add the library into another project

1. Copy the `libmapsforge-ios.a`library and the directory header `mapsforge-ios-headers` into the new project.
2. In *Build Phases*, add the `.a` library file to *Link Binaries With Librairies*.
3. In *Build Settings*, search the *Header Search Path* and add `$(SRCROOT)/YourProjectName/YourLibraryFolder/mapsforge-ios-headers`. Set this recursive.
4. In *Build Settings*, search the *Other Linker Flags* and set this `-L $(HOME)/j2objc/lib -l jre_emul -ObjC`. This is mandatory when you use librairies using J2OBJC.
4. Build your project. You can make references to headers of the library by calling `mapsforge-ios/org/mapsforge/path/to/the/file.h`.

Beware if you are using J2OBJC for other librairies or for your current project, the library headers already contains java headers for your convenience. If you already specify J2OBJC headers, you can change the *Header Search Path* and set `$(SRCROOT)/YourProjectName/YourLibraryFolder/mapsforge-ios-headers/mapsforge-ios` to only include the library headers and not the J2OBJC headers. If you do that, references to headers of the library are made like this: `/org/mapsforge/path/to/the/file.h`.
