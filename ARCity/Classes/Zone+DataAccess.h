//
//  Building.h
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Zone.h"

typedef NS_ENUM(NSUInteger, ZoneType) {
    ZoneTypeHouse = 0,
    ZoneTypeIndustry,
    ZoneTypeShopping,
    ZoneTypeCultural
};

@interface Zone(DataAccess)

+ (instancetype)zoneWithType:(ZoneType)type;

- (ZoneType)type;
- (NSString *)pathToGeometry;

@end
