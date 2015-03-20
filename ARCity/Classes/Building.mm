//
//  Building.m
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Building.h"
#import <metaioSDK/MetaioSDKViewController.h>


@interface Building()

@end

@implementation Building

+ (instancetype)buildingWithType:(BuildingType)type metaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK {
    Building *building = [[Building alloc] init];
    NSString *modelPath = nil;
    
    if (type == BuildingTypeHouse) {
        modelPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"zip"];
        
    }
    
    // Test if path exist
    if (modelPath) {
        building.geometry = metaioSDK->createGeometry([modelPath UTF8String]);
        
        if (building.geometry) {
#if DEBUG
            NSLog(@"Loaded building: %@", [building description]);
#endif
        } else {
            NSLog(@"Error! Cannot load building geometry!");
            assert(false);
        }
        
    } else {
        NSLog(@"Cannot find model");
    }
    
    return building;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.geometry = nil;
    }
    return self;
}

- (void)setMarkerId:(NSUInteger)marker_id {
    if (self.geometry) {
        self.geometry->setCoordinateSystemID((int)marker_id);
    } else {
        NSLog(@"Trying to set marker id for building without model!");
    }
    
}

@end
