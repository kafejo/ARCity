//
//  GlobalConfig.h
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Zone+DataAccess.h"

@interface GlobalConfig : NSObject

//+ (instancetype)config;

+ (NSNumber *)priceForZone:(ZoneType)zoneType;



@end
