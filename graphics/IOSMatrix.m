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

#import "IOSMatrix.h"

@implementation IOSMatrix

- (id)init {
    self = [super init];
    if (self) {
        matrix_ = CGAffineTransformIdentity;
    }
    return self;
}

- (void)reset {
    matrix_ = CGAffineTransformIdentity;
}

- (void)rotateWithFloat:(jfloat)theta {
    matrix_ = CGAffineTransformRotate(matrix_, theta);
}

- (void)rotateWithFloat:(jfloat)theta
              withFloat:(jfloat)pivotX
              withFloat:(jfloat)pivotY {
    matrix_ = CGAffineTransformTranslate(matrix_, pivotX, pivotY);
    matrix_ = CGAffineTransformRotate(matrix_, (3.1415/2)-theta);
    matrix_ = CGAffineTransformTranslate(matrix_, -pivotX, -pivotY);
}

- (void)scale__WithFloat:(jfloat)scaleX
               withFloat:(jfloat)scaleY {
    matrix_ = CGAffineTransformScale(matrix_, scaleX, scaleY);
}

- (void)scale__WithFloat:(jfloat)scaleX
               withFloat:(jfloat)scaleY
               withFloat:(jfloat)pivotX
               withFloat:(jfloat)pivotY {
    matrix_ = CGAffineTransformTranslate(matrix_, pivotX, pivotY);
    matrix_ = CGAffineTransformScale(matrix_, scaleX, scaleY);
    matrix_ = CGAffineTransformTranslate(matrix_, -pivotX, -pivotY);
}

- (void)translateWithFloat:(jfloat)translateX
                 withFloat:(jfloat)translateY {
    matrix_ = CGAffineTransformTranslate(matrix_, translateX, translateY);
}

@end
