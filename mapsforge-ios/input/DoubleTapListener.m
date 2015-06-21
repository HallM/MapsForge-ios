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

#import "DoubleTapListener.h"
#import "IOSMapView.h"
#import "org/mapsforge/map/util/MapViewProjection.h"
#import "org/mapsforge/core/model/LatLong.h"
#import "org/mapsforge/core/model/Point.h"

@implementation DoubleTapListener

- (id)initWithMapPosition:(OrgMapsforgeMapModelMapViewPosition*)mapPosition andMapDimension:(OrgMapsforgeMapModelMapViewDimension*)mapDimension {
    self = [super initWithMapPosition:mapPosition];
    if (self) {
        mapViewDimension = mapDimension;
    }
    return self;
}

- (void)dealloc {
    [mapViewDimension release]; mapViewDimension = nil;
    [super dealloc];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)tapGesture {
    IOSMapView *view = (IOSMapView*)tapGesture.view;
    OrgMapsforgeMapUtilMapViewProjection *projection = [[OrgMapsforgeMapUtilMapViewProjection alloc] initWithOrgMapsforgeMapViewMapView:view];
    CGPoint location = [tapGesture locationInView:view];
    OrgMapsforgeCoreModelLatLong *coord = [projection fromPixelsWithDouble:location.x withDouble:location.y];
    [projection release];
    projection = nil;
    
    OrgMapsforgeCoreModelPoint *center = [[mapViewDimension getDimension] getCenter];
    jbyte zoomLevelDiff = 1;
    double moveHorizontal = (center->x_ - location.x) / 2.f;
    double moveVertical = (center->y_ - location.y) / 2.f;
    [mapViewPosition setPivotWithOrgMapsforgeCoreModelLatLong:coord];
    [mapViewPosition moveCenterAndZoomWithDouble:moveHorizontal withDouble:moveVertical withByte:zoomLevelDiff];
}

@end
