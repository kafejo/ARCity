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
#import "GlobalConfig.h"

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
            
            graphicsCore.selection->setScale(metaio::Vector3d(6, 6, 6));
            graphicsCore.selection->setRotation(metaio::Rotation(M_PI_2, 0, 0));
            graphicsCore.selection->setCoordinateSystemID(1000);
            graphicsCore.selection->setVisible(false);
            graphicsCore.selection->setTransparency(0.4f);
            graphicsCore.selection->setAnimationSpeed(12.0f);
            
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
        
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"empty_zone" ofType:@"zip"];
        
        if (modelPath) {
            item.placeholder = self.metaioSDK->createGeometry([modelPath UTF8String]);

            if (item.placeholder) {

                item.placeholder->setScale(metaio::Vector3d(0.15, 0.15, 0.15));
                //item.placeholder->setRotation(metaio::Rotation(M_PI_2, 0, 0));
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
    if (plot.plotZone && !item.object) {
        
        item.object = [self loadGeometryFromPath:[GlobalConfig pathToModelForZoneType:plot.plotZone.type level:plot.plotZone.level]];
        item.object->setCoordinateSystemID(plot.markerId.intValue);
        item.type = plot.plotZone.type;
       [self applyBuildingSettings:item.object];
        
        if (item.placeholder->isVisible()) {
            item.placeholder->setVisible(false);
        }
        
    } // Plot changed his building
    else if (plot.plotZone && item.object && item.type != plot.plotZone.type) {
       
        // first unload current geometry
        self.metaioSDK->unloadGeometry(item.object);
        
        // Then load new
        item.object = [self loadGeometryFromPath:[GlobalConfig pathToModelForZoneType:plot.plotZone.type level:plot.plotZone.level]];
        item.object->setCoordinateSystemID(plot.markerId.intValue);
        [self applyBuildingSettings:item.object];
        item.type = plot.plotZone.type;
        
    } else if (!plot.plotZone && item.object) {
        self.metaioSDK->unloadGeometry(item.object);
        item.placeholder->setVisible(true);
    }
}

- (void)applyBuildingSettings:(metaio::IGeometry *)object {
    object->setScale(metaio::Vector3d(0.15, 0.15, 0.15));
    
//    NSInteger random = arc4random() % 4;
//    switch (random) {
//        case 0:
//            object->setRotation(metaio::Rotation(0, 0, M_PI));
//            break;
//        case 1:
//            object->setRotation(metaio::Rotation(0, 0, M_PI_2));
//            break;
//        case 2:
//            object->setRotation(metaio::Rotation(0, 0, M_PI + M_PI_2));
//            break;
//            
//        default:
//            break;
//    }
    
    //item.object->setRotation(metaio::Rotation(M_PI_2, 0, 0));
}

- (metaio::IGeometry *)loadGeometryFromPath:(NSString *)path {
    
    metaio::IGeometry *geometry = nil;
    
    if (path) {
        geometry = self.metaioSDK->createGeometry([path UTF8String]);
        
        if (geometry) {

//            geometry->setScale(metaio::Vector3d(0.5, 0.5, 0.5));
//            geometry->setRotation(metaio::Rotation(M_PI_2, 0, 0));
            
        } else {
            NSLog(@"Error! Cannot load plot geometry!");
            assert(false);
        }
        
    } else {
        NSLog(@"Cannot find model");
    }
    
    return geometry;
}

- (NSNumber *)markerIdWithTouchPoint:(CGPoint)touchPoint {
    metaio::IGeometry *geometry = self.metaioSDK->getGeometryFromViewportCoordinates(touchPoint.x, touchPoint.y, true);
    
    if (geometry) {
        return @(geometry->getCoordinateSystemID());
    } else {
        return nil;
    }

}

- (void)selectMarkerId:(NSInteger)markerId {
    if (self.selection) {
        
        if (self.selection->getCoordinateSystemID() == (int)markerId) {
            
            if (self.selection->isVisible()) {

                
                self.selection->setVisible(false);
                self.selection->stopAnimation();
                
                if (self.delegate) {
                    [self.delegate didDeselectMarker:@(self.selection->getCoordinateSystemID())];
                }
            } else {
                
                self.selection->startAnimation("Take 001", true);
                self.selection->setVisible(true);
                
                if (self.delegate) {
                    [self.delegate didSelectMarker:@(self.selection->getCoordinateSystemID())];
                }
            }
            
            

        } else {
            self.selection->setCoordinateSystemID((int)markerId);
            
            self.selection->startAnimation("Take 001", true);
            self.selection->setVisible(true);
            
            if (self.delegate) {
                [self.delegate didSelectMarker:@(self.selection->getCoordinateSystemID())];
            }
        }
        
    } else {
        NSLog(@"Error: Missing selection geometry");
    }
}

- (BOOL)isSelectedMarker {
    return self.selection->isVisible();
}
- (NSNumber *)selectedMarkerId {
    if (self.selection->isVisible()) {
        return @(self.selection->getCoordinateSystemID());
    } else {
        return nil;
    }
}

- (NSNumber *)deselectSelectedMarker {
    if (self.selection->isVisible()) {
        self.selection->setVisible(false);
        self.selection->stopAnimation();
        if (self.delegate) {
            [self.delegate didDeselectMarker:@(self.selection->getCoordinateSystemID())];
        }
        
        return @(self.selection->getCoordinateSystemID());
        
    } else {
        return nil;
    }
}

//
//
//        // Test if path exist
//

@end
