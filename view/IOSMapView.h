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

#import <UIKit/UIKit.h>
#import "AssetRenderTheme.h"
#import "ScaleListener.h"
#import "PanListener.h"
#import "DoubleTapListener.h"

#import "org/mapsforge/map/view/MapView.h"

#import "org/mapsforge/core/graphics/GraphicFactory.h"
#import "org/mapsforge/core/model/Dimension.h"
#import "org/mapsforge/map/controller/FrameBufferController.h"
#import "org/mapsforge/map/controller/LayerManagerController.h"
#import "org/mapsforge/map/controller/MapViewController.h"
#import "org/mapsforge/map/layer/LayerManager.h"
#import "org/mapsforge/map/model/Model.h"
#import "org/mapsforge/map/view/FrameBuffer.h"
#import "org/mapsforge/map/scalebar/MapScaleBar.h"

@interface IOSMapView : UIView <OrgMapsforgeMapViewMapView> {
    OrgMapsforgeMapViewFrameBuffer *frameBuffer;
    OrgMapsforgeMapControllerFrameBufferController *frameBufferController;
    OrgMapsforgeMapLayerLayerManager *layerManager;
    OrgMapsforgeMapControllerLayerManagerController *layerManagerController;
    OrgMapsforgeMapModelModel *model;
    OrgMapsforgeMapScalebarMapScaleBar *mapScaleBar;
    OrgMapsforgeMapControllerMapViewController *mapViewController;
    
    id<OrgMapsforgeCoreGraphicsGraphicFactory> graphicFactory;
    AssetRenderTheme *renderTheme;
    
    ScaleListener *scaleListener;
    PanListener *panListener;
    DoubleTapListener *doubleTapListener;
}

@end
