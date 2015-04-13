//
//  Building.m
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Building+DataAccess.h"

@implementation Building (DataAccess)

+ (instancetype)buildingWithType:(BuildingType)type {
    Building *building = [Building MR_createEntity];
    building.type_id = @(type);
    
    return building;
}

- (BuildingType)type {
    return (BuildingType)[self.type_id integerValue];
}

- (NSString *)pathToGeometry {
    if (self.type == BuildingTypeHouse) {
        return [[NSBundle mainBundle] pathForResource:@"house_zone" ofType:@"zip"];
    } else {
        return @"";
    }
}

@end
