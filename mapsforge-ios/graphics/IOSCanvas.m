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

#import "IOSCanvas.h"
#import <CoreText/CoreText.h>
#import "org/mapsforge/core/model/Dimension.h"

#import "IOSBitmap.h"
#import "IOSMatrix.h"
#import "IOSPaint.h"
#import "IOSPath.h"
#import "IOSPointTextContainer.h"
#import "IOSResourceBitmap.h"
#import "IOSSvgBitmap.h"
#import "IOSTileBitmap.h"
#import "IOSGraphicFactory.h"

//#define SHOWTILELINESDEBUG 1

void shaderPatternDraw( void * info, CGContextRef context ) {
    if (info != NULL) {
        CGImageRef shaderImg = (CGImageRef)info;
        CGRect r = CGRectMake(0, 0, CGImageGetWidth(shaderImg), CGImageGetHeight(shaderImg));
        CGContextDrawImage(context, r, shaderImg);
    }
}

@implementation IOSCanvas

- (id)init {
    self = [super init];
    if (self) {
        size_ = CGSizeZero;
        context_ = NULL;
        patternCallbacks_.drawPattern = shaderPatternDraw;
        syncro = [[NSObject alloc] init];
    }
    return self;
}

- (id)initWithContext:(CGContextRef)context andSize:(CGSize)size {
    self = [super init];
    if (self) {
        size_ = size;
        context_ = context;
        patternCallbacks_.drawPattern = shaderPatternDraw;
        syncro = [[NSObject alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self destroy];
    [syncro release]; syncro = nil;
    [super dealloc];
}

- (void)destroy {
    @synchronized (syncro) {
        if (context_) {
            context_ = NULL;
        }
        size_ = CGSizeMake(0.f, 0.f);
    }
}

- (OrgMapsforgeCoreModelDimension *)getDimension {
    return [[[OrgMapsforgeCoreModelDimension alloc] initWithInt:[self getWidth] withInt:[self getHeight]] autorelease];
}

- (jint)getHeight {
    return size_.height;
}

- (jint)getWidth {
    return size_.width;
}

- (void)setBitmapWithOrgMapsforgeCoreGraphicsBitmap:(id<OrgMapsforgeCoreGraphicsBitmap>)bitmap {
    @synchronized (syncro) {
        if (bitmap == nil) {
            context_ = NULL;
        } else {
            IOSBitmap *ibitmap = (IOSBitmap*)bitmap;
            if (ibitmap->bitmapContext_ != NULL) {
                if (context_) {
                    context_ = NULL;
                }
                size_ = ibitmap->size_;
                context_ = ibitmap->bitmapContext_;
                if (context_ != NULL) {
                    ibitmap->drawCanvas = [self retain];
                }
            }
        }
    }
}

// this one is not thread safe! Only use internally and surrounded by a thread safe one
- (void)drawBitmap:(id<OrgMapsforgeCoreGraphicsBitmap>)bitmap left:(jint)left top:(jint)top {
    if (context_ == NULL) {
        return;
    }
    IOSBitmap *ibitmap = (IOSBitmap*)bitmap;
    CGImageRef img = CGBitmapContextCreateImage(ibitmap->bitmapContext_);
    
    CGRect r = CGRectMake(left, top, ibitmap->size_.width, ibitmap->size_.height);
    CGContextSetRGBFillColor(context_, 1.f, 1.f, 1.f, 1.f);
    CGContextDrawImage(context_, r, img);
    
    // sometimes, need to debug the outline of tiles
#ifdef SHOWTILELINESDEBUG
    if ([ibitmap isKindOfClass:[IOSTileBitmap class]]) {
        CGContextSetRGBStrokeColor(context_, 0.f, 0.f, 0.f, 1.f);
        CGContextStrokeRect(context_, r);
    }
#endif
    
    CGImageRelease(img);
}

- (void)drawBitmapWithOrgMapsforgeCoreGraphicsBitmap:(id<OrgMapsforgeCoreGraphicsBitmap>)bitmap
                                             withInt:(jint)left
                                             withInt:(jint)top {
    @synchronized (syncro) {
        [self drawBitmap:bitmap left:left top:top];
    }
}

- (void)drawBitmapWithOrgMapsforgeCoreGraphicsBitmap:(id<OrgMapsforgeCoreGraphicsBitmap>)bitmap
                  withOrgMapsforgeCoreGraphicsMatrix:(id<OrgMapsforgeCoreGraphicsMatrix>)matrix {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        IOSMatrix *imatrix = (IOSMatrix*)matrix;
        
        CGContextSaveGState(context_);
        
        //CGAffineTransform orig = CGContextGetCTM(context_);
        CGAffineTransform mtxTransform = imatrix->matrix_;
        CGContextConcatCTM(context_, mtxTransform);
        
        [self drawBitmap:bitmap left:0 top:0];

        CGContextRestoreGState(context_);
    }
}

- (void)drawCircleWithInt:(jint)x
                  withInt:(jint)y
                  withInt:(jint)radius
withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        IOSPaint *ipaint = (IOSPaint*)paint;
        CGRect r = CGRectMake(x, YES, radius*2, radius*2);
        
        CGContextSaveGState(context_);

        jint colorInt = ipaint->color_;
        CGFloat colorComponents[4];
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorRef = CGColorCreate(rgbcolorSpace, colorComponents);
        CGColorSpaceRelease(rgbcolorSpace);
        
        CGContextSetLineWidth(context_, ipaint->strokeWidth_);

        if (ipaint->style_ == OrgMapsforgeCoreGraphicsStyle_FILL) {
            CGContextSetFillColorWithColor(context_, colorRef);
            CGContextFillEllipseInRect(context_, r);
        } else {
            CGContextSetStrokeColorWithColor(context_, colorRef);
            CGContextStrokeEllipseInRect(context_, r);
        }
        
        CGColorRelease(colorRef);
        CGContextRestoreGState(context_);
    }
}

