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
    ZoneTypeCultural,
    ZoneTypeCityHall
};

typedef NS_ENUM(NSUInteger, ZoneLevel) {
    ZoneLevel1 = 0,
    ZoneLevel2,
    ZoneLevel3
};

@interface Zone(DataAccess)

+ (instancetype)zoneWithType:(ZoneType)type;

- (ZoneType)type;
- (ZoneLevel)level;
- (void)setLevel:(ZoneLevel)level;

@end
