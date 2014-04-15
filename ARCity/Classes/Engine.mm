//
//  Engine.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Engine.h"

@implementation Engine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buildings = [@[] mutableCopy];
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

- (Building *)buildingForGeometry:(metaio::IGeometry *)geometry {
    if (geometry) {
        for (Building *building in self.buildings) {
            if (building.model == geometry) {
                return building;
            }
        }
    }
    
    return nil;
}

@end