- (void)drawLineWithInt:(jint)x1
                withInt:(jint)y1
                withInt:(jint)x2
                withInt:(jint)y2
withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        IOSPaint *ipaint = (IOSPaint*)paint;

        CGContextSaveGState(context_);
        
        jint colorInt = ipaint->color_;
        CGFloat colorComponents[4];
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorRef = CGColorCreate(rgbcolorSpace, colorComponents);
        CGColorSpaceRelease(rgbcolorSpace);
        
        CGContextSetLineWidth(context_, ipaint->strokeWidth_);
        CGContextSetStrokeColorWithColor(context_, colorRef);
        
        CGContextBeginPath(context_);
        CGContextMoveToPoint(context_, x1, y1);
        CGContextAddLineToPoint(context_, x2, y2);
        CGContextStrokePath(context_);
        
        CGColorRelease(colorRef);
        CGContextRestoreGState(context_);
    }
}

- (void)drawPathWithOrgMapsforgeCoreGraphicsPath:(id<OrgMapsforgeCoreGraphicsPath>)path
               withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        
        CGContextSaveGState(context_);
        
        IOSPath *ipath = (IOSPath*)path;
        IOSPaint *ipaint = (IOSPaint*)paint;
        
        CGLineJoin lineJoin;
        switch (ipaint->joinStyle_) {
            case OrgMapsforgeCoreGraphicsJoin_BEVEL:
                lineJoin = kCGLineJoinBevel;
                break;
            case OrgMapsforgeCoreGraphicsJoin_MITER:
                lineJoin = kCGLineJoinMiter;
                break;
            case OrgMapsforgeCoreGraphicsJoin_ROUND:
            default:
                lineJoin = kCGLineJoinRound;
                break;
        }
        
        CGLineCap lineCap;
        switch (ipaint->capStyle_) {
            case OrgMapsforgeCoreGraphicsCap_BUTT:
                lineCap = kCGLineCapButt;
                break;
            case OrgMapsforgeCoreGraphicsCap_SQUARE:
                lineCap = kCGLineCapSquare;
                break;
            case OrgMapsforgeCoreGraphicsCap_ROUND:
            default:
                lineCap = kCGLineCapRound;
                break;
        }
        
        jint colorInt = ipaint->color_;
        CGFloat colorComponents[4];
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorRef = CGColorCreate(rgbcolorSpace, colorComponents);
        CGColorSpaceRelease(rgbcolorSpace);
        
        CGContextSetLineWidth(context_, ipaint->strokeWidth_);
        CGContextSetLineJoin(context_, lineJoin);
        CGContextSetLineCap(context_, lineCap);
        CGContextSetStrokeColorWithColor(context_, colorRef);
        
        if (ipaint->shaderImg_ != NULL) {
            CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern (NULL);
            CGContextSetFillColorSpace (context_, patternSpace);
            CGColorSpaceRelease (patternSpace);
            
            CGRect patternRect = CGRectMake(0, 0, CGImageGetWidth(ipaint->shaderImg_), CGImageGetHeight(ipaint->shaderImg_));
            CGPatternRef pattern = CGPatternCreate(ipaint->shaderImg_, patternRect, ipaint->shaderShift_, patternRect.size.width, patternRect.size.height, kCGPatternTilingConstantSpacingMinimalDistortion, YES, &patternCallbacks_);
            
            CGFloat comps[4];
            comps[0] = 1.f;
            comps[1] = 1.f;
            comps[2] = 1.f;
            comps[3] = 1.f;
            CGContextSetFillPattern(context_, pattern, comps);
            
            CGContextAddPath(context_, ipath->path_);
            CGContextFillPath(context_);
            
            CGPatternRelease(pattern);
        } else {
            NSUInteger strokeLengthCounts = [ipaint->strokeLengths_ count];
            if (strokeLengthCounts > 0) {
                CGFloat *floats = malloc(sizeof(CGFloat)*strokeLengthCounts);
                for (int i=0; i < strokeLengthCounts; i++) {
                    floats[i] = [[ipaint->strokeLengths_ objectAtIndex:i] floatValue];
                }
                CGContextSetLineDash(context_, 0, floats, strokeLengthCounts);
                free(floats);
            }
            CGContextSetFillColorWithColor(context_, colorRef);
        
            CGContextAddPath(context_, ipath->path_);
            
            CGPathDrawingMode pathDrawMode = (CGPathDrawingMode)kCGPathStroke;
            if (ipaint->style_ == OrgMapsforgeCoreGraphicsStyle_FILL) {
                if (ipath->fillRule_ == OrgMapsforgeCoreGraphicsFillRule_EVEN_ODD) {
                    pathDrawMode = (CGPathDrawingMode)kCGPathEOFill;
                } else if (ipath->fillRule_ == OrgMapsforgeCoreGraphicsFillRule_NON_ZERO) {
                    pathDrawMode = (CGPathDrawingMode)kCGPathFill;
                }
            } else if (ipaint->style_ == OrgMapsforgeCoreGraphicsStyle_STROKE) {
                pathDrawMode = (CGPathDrawingMode)kCGPathStroke;
            }
            CGContextDrawPath(context_, pathDrawMode);
        }

        CGColorRelease(colorRef);
        
        CGContextRestoreGState(context_);
    }
}

