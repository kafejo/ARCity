//
//  Building.h
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Building.h"

typedef NS_ENUM(NSUInteger, BuildingType) {
    BuildingTypeHouse
};

@interface Building(DataAccess)

+ (instancetype)buildingWithType:(BuildingType)type;

- (BuildingType)type;
- (NSString *)pathToGeometry;

@end
