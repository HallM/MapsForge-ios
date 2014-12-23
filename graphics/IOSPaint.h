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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "org/mapsforge/core/graphics/Paint.h"

#import "org/mapsforge/core/graphics/Cap.h"
#import "org/mapsforge/core/graphics/Join.h"
#import "org/mapsforge/core/graphics/Style.h"
#import "org/mapsforge/core/graphics/Align.h"
#import "org/mapsforge/core/graphics/FontFamily.h"
#import "org/mapsforge/core/graphics/FontStyle.h"

@interface IOSPaint : NSObject <OrgMapsforgeCoreGraphicsPaint> {
@public
    jint color_;
    OrgMapsforgeCoreGraphicsCap capStyle_;
    OrgMapsforgeCoreGraphicsJoin joinStyle_;
    OrgMapsforgeCoreGraphicsStyle style_;
    OrgMapsforgeCoreGraphicsAlign alignStyle_;
    NSMutableArray *strokeLengths_;
    CGFloat strokeWidth_;
    CGFloat textSize_;
    OrgMapsforgeCoreGraphicsFontFamily fontFamily_;
    OrgMapsforgeCoreGraphicsFontStyle fontStyle_;
    
    CGImageRef shaderImg_;
    CGAffineTransform shaderShift_;
}

-(NSString*)fontName;

@end