- (void)drawTextWithNSString:(NSString *)text
                     withInt:(jint)x
                     withInt:(jint)y
                   withAngle:(CGFloat)theta
withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        IOSPaint *ipaint = (IOSPaint*)paint;
        
        CGContextSaveGState(context_);

        jint contextHeight = [self getHeight];

        // set up to make sure the text isnt upside down
        CGContextSetTextMatrix(context_, CGAffineTransformIdentity);
        CGContextTranslateCTM(context_, 0, contextHeight);
        CGContextScaleCTM(context_, 1.0, -1.0);

        // translate and rotate where to draw
        CGContextTranslateCTM(context_, x, contextHeight-y);
        CGContextRotateCTM(context_, -theta);

        // generate the attributed string
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        jint colorInt = ipaint->color_;
        CGFloat colorComponents[4];
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        CGColorRef fillColor = CGColorCreate(rgbcolorSpace, colorComponents);
        
        colorComponents[2] = 0.f;
        colorComponents[1] = 0.f;
        colorComponents[0] = 0.f;
        colorComponents[3] = 1.f;
        CGColorRef strokeColor = CGColorCreate(rgbcolorSpace, colorComponents);
        
        CGColorSpaceRelease(rgbcolorSpace);

        NSString *fontName = [ipaint fontName];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, ipaint->textSize_, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (id)fontRef, (NSString *)kCTFontAttributeName,
                                        (id)fillColor, (NSString *)(kCTForegroundColorAttributeName),
                                        (id)strokeColor, (NSString *) kCTStrokeColorAttributeName,
                                        (id)[NSNumber numberWithFloat:-2.f], (NSString *)kCTStrokeWidthAttributeName
                                        , nil];

        NSAttributedString* attString = [[[NSAttributedString alloc] initWithString:text attributes:attrDictionary] autorelease];

        // release everything created to generate the attr string
        CGColorRelease(strokeColor);
        CGColorRelease(fillColor);
        CFRelease(fontRef);

        // need a bounding box for drawing. the Y math helps position it perfectly
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect r = CGRectMake(0, -98+(ipaint->textSize_/2.f), 100, 100);
        CGPathAddRect(path, NULL, r);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
        
        CTFrameDraw(frame, context_);
        
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        
        CGContextRestoreGState(context_);
    }
}

