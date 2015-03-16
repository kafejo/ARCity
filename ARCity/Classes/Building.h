//
//  Building.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/MetaioSDKViewController.h>
//#import "MetaioSDKViewController.h"

#define MODEL_PATH @"Models"

@interface Building : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *modelPathName;
@property (assign) NSInteger population;
@property metaio::IGeometry *model;

+ (instancetype)buildingWithModel:(metaio::IGeometry *)model;
+ (instancetype)building;

- (void)setMarkerID:(NSInteger)markerID;

@end
