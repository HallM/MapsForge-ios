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

#import "IOSPath.h"

@implementation IOSPath

-(id)init {
    self = [super init];
    if (self) {
        path_ = CGPathCreateMutable();
        fillRule_ = OrgMapsforgeCoreGraphicsFillRule_NON_ZERO;
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(path_);
    [super dealloc];
}

- (void)clear {
    CGPathRelease(path_);
    path_ = NULL;
    path_ = CGPathCreateMutable();
}

- (void)lineToWithFloat:(jfloat)x
              withFloat:(jfloat)y {
    CGPathAddLineToPoint(path_, NULL, x, y);
}

- (void)moveToWithFloat:(jfloat)x
              withFloat:(jfloat)y {
    CGPathMoveToPoint(path_, NULL, x, y);
}

- (void)setFillRuleWithOrgMapsforgeCoreGraphicsFillRuleEnum:(OrgMapsforgeCoreGraphicsFillRuleEnum *)fillRule {
    fillRule_ = [fillRule ordinal];
}

@end
