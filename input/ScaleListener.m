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

#import "ScaleListener.h"

static float threshold = 0.05f;

@implementation ScaleListener

- (id)initWithMapPosition:(OrgMapsforgeMapModelMapViewPosition*)mapPosition {
    self = [super initWithMapPosition:mapPosition];
    if (self) {
        scaleFactorApplied = 1.f;
        scaleFactorCumulative = 1.f;
    }
    return self;
}

- (void)dealloc {
    [mapViewPosition release]; mapViewPosition = nil;
    [super dealloc];
}

- (void)onScaleBegin:(UIPinchGestureRecognizer*)sender {
    scaleFactorApplied = 1.f;
    scaleFactorCumulative = 1.f;
}

- (void)onScale:(UIPinchGestureRecognizer*)sender {
    CGFloat scaleFactor = sender.scale;
    scaleFactorCumulative *= scaleFactor;
    if (scaleFactorCumulative < scaleFactorApplied - threshold || scaleFactorCumulative > scaleFactorApplied + threshold) {
        // hysteresis to avoid flickering
        [mapViewPosition setScaleFactorAdjustmentWithDouble:scaleFactorCumulative];
        scaleFactorApplied = scaleFactorCumulative;
    }
}

- (void)onScaleEnd:(UIPinchGestureRecognizer*)sender {
    jbyte zoomLevelDiff = (jbyte)round(log2(scaleFactorCumulative));
    [mapViewPosition zoomWithByte:zoomLevelDiff];
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self onScaleBegin:sender];
            break;
        case UIGestureRecognizerStateChanged:
            [self onScale:sender];
            break;
        case UIGestureRecognizerStateEnded:
            [self onScaleEnd:sender];
            break;
        default:
            break;
    }
}

@end
