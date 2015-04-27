//
//  Building.m
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Zone+DataAccess.h"

@implementation Zone (DataAccess)

+ (instancetype)zoneWithType:(ZoneType)type {
    Zone *zone = [Zone MR_createEntity];
    zone.type_id = @(type);
    
    return zone;
}

- (ZoneType)type {
    return (ZoneType)[self.type_id integerValue];
}

- (NSString *)pathToGeometry {
    if (self.type == ZoneTypeHouse) {
        return [[NSBundle mainBundle] pathForResource:@"house_zone" ofType:@"zip"];
    } else {
        return @"";
    }
}

@end
