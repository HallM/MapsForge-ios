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

#import "IOSBitmap.h"

#import "IOSArray.h"
#import "java/io/ByteArrayOutputStream.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation IOSBitmap

- (id)initWithSize:(CGSize)size isTransparent:(BOOL)isTransparent {
    self = [super init];
    if (self) {
        drawCanvas = nil;
        size_ = size;
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapContext_ = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, rgbcolorSpace, (CGBitmapInfo)(isTransparent ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst));
        CGColorSpaceRelease(rgbcolorSpace);
        if (bitmapContext_ != NULL) {
            CGFloat comp[4];
            comp[0] = 0.f;
            comp[1] = 0.f;
            comp[2] = 0.f;
            comp[3] = 0.f;
            CGContextSetFillColor(bitmapContext_, comp);
            CGRect r = CGRectMake(0.f, 0.f, size.width, size.height);
            CGContextFillRect(bitmapContext_, r);
        }
    }
    return self;
}

- (id)initWithImage:(CGImageRef)image andScale:(CGFloat)scale {
    self = [self initWithSize:CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)) isTransparent:YES];
    if (self) {
        CGRect r = CGRectMake(0, 0, size_.width, size_.height);
        if (scale > 0) {
            CGContextTranslateCTM(bitmapContext_, 0, r.size.height);
            CGContextScaleCTM(bitmapContext_, scale, -scale);
        }
        CGContextDrawImage(bitmapContext_, r, image);
        if (scale > 0) {
            CGContextScaleCTM(bitmapContext_, scale, -scale);
            CGContextTranslateCTM(bitmapContext_, 0, -r.size.height);
        }
    }
    return self;
}

- (void)destroy {
    if (drawCanvas) {
        [drawCanvas setBitmapWithOrgMapsforgeCoreGraphicsBitmap:nil];
        [drawCanvas release]; drawCanvas = nil;
    }
    if (bitmapContext_ != NULL) {
        CGContextRelease(bitmapContext_);
        bitmapContext_ = NULL;
    }
}

- (void)dealloc {
    [self destroy];
    [super dealloc];
}

- (void)compressWithJavaIoOutputStream:(JavaIoOutputStream *)outputStream {
    if (bitmapContext_ == NULL) {
        return;
    }
    CGImageRef flippedimg = CGBitmapContextCreateImage(bitmapContext_);

    CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef tempContext = CGBitmapContextCreate(NULL, size_.width, size_.height, 8, 0, rgbcolorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(rgbcolorSpace);

    CGContextTranslateCTM(tempContext, 0, size_.height);
    CGContextScaleCTM(tempContext, 1, -1);
    
    CGRect r = CGRectMake(0, 0, size_.width, size_.height);
    CGContextDrawImage(tempContext, r, flippedimg);
    
    CGImageRef img = CGBitmapContextCreateImage(tempContext);

    NSMutableData *mutaData = [[NSMutableData alloc] init];
    CGImageDestinationRef imageDef = CGImageDestinationCreateWithData((CFMutableDataRef)mutaData, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(imageDef, img, NULL);
    CGImageDestinationFinalize(imageDef);
    
    IOSByteArray *byteArray = [IOSByteArray arrayWithBytes:(jbyte*)[mutaData bytes] count:[mutaData length]];
    
    [outputStream writeWithByteArray:byteArray];
    
    CFRelease(imageDef);
    [mutaData release];
    CGImageRelease(img);
    CGImageRelease(flippedimg);
    CGContextRelease(tempContext);
}

// just using iOS's mem management, normal retain+release work fine
- (void)incrementRefCount {
}

- (void)decrementRefCount {
}

- (jint)getHeight {
    return size_.height;
}

- (jint)getWidth {
    return size_.width;
}

- (void)scaleToWithInt:(jint)width withInt:(jint)height {
    if (bitmapContext_ == NULL) {
        return;
    }
    // TODO: do it
}

- (void)setBackgroundColorWithInt:(jint)color {
    if (bitmapContext_ == NULL) {
        return;
    }
    jint tmp = color;
    CGFloat blue = ((CGFloat)(tmp & 0xff)) / 255.f;
    tmp = tmp >> 8;
    CGFloat green = ((CGFloat)(tmp & 0xff)) / 255.f;
    tmp = tmp >> 8;
    CGFloat red = ((CGFloat)(tmp & 0xff)) / 255.f;
    tmp = tmp >> 8;
    CGFloat alpha = ((CGFloat)(tmp & 0xff)) / 255.f;
    
    CGContextSetRGBFillColor(bitmapContext_, red, green, blue, alpha);
    CGContextFillRect(bitmapContext_, CGRectMake(0.f, 0.f, size_.width, size_.height));
}

@end
