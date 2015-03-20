//
//  Building.h
//  ARCity
//
//  Created by Aleš Kocur on 18/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/MetaioSDKViewController.h>

typedef NS_ENUM(NSUInteger, BuildingType) {
    BuildingTypeHouse
};

@interface Building : NSObject

@property (nonatomic) metaio::IGeometry *geometry;

+ (instancetype)buildingWithType:(BuildingType)type metaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK;

- (void)setMarkerId:(NSUInteger)marker_id;

@end
