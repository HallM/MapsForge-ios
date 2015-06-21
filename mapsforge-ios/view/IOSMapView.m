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

#import "IOSMapView.h"
#import "IOSGraphicFactory.h"
#import "IOSCanvas.h"
#import "AssetRenderTheme.h"

#import "org/mapsforge/map/layer/cache/TileCache.h"
#import "org/mapsforge/map/layer/cache/InMemoryTileCache.h"
#import "org/mapsforge/map/layer/cache/FileSystemTileCache.h"
#import "org/mapsforge/map/layer/cache/TwoLevelTileCache.h"
#import "org/mapsforge/map/layer/renderer/TileRendererLayer.h"
#import "org/mapsforge/map/layer/Layers.h"
#import "org/mapsforge/map/rendertheme/InternalRenderTheme.h"
#import "org/mapsforge/map/model/MapViewPosition.h"
#import "org/mapsforge/map/model/MapViewDimension.h"
#import "org/mapsforge/core/model/MapPosition.h"
#import "org/mapsforge/core/model/LatLong.h"
#import "org/mapsforge/map/scalebar/DefaultMapScaleBar.h"

#import "org/mapsforge/map/layer/download/TileDownloadLayer.h"
#import "org/mapsforge/map/layer/download/tilesource/OpenStreetMapMapnik.h"

#import "java/io/File.h"

@interface IOSMapView ()

@end

@implementation IOSMapView

-(id)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        [model->mapViewDimension_ setDimensionWithOrgMapsforgeCoreModelDimension:[self getDimension]];
    }
    return self;
}

- (void)sharedInit {
    graphicFactory = [[IOSGraphicFactory alloc] init];
    model = [[OrgMapsforgeMapModelModel alloc] init];
    
    frameBuffer = [[OrgMapsforgeMapViewFrameBuffer alloc] initWithOrgMapsforgeMapModelFrameBufferModel:model->frameBufferModel_ withOrgMapsforgeMapModelDisplayModel:model->displayModel_ withOrgMapsforgeCoreGraphicsGraphicFactory:graphicFactory];
    frameBufferController = [OrgMapsforgeMapControllerFrameBufferController createWithOrgMapsforgeMapViewFrameBuffer:frameBuffer withOrgMapsforgeMapModelModel:model];
    layerManager = [[OrgMapsforgeMapLayerLayerManager alloc] initWithOrgMapsforgeMapViewMapView:self withOrgMapsforgeMapModelMapViewPosition:model->mapViewPosition_ withOrgMapsforgeCoreGraphicsGraphicFactory:graphicFactory];
    [layerManager start];
    layerManagerController = [OrgMapsforgeMapControllerLayerManagerController createWithOrgMapsforgeMapLayerLayerManager:layerManager withOrgMapsforgeMapModelModel:model];
    mapViewController = [OrgMapsforgeMapControllerMapViewController createWithOrgMapsforgeMapViewMapView:self withOrgMapsforgeMapModelModel:model];

    mapScaleBar = [[OrgMapsforgeMapScalebarDefaultMapScaleBar alloc] initWithOrgMapsforgeMapModelMapViewPosition:model->mapViewPosition_ withOrgMapsforgeMapModelMapViewDimension:model->mapViewDimension_ withOrgMapsforgeCoreGraphicsGraphicFactory:graphicFactory withOrgMapsforgeMapModelDisplayModel:model->displayModel_];
    // TODO: FPSCounter, ScaleBar
    // TODO: MapZoomControls
    
    scaleListener = [[ScaleListener alloc] initWithMapPosition:model->mapViewPosition_];
    UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:scaleListener action:@selector(handlePinch:)] autorelease];
    [self addGestureRecognizer:pinchGesture];
    
    panListener = [[PanListener alloc] initWithMapPosition:model->mapViewPosition_];
    UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:panListener action:@selector(handlePan:)] autorelease];
    [self addGestureRecognizer:panGesture];
    
    doubleTapListener = [[DoubleTapListener alloc] initWithMapPosition:model->mapViewPosition_ andMapDimension:model->mapViewDimension_];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:doubleTapListener action:@selector(handleDoubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (id<OrgMapsforgeMapLayerCacheTileCache>)createTileCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/tilecache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    // TODO: determine real numbers of tiles to cache!
    OrgMapsforgeMapLayerCacheInMemoryTileCache *inMemCache = [[[OrgMapsforgeMapLayerCacheInMemoryTileCache alloc] initWithInt:16] autorelease];
    if (dataPath && [[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        JavaIoFile *jFile = [[[JavaIoFile alloc] initWithNSString:dataPath] autorelease];
        OrgMapsforgeMapLayerCacheFileSystemTileCache *secondLevelTileCache = [[[OrgMapsforgeMapLayerCacheFileSystemTileCache alloc] initWithInt:128 withJavaIoFile:jFile withOrgMapsforgeCoreGraphicsGraphicFactory:graphicFactory withBoolean:NO withInt:0] autorelease];
        return [[[OrgMapsforgeMapLayerCacheTwoLevelTileCache alloc] initWithOrgMapsforgeMapLayerCacheTileCache:inMemCache withOrgMapsforgeMapLayerCacheTileCache:secondLevelTileCache] autorelease];
    } else {
        return inMemCache;
    }
}

- (void)dealloc {
    [doubleTapListener release]; doubleTapListener = nil;
    [panListener release]; panListener = nil;
    [scaleListener release]; scaleListener = nil;
    [layerManager interrupt];
    [frameBuffer release]; frameBuffer = nil;
    [frameBufferController release]; frameBufferController = nil;
    [mapScaleBar release]; mapScaleBar = nil;
    [layerManager release]; layerManager = nil;
    [layerManagerController release]; layerManagerController = nil;
    [model release]; model = nil;
    [mapViewController release]; mapViewController = nil;
    [graphicFactory release]; graphicFactory = nil;
    [renderTheme release]; renderTheme = nil;
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (model) {
        [model->mapViewDimension_ setDimensionWithOrgMapsforgeCoreModelDimension:[self getDimension]];
    }
}

- (OrgMapsforgeCoreModelDimension *)getDimension {
    return [[[OrgMapsforgeCoreModelDimension alloc] initWithInt:[self getWidth] withInt:[self getHeight]] autorelease];
}

- (jint)getHeight {
    return (jint)self.frame.size.height;
}

- (jint)getWidth {
    return (jint)self.frame.size.width;
}

- (OrgMapsforgeMapViewFpsCounter *)getFpsCounter {
    // TODO:
    return nil;
}

- (OrgMapsforgeMapScalebarMapScaleBar *)getMapScaleBar {
    return mapScaleBar;
}

- (void)setMapScaleBarWithOrgMapsforgeMapScalebarMapScaleBar:(OrgMapsforgeMapScalebarMapScaleBar *)inmapScaleBar {
    // TODO:
    [mapScaleBar release]; mapScaleBar = nil;
    mapScaleBar = inmapScaleBar;
}

- (OrgMapsforgeMapViewFrameBuffer *)getFrameBuffer {
    return frameBuffer;
}

- (OrgMapsforgeMapLayerLayerManager *)getLayerManager {
    return layerManager;
}

- (OrgMapsforgeMapModelModel *)getModel {
    return model;
}

- (void)repaint {
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)destroy {
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize cSize = self.frame.size;
    IOSCanvas *canvas = [[IOSCanvas alloc] initWithContext:context andSize:cSize];
    [frameBuffer drawWithOrgMapsforgeCoreGraphicsGraphicContext:canvas];
    [canvas destroy];
    [canvas release];
}

@end
