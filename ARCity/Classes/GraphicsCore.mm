//
//  GraphicsCore.m
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GraphicsCore.h"
#import "Plot+DataAccess.h"
#import "GCItem.h"
#import "GameSession+DataAccess.h"

@interface GraphicsCore ()

@property (nonatomic) metaio::IMetaioSDKIOS *metaioSDK;
@property metaio::IGeometry *selection;
@property (nonatomic, strong) NSMutableDictionary *graphicsItems;
@property (nonatomic) GameSession *currentSession;
@property (nonatomic) NSTimer *timer;

@end

@implementation GraphicsCore

+ (instancetype)graphicsCoreWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK {
    GraphicsCore *graphicsCore = [[GraphicsCore alloc] init];
    
    graphicsCore.metaioSDK = metaioSDK;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"selection" ofType:@"zip"];
    
    if (modelPath) {
        graphicsCore.selection = metaioSDK->createGeometry([modelPath UTF8String]);
        
        if (graphicsCore.selection) {
            
            graphicsCore.selection->setScale(metaio::Vector3d(1.5, 1.5, 1.5));
            graphicsCore.selection->setRotation(metaio::Rotation(M_PI_2, 0, 0));
            graphicsCore.selection->setCoordinateSystemID(1000);
            graphicsCore.selection->setVisible(false);
            
        } else {
            NSLog(@"Error! Cannot load plot geometry!");
            assert(false);
        }
        
    } else {
        NSLog(@"Cannot find model");
    }
    
    
    return graphicsCore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _graphicsItems = [@{} mutableCopy];
        
        
    }
    return self;
}

//- (metaio::IMetaioSDKIOS *)metaioSDK {
//    // Throw assertion if metaio SDK is not set
//    assert(self.metaioSDK != nil);
//    return self.metaioSDK;
//}

- (void)startDrawingGameSession:(GameSession *)session {
    self.currentSession = session;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSession) userInfo:nil repeats:YES];
}

- (void)stopDrawingCurrentGameSession {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.currentSession = nil;
    }
}

- (void)updateSession {
    for (Plot *plot in self.currentSession.plots) {
        [self drawPlot:plot];
    }
}

- (void)drawPlot:(Plot *)plot {
    
    // Check for CGItem at marker id
    GCItem *item = self.graphicsItems[plot.markerId];
    
    // If not found, create one with default placeholder
    if (!item) {
        item = [GCItem item];
        
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"plot" ofType:@"zip"];
        
        if (modelPath) {
            item.placeholder = self.metaioSDK->createGeometry([modelPath UTF8String]);

            if (item.placeholder) {

                item.placeholder->setScale(metaio::Vector3d(1.5, 1.5, 1.5));
                item.placeholder->setRotation(metaio::Rotation(M_PI_2, 0, 0));
                item.placeholder->setCoordinateSystemID(plot.markerId.intValue);

            } else {
                NSLog(@"Error! Cannot load plot geometry!");
                assert(false);
            }

        } else {
            NSLog(@"Cannot find model");
        }
        
        [self.graphicsItems setObject:item forKey:plot.markerId];
    }
    
    // If plot have a building but CGItem not, create its geometry
    if (plot.building && !item.object) {
        
        item.object = [self loadGeometryFromPath:[plot.building pathToGeometry]];
        item.object->setCoordinateSystemID(plot.markerId.intValue);
        
        if (item.placeholder->isVisible()) {
            item.placeholder->setVisible(false);
        }
        
    } // Plot changed his building
    else if (plot.building && item.object && item.type != plot.building.type) {
       
        // first unload current geometry
        self.metaioSDK->unloadGeometry(item.object);
        
        // Then load new
        item.object = [self loadGeometryFromPath:[plot.building pathToGeometry]];
        item.object->setCoordinateSystemID(plot.markerId.intValue);
        
        
    } else if (!plot.building && item.object) {
        self.metaioSDK->unloadGeometry(item.object);
        item.placeholder->setVisible(true);
    }
    
    
}

- (metaio::IGeometry *)loadGeometryFromPath:(NSString *)path {
    
    metaio::IGeometry *geometry = nil;
    
    if (path) {
        geometry = self.metaioSDK->createGeometry([path UTF8String]);
        
        if (geometry) {

            geometry->setScale(metaio::Vector3d(6, 6, 6));
            geometry->setRotation(metaio::Rotation(M_PI_2, 0, 0));
            
        } else {
            NSLog(@"Error! Cannot load plot geometry!");
            assert(false);
        }
        
    } else {
        NSLog(@"Cannot find model");
    }
    
    return geometry;
}

- (NSInteger)markerIdWithTouchPoint:(CGPoint)touchPoint {
    metaio::IGeometry *geometry = self.metaioSDK->getGeometryFromViewportCoordinates(touchPoint.x, touchPoint.y, true);
    
    if (geometry) {
        return (NSInteger)geometry->getCoordinateSystemID();
    }
    
    NSLog(@"Not found");
    
    return -1;
}

- (void)selectPlotAtMarkerId:(NSInteger)markerId {
    if (self.selection) {
        
        if (self.selection->getCoordinateSystemID() == (int)markerId) {
            self.selection->setVisible(!self.selection->isVisible());
        } else {
            self.selection->setCoordinateSystemID((int)markerId);
            self.selection->setVisible(true);
        }
        
    } else {
        NSLog(@"Error: Missing selection geometry");
    }
}

//
//
//        // Test if path exist
//

@end
