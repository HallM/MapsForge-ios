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

#import "IOSPointTextContainer.h"
#import "IOSCanvas.h"
#import "IOSMatrix.h"
#import "IOSPaint.h"

#import "org/mapsforge/core/model/Rectangle.h"
#import "org/mapsforge/core/model/Point.h"
#import "org/mapsforge/core/graphics/Position.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@implementation IOSPointTextContainer

- (void)withOrgMapsforgeCoreModelPoint:(OrgMapsforgeCoreModelPoint *)point
                                           withInt:(jint)priority
                                      withNSString:(NSString *)text
                 withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintFront
                 withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintBack
    withOrgMapsforgeCoreMapelementsSymbolContainer:(OrgMapsforgeCoreMapelementsSymbolContainer *)symbolContainer
          withOrgMapsforgeCoreGraphicsPositionEnum:(OrgMapsforgeCoreGraphicsPositionEnum *)position
                                           withInt:(jint)maxTextWidth {
    //self = [super initWithOrgMapsforgeCoreModelPoint:point withInt:priority withNSString:text withOrgMapsforgeCoreGraphicsPaint:paintFront withOrgMapsforgeCoreGraphicsPaint:paintBack withOrgMapsforgeCoreMapelementsSymbolContainer:symbolContainer withOrgMapsforgeCoreGraphicsPositionEnum:position withInt:maxTextWidth];
    //if (self) {
        boxWidth = self->textWidth_;
        boxHeight = self->textHeight_;

        IOSPaint *ipaintFront = (IOSPaint*)self->paintFront_;
        IOSPaint *ipaintBack = (IOSPaint*)self->paintBack_;
        
        CGColorSpaceRef rgbcolorSpace = CGColorSpaceCreateDeviceRGB();
        jint colorInt = ipaintFront->color_;
        CGFloat colorComponents[4];
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        CGColorRef fillColor = CGColorCreate(rgbcolorSpace, colorComponents);
        
        colorInt = ipaintBack != nil ? ipaintBack->color_ : 0xFF000000;
        colorComponents[2] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[1] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[0] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        colorInt = colorInt >> 8;
        colorComponents[3] = ((CGFloat)(colorInt & 0xff)) / 255.f;
        CGColorRef strokeColor = CGColorCreate(rgbcolorSpace, colorComponents);
        
        CGColorSpaceRelease(rgbcolorSpace);
        
        NSString *fontName = [ipaintFront fontName];
        int fontSize = ipaintBack != NULL ? ipaintBack->textSize_ : (ipaintFront != NULL ? ipaintFront->textSize_ : 10);
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (id)fontRef, (NSString *)kCTFontAttributeName,
                                        (id)fillColor, (NSString *)(kCTForegroundColorAttributeName),
                                        (id)strokeColor, (NSString *) kCTStrokeColorAttributeName,
                                        (id)[NSNumber numberWithFloat:-2.f], (NSString *)kCTStrokeWidthAttributeName
                                        , nil];
        
        frontAttrString = [[NSAttributedString alloc] initWithString:text attributes:attrDictionary];
        
        CGColorRelease(strokeColor);
        CGColorRelease(fillColor);
        CFRelease(fontRef);
        
        if (self->textWidth_ > maxTextWidth) {
            CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(frontAttrString));
            CGFloat widthConstraint = maxTextWidth;
            CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                            frameSetter,
                                                            CFRangeMake(0, text.length),
                                                            NULL,
                                                            CGSizeMake(widthConstraint, CGFLOAT_MAX),
                                                            NULL
                                                            );
            boxWidth = suggestedSize.width;
            boxHeight = suggestedSize.height;
            
            CFRelease(frameSetter);
        }
        
        jint left = 0, top = 0, right = 1, bottom = 1;
        switch ([position ordinal]) {
            case OrgMapsforgeCoreGraphicsPosition_AUTO:
            default:
            case OrgMapsforgeCoreGraphicsPosition_CENTER:
            {
                left = -boxWidth / 2.f;
                top = -boxHeight / 2.f;
                right = boxWidth / 2.f;
                bottom = boxHeight / 2.f;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_BELOW:
            {
                left = -boxWidth / 2.f;
                top = 0;
                right = boxWidth / 2.f;
                bottom = boxHeight;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_BELOW_LEFT:
            {
                left = -boxWidth;
                top = 0;
                right = 0;
                bottom = boxHeight;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_BELOW_RIGHT:
            {
                left = 0;
                top = 0;
                right = boxWidth;
                bottom = boxHeight;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_ABOVE_LEFT:
            {
                left = -boxWidth;
                top = -boxHeight;
                right = 0;
                bottom = 0;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_ABOVE_RIGHT:
            {
                left = 0;
                top = -boxHeight;
                right = boxWidth;
                bottom = 0;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_LEFT:
            {
                left = -boxWidth;
                top = -boxHeight / 2.f;
                right = 0;
                bottom = boxHeight / 2.f;
                break;
            }
            case OrgMapsforgeCoreGraphicsPosition_RIGHT:
            {
                left = 0;
                top = -boxHeight / 2.f;
                right = boxWidth;
                bottom = boxHeight / 2.f;
                break;
            }
        }
        
        self->boundary_ = [[OrgMapsforgeCoreModelRectangle alloc] initWithDouble:left withDouble:top withDouble:right withDouble:bottom];
    //}
    //return self;
}

- (id)initWithOrgMapsforgeCoreModelPoint:(OrgMapsforgeCoreModelPoint *)point
 withOrgMapsforgeCoreGraphicsDisplayEnum:(OrgMapsforgeCoreGraphicsDisplayEnum *)display
                                 withInt:(jint)priority
                            withNSString:(NSString *)text
       withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintFront
       withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintBack
withOrgMapsforgeCoreMapelementsSymbolContainer:(OrgMapsforgeCoreMapelementsSymbolContainer *)symbolContainer
withOrgMapsforgeCoreGraphicsPositionEnum:(OrgMapsforgeCoreGraphicsPositionEnum *)position
                                 withInt:(jint)maxTextWidth
{
    self = [super initWithOrgMapsforgeCoreModelPoint:(OrgMapsforgeCoreModelPoint *)point
             withOrgMapsforgeCoreGraphicsDisplayEnum:(OrgMapsforgeCoreGraphicsDisplayEnum *)display
                                             withInt:(jint)priority
                                        withNSString:(NSString *)text
                   withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintFront
                   withOrgMapsforgeCoreGraphicsPaint:(id<OrgMapsforgeCoreGraphicsPaint>)paintBack
      withOrgMapsforgeCoreMapelementsSymbolContainer:(OrgMapsforgeCoreMapelementsSymbolContainer *)symbolContainer
            withOrgMapsforgeCoreGraphicsPositionEnum:(OrgMapsforgeCoreGraphicsPositionEnum *)position
                                             withInt:(jint)maxTextWidth];
    if (self) {
        [self withOrgMapsforgeCoreModelPoint:point withInt:priority withNSString:text withOrgMapsforgeCoreGraphicsPaint:paintFront withOrgMapsforgeCoreGraphicsPaint:paintBack withOrgMapsforgeCoreMapelementsSymbolContainer:symbolContainer withOrgMapsforgeCoreGraphicsPositionEnum:position withInt:maxTextWidth];
    }
    return self;
}

- (void)dealloc {
    [frontAttrString release]; frontAttrString = nil;
    [super dealloc];
}

-(void)drawWithOrgMapsforgeCoreGraphicsCanvas:(id<OrgMapsforgeCoreGraphicsCanvas>)canvas withOrgMapsforgeCoreModelPoint:(OrgMapsforgeCoreModelPoint *)origin withOrgMapsforgeCoreGraphicsMatrix:(id<OrgMapsforgeCoreGraphicsMatrix>)matrix {
    IOSCanvas *icanvas = (IOSCanvas*)canvas;
    IOSMatrix *imatrix = (IOSMatrix*)matrix;
    // TODO: gotta get the rotations to work (maybe?)

    int x = (self->xy_->x_ - origin->x_) + self->boundary_->left_;
    int y = (self->xy_->y_ - origin->y_) + self->boundary_->top_;
    
    CGContextSaveGState(icanvas->context_);
    
    jint contextHeight = [icanvas getHeight];

    // set up to make sure the text isnt upside down
    CGContextSetTextMatrix(icanvas->context_, CGAffineTransformIdentity);
    CGContextTranslateCTM(icanvas->context_, 0, contextHeight);
    CGContextScaleCTM(icanvas->context_, 1.0, -1.0);

    // translate and rotate where to draw
    CGContextTranslateCTM(icanvas->context_, x, contextHeight-y);
    //CGContextConcatCTM(icanvas->context_, imatrix->matrix_);

    CGMutablePathRef path = CGPathCreateMutable();
    CGRect r = CGRectMake(0, -boxHeight, boxWidth+5, boxHeight*2); //-98+(ipaint->textSize_/2.f)
    CGPathAddRect(path, NULL, r);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)frontAttrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [frontAttrString length]), path, NULL);
    
    CTFrameDraw(frame, icanvas->context_);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);

    CGContextRestoreGState(icanvas->context_);
}

@end