- (void)drawTextWithNSString:(NSString *)text
                     withInt:(jint)x
                     withInt:(jint)y
withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    [self drawTextWithNSString:text withInt:x withInt:y withAngle:0 withOrgMapsforgeCoreGraphicsPaint:paint];
}


- (void)drawTextRotatedWithNSString:(NSString *)text
                            withInt:(jint)x1
                            withInt:(jint)y1
                            withInt:(jint)x2
                            withInt:(jint)y2
  withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paint {
    CGFloat xDiff = x2-x1;
    CGFloat yDiff = y2-y1;
    CGFloat theta = atan2(yDiff, xDiff);
    
    [self drawTextWithNSString:text withInt:x1 withInt:y1 withAngle:theta withOrgMapsforgeCoreGraphicsPaint:paint];
}

- (void)fillColorWithOrgMapsforgeCoreGraphicsColorEnum:(OrgMapsforgeCoreGraphicsColorEnum *)color {
    jint colorInt = [IOSGraphicFactory getIntColorFromEnum:color];
    [self fillColorWithInt:colorInt];
}

- (void)fillColorWithInt:(jint)color {
    @synchronized (syncro) {
        if (context_ == NULL) {
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

        CGContextSetRGBFillColor(context_, red, green, blue, alpha);
        CGContextFillRect(context_, CGRectMake(0.f, 0.f, size_.width, size_.height));
    }
}

- (void)resetClip {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        NSLog(@"reset clip");
        //CGRect r = CGRectMake(0, 0, size_.width, size_.height);
        //CGContextClipToRect(context_, r);
    }
}

- (void)setClipWithInt:(jint)left
               withInt:(jint)top
               withInt:(jint)width
               withInt:(jint)height {
    @synchronized (syncro) {
        if (context_ == NULL) {
            return;
        }
        NSLog(@"set clip %d,%d, %d,%d", left, top, width, height);
        //CGRect r = CGRectMake(left, top, width, height);
        //CGContextClipToRect(context_, r);
    }
}

@end
