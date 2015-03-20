//
//  Engine.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Engine.h"

@interface Engine ()

@property (nonatomic, setter=setMetaioSDK:) metaio::IMetaioSDKIOS *_metaioSDK;

@end

@implementation Engine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.plots = @[];
        
    }
    return self;
}

+ (instancetype)sharedEngine {
    static Engine * sharedEngine;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[Engine alloc] init];
    });
    
    return sharedEngine;
}

- (void)setupWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK {
    self.metaioSDK = metaioSDK;
    
    NSString* selectionGeometryPath = [[NSBundle mainBundle] pathForResource:@"selection" ofType:@"zip"];
    metaio::IGeometry *selectionGeometry = nil;
    
    if (selectionGeometryPath) {
        selectionGeometry = self.metaioSDK->createGeometry([selectionGeometryPath UTF8String]);
    } else {
        NSLog(@"Cannot find model");
    }
    
    selectionGeometry->setScale(metaio::Vector3d(6, 6, 6));
    selectionGeometry->setRotation(metaio::Rotation(M_PI_2, 0, 0));
    selectionGeometry->setCoordinateSystemID(1);
    selectionGeometry->setTransparency(0.4f);
    selectionGeometry->setVisible(false);
    selectionGeometry->setAnimationSpeed(12.0f);
    self.selection = selectionGeometry;
    
    NSMutableArray *tPlots = [@[] mutableCopy];
    
    for (int i = 0; i < GAMEBOARD_SIZE; i++) {
        [tPlots addObject:[Plot plotWithMarkerId:i + 1]];
    }
    _plots = [tPlots copy];
    
}

- (metaio::IMetaioSDKIOS *)metaioSDK {
    // Throw assertion if metaio SDK is not set
    assert(self._metaioSDK != nil);
    return self._metaioSDK;
}

- (NSArray *)plots {
    if (!_plots) {
        
        NSLog(@"Engine setup needed!");
        assert(false);
    }
    
    return _plots;
}

- (Plot *)plotForGeometry:(metaio::IGeometry *)geometry {
    if (geometry) {
        
        NSUInteger geometryMarkerId = geometry->getCoordinateSystemID();
        
        for (Plot *plot in self.plots) {
            if (plot.markerId == geometryMarkerId) {
                return plot;
            }
        }
    }
    
    NSLog(@"Plot not found!");
    assert(false);
    
    return nil;
}

- (void)removeBuildingAtPlot:(Plot *)plot {
    if (plot.building) {
        self.metaioSDK->unloadGeometry(plot.building.geometry);
    }
}

- (void)processTouchAtPoint:(CGPoint)touchPoint {
    
    // ask SDK if the user picked an object
    // the 'true' flag tells SDK to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* geometry = self.metaioSDK->getGeometryFromViewportCoordinates(touchPoint.x, touchPoint.y, true);
    
    
    if (geometry) {
        
        metaio::IGeometry *selectedGeometry = [self selection];
        
        if (selectedGeometry->isVisible()) {
            selectedGeometry->setVisible(false);
            selectedGeometry->stopAnimation();
            //            self.nameLabel.text = @"";
            //            self.populationLabel.text = @"";
        } else {
            Plot *plot = [self plotForGeometry:selectedGeometry];
            if (plot) {
                // Notifity delegate if user did select plot
                [self.delegate didSelectPlot:plot];
                
            }
            
            selectedGeometry->setCoordinateSystemID(geometry->getCoordinateSystemID());
            selectedGeometry->setVisible(true);
            selectedGeometry->startAnimation("Take 001", true);
        }
    }

}

@end
