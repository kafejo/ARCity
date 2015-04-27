//
//  GlobalConfig.m
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GlobalConfig.h"

@implementation GlobalConfig

+ (instancetype)config {
    static GlobalConfig *config;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[GlobalConfig alloc] init];
    });
    
    return config;
}

+ (NSNumber *)priceForZone:(ZoneType)zoneType {
    switch (zoneType) {
        case ZoneTypeHouse:
            return @3000;
            break;
        case ZoneTypeIndustry:
            return @4000;
            break;
        case ZoneTypeShopping:
            return @5000;
            break;
        case ZoneTypeCultural:
            return @2000;
            break;
            
        default:
            return nil;
            break;
    }
}

+ (NSNumber *)startingPlayerMoney {
    return @500000;
}

@end
