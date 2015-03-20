//
//  Building.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Plot.h"
#import "Engine.h"

NSUInteger const kPlotMarkerIdNone = 1000;

@interface Plot ()

@property (nonatomic, assign, setter=setMarkerId:) NSUInteger marker_id;

@end

@implementation Plot

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"";
        
        _modelPathName = @"";
        _population = 0;
        _building = nil;
        _marker_id = kPlotMarkerIdNone;
        
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"plot" ofType:@"zip"];
        
        // Test if path exist
        if (modelPath) {
            _geometry = [[Engine sharedEngine] metaioSDK]->createGeometry([modelPath UTF8String]);
            
            if (_geometry) {
#if DEBUG
                NSLog(@"Loaded plot: %@", [self description]);
                _geometry->setScale(metaio::Vector3d(1.5, 1.5, 1.5));
                _geometry->setRotation(metaio::Rotation(M_PI_2, 0, 0));
                _geometry->setTransparency(0.0f);
#endif
            } else {
                NSLog(@"Error! Cannot load plot geometry!");
                assert(false);
            }
            
        } else {
            NSLog(@"Cannot find model");
        }
    }
    
    return self;
}

+ (instancetype)plot {
    Plot *plot = [[Plot alloc] init];
    
    return plot;
}

+ (instancetype)plotWithMarkerId:(NSUInteger)marker_id {
    Plot *plot = [Plot plot];
    [plot setMarkerId:marker_id];
    
    return plot;
}

- (void)setMarkerId:(NSUInteger)markerId {
    
    _marker_id = markerId;
    
    if (self.geometry) {
        self.geometry->setCoordinateSystemID((uint)markerId);
    }
    
    if (self.building) {
        [self.building setMarkerId:markerId];
    }
}

- (NSUInteger)markerId {
    return _marker_id;
}

- (void)removeBuilding {
    self.geometry->setCoordinateSystemID((uint)self.markerId);
    
    if (self.building) {
        [[Engine sharedEngine] metaioSDK]->unloadGeometry(self.building.geometry);
        self.building = nil;
    }

}

@end
