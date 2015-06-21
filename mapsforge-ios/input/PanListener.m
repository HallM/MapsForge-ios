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

#import "PanListener.h"

@implementation PanListener

- (id)initWithMapPosition:(OrgMapsforgeMapModelMapViewPosition*)mapPosition {
    self = [super initWithMapPosition:mapPosition];
    if (self) {
        mapViewPosition = [mapPosition retain];
        previousTranslation = CGPointMake(0.f, 0.f);
    }
    return self;
}

- (void)dealloc {
    [mapViewPosition release]; mapViewPosition = nil;
    [super dealloc];
}

- (void)handlePan:(UIPanGestureRecognizer*)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        previousTranslation = [panGesture locationInView:panGesture.view];
    }
    
    CGPoint point = [panGesture locationInView:panGesture.view];
    CGPoint translation = CGPointMake(point.x-previousTranslation.x, point.y-previousTranslation.y);
    [mapViewPosition moveCenterWithDouble:translation.x withDouble:translation.y];
    previousTranslation = point;
}

@end
