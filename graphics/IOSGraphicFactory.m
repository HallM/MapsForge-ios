/*
 * Copyright 2014 Matthew Hall
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "IOSGraphicFactory.h"

#import "org/mapsforge/core/graphics/Color.h"

#import "java/io/FileInputStream.h"
#import "java/io/InputStream.h"

#import "IOSArray.h"

#import "IOSBitmap.h"
#import "IOSCanvas.h"
#import "IOSMatrix.h"
#import "IOSPaint.h"
#import "IOSPath.h"
#import "IOSPointTextContainer.h"
#import "IOSResourceBitmap.h"
#import "IOSSvgBitmap.h"
#import "IOSTileBitmap.h"

@implementation IOSGraphicFactory

- (id<OrgMapsforgeCoreGraphicsBitmap>)createBitmapWithInt:(jint)width
                                                  withInt:(jint)height {
    return [[[IOSBitmap alloc] initWithSize:CGSizeMake(width, height) isTransparent:YES] autorelease];
}

- (id<OrgMapsforgeCoreGraphicsBitmap>)createBitmapWithInt:(jint)width
                                                  withInt:(jint)height
                                              withBoolean:(jboolean)isTransparent {
    return [[[IOSBitmap alloc] initWithSize:CGSizeMake(width, height) isTransparent:isTransparent] autorelease];
}

- (id<OrgMapsforgeCoreGraphicsCanvas>)createCanvas {
    return [[[IOSCanvas alloc] init] autorelease];
}

+ (jint)getIntColorFromEnum:(OrgMapsforgeCoreGraphicsColorEnum *)color {
    switch ([color ordinal]) {
        case OrgMapsforgeCoreGraphicsColor_BLACK:
            return [IOSGraphicFactory getColorFromA:0xff R:0 G:0 B:0];
            break;
        case OrgMapsforgeCoreGraphicsColor_BLUE:
            return [IOSGraphicFactory getColorFromA:0xff R:0 G:0 B:0xff];
            break;
        case OrgMapsforgeCoreGraphicsColor_GREEN:
            return [IOSGraphicFactory getColorFromA:0xff R:0 G:0xff B:0];
            break;
        case OrgMapsforgeCoreGraphicsColor_RED:
            return [IOSGraphicFactory getColorFromA:0xff R:0xff G:0 B:0];
            break;
        case OrgMapsforgeCoreGraphicsColor_TRANSPARENT:
            return [IOSGraphicFactory getColorFromA:0 R:0 G:0 B:0];
            break;
        case OrgMapsforgeCoreGraphicsColor_WHITE:
            return [IOSGraphicFactory getColorFromA:0xff R:0xff G:0xff B:0xff];
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (jint)createColorWithOrgMapsforgeCoreGraphicsColorEnum:(OrgMapsforgeCoreGraphicsColorEnum *)color {
    return [IOSGraphicFactory getIntColorFromEnum:color];
}

+ (jint)getColorFromA:(jint)alpha
                   R:(jint)red
                   G:(jint)green
                   B:(jint)blue {
    jint convColor = ((alpha & 0xff) << 24) | ((red & 0xff) << 16) | ((green & 0xff) << 8) | ((blue & 0xff));
    return convColor;
}

- (jint)createColorWithInt:(jint)alpha
                   withInt:(jint)red
                   withInt:(jint)green
                   withInt:(jint)blue {
    return [IOSGraphicFactory getColorFromA:alpha R:red G:green B:blue];
}

- (id<OrgMapsforgeCoreGraphicsMatrix>)createMatrix {
    return [[[IOSMatrix alloc] init] autorelease];
}

- (id<OrgMapsforgeCoreGraphicsPaint>)createPaint {
    return [[[IOSPaint alloc] init] autorelease];
}

- (id<OrgMapsforgeCoreGraphicsPath>)createPath {
    return [[[IOSPath alloc] init] autorelease];
}

- (OrgMapsforgeCoreMapelementsPointTextContainer *)createPointTextContainerWithOrgMapsforgeCoreModelPoint:(OrgMapsforgeCoreModelPoint *)xy
                                                                                                  withInt:(jint)priority
                                                                                             withNSString:(NSString *)text
                                                                        withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintFront
                                                                        withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintBack
                                                           withOrgMapsforgeCoreMapelementsSymbolContainer:(OrgMapsforgeCoreMapelementsSymbolContainer *)symbolContainer
                                                                 withOrgMapsforgeCoreGraphicsPositionEnum:(OrgMapsforgeCoreGraphicsPositionEnum *)position
                                                                                                  withInt:(jint)maxTextWidth {
    return [[[IOSPointTextContainer alloc] initWithOrgMapsforgeCoreModelPoint:xy withInt:priority withNSString:text withOrgMapsforgeCoreGraphicsPaint:paintFront withOrgMapsforgeCoreGraphicsPaint:paintBack withOrgMapsforgeCoreMapelementsSymbolContainer:symbolContainer withOrgMapsforgeCoreGraphicsPositionEnum:position withInt:maxTextWidth] autorelease];
}

- (id<OrgMapsforgeCoreGraphicsResourceBitmap>)createResourceBitmapWithJavaIoInputStream:(JavaIoInputStream *)inputStream
                                                                                withInt:(jint)hash_ {
    IOSByteArray *fileData = [IOSByteArray arrayWithLength:[inputStream available]];
    if ([inputStream readWithByteArray:fileData withInt:0 withInt:[inputStream available]] > 0) {
        NSData *data = [fileData toNSData];
        
        CGDataProviderRef pngProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
        CGImageRef img = CGImageCreateWithPNGDataProvider(pngProvider, NULL, true, kCGRenderingIntentPerceptual);
        CGDataProviderRelease(pngProvider);
        
        IOSResourceBitmap *bitmap = [[[IOSResourceBitmap alloc] initWithImage:img andScale:1.f] autorelease];
        CGImageRelease(img);

        return bitmap;
    }
    
    return nil;
}

- (id<OrgMapsforgeCoreGraphicsTileBitmap>)createTileBitmapWithJavaIoInputStream:(JavaIoInputStream *)inputStream
                                                                        withInt:(jint)tileSize
                                                                    withBoolean:(jboolean)isTransparent {
    NSMutableData *pngTile = [NSMutableData dataWithCapacity:32768];
    
    IOSByteArray *fileData = [IOSByteArray arrayWithLength:4096];
    jint bytesRead = -1;
    
    do {
        bytesRead = [inputStream readWithByteArray:fileData];
        if (bytesRead > 0) {
            NSData *data = [fileData toNSData];
            [pngTile appendData:data];
        }
    } while (bytesRead > 0);
    
    if ([pngTile length] > 0) {
        CGDataProviderRef pngProvider = CGDataProviderCreateWithCFData((CFDataRef)pngTile);
        CGImageRef img = CGImageCreateWithPNGDataProvider(pngProvider, NULL, true, kCGRenderingIntentPerceptual);
        CGDataProviderRelease(pngProvider);
        
        IOSTileBitmap *bitmap = [[[IOSTileBitmap alloc] initWithImage:img andScale:1.f] autorelease];
        CGImageRelease(img);
        
        return bitmap;
    }
    // TODO: this is an error, figure out the best way to pass this to end user
    return nil;
}

- (id<OrgMapsforgeCoreGraphicsTileBitmap>)createTileBitmapWithInt:(jint)tileSize
                                                      withBoolean:(jboolean)isTransparent {
    return [[[IOSTileBitmap alloc] initWithSize:CGSizeMake(tileSize, tileSize) isTransparent:isTransparent] autorelease];
}

- (JavaIoInputStream *)platformSpecificSourcesWithNSString:(NSString *)relativePathPrefix
                                              withNSString:(NSString *)src {
    NSRange rng = [src rangeOfString:@"assets:" options:NSBackwardsSearch];
    NSString *platformSource = rng.location != NSNotFound ? [src substringFromIndex:rng.location+rng.length] : src;
    
    // don't have SVG support yet, so return the PNG
    NSString *asset = [platformSource stringByReplacingOccurrencesOfString:@"svg" withString:@"png"];
    NSString *path = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
    if (path) {
        JavaIoFileInputStream *fileStream = [[[JavaIoFileInputStream alloc] initWithNSString:path] autorelease];
        return fileStream;
    } else {
        return nil;
    }
}

- (id<OrgMapsforgeCoreGraphicsResourceBitmap>)renderSvgWithJavaIoInputStream:(JavaIoInputStream *)inputStream
                                                                   withFloat:(jfloat)scaleFactor
                                                                     withInt:(jint)width
                                                                     withInt:(jint)height
                                                                     withInt:(jint)percent
                                                                     withInt:(jint)hash_ {
    // TODO: need an SVG CoreGraphics-based renderer for iOS
    return [self createResourceBitmapWithJavaIoInputStream:inputStream withInt:hash_];
    
    /*Leaving this commented code for now. Originally written for SVGKit, but had issues
    IOSByteArray *fileData = [IOSByteArray arrayWithLength:[inputStream available]];
    if ([inputStream readWithByteArray:fileData withInt:0 withInt:[inputStream available]] > 0) {
        NSData *data = [fileData toNSData];
        
        ??? *svgImg = ???;
        double scale = scaleFactor / sqrt((svgImg.size.height * svgImg.size.width) / 400.f);
        
        CGFloat imgWidth = svgImg.size.width * scale;
        CGFloat imgHeight = svgImg.size.height * scale;
        
        float aspectRatio = (1.f * svgImg.size.width) / svgImg.size.height;
        
        if (width != 0 && height != 0) {
            imgWidth = width;
            imgHeight = height;
        } else if (width == 0 && height != 0) {
            imgWidth = height * aspectRatio;
            imgHeight = height;
        } else if (width != 0 && height == 0) {
            imgWidth = width;
            imgHeight = width / aspectRatio;
        }
        
        if (percent != 100) {
            imgWidth *= ((CGFloat)percent / 100.f);
            imgHeight *= ((CGFloat)percent / 100.f);
        }
        svgImg.size = CGSizeMake(imgWidth, imgHeight);
        
        IOSSvgBitmap *bitmap = [[[IOSSvgBitmap alloc] initWithSvgImage:svgImg] autorelease];
        [svgImg release];
        
        NSLog(@"return svg");
        return bitmap;
    }
    
    NSLog(@"failed to get svg");
    return nil;*/
}

@end
