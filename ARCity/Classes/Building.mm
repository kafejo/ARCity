//
//  Building.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Building.h"

@interface Building ()

@end

@implementation Building

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.model = nil;
        self.modelPathName = @"";
        self.population = 0;
    }
    return self;
}

+ (instancetype)building {
    Building *building = [[Building alloc] init];
    
    return building;
}

+ (instancetype)buildingWithModel:(metaio::IGeometry *)model {
    Building *building = [[Building alloc] init];
    if (model) {
        building.model = model;
    }
    return building;
}

- (void)setMarkerID:(NSInteger)markerID {
    if (self.model) {
        self.model->setCoordinateSystemID((int)markerID);
    } else {
        NSLog(@"Cannot set markerID for object %@. You have to set its model first.", self.name);
    }
}

@end
