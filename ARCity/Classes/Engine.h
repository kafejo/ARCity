//
//  Engine.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Building.h"
#import <metaioSDK/MetaioSDKViewController.h>

@interface Engine : NSObject

@property (nonatomic, strong) NSMutableArray *buildings;
@property metaio::IGeometry *selection;

+ (instancetype)sharedEngine;

- (Building *)buildingForGeometry:(metaio::IGeometry *)geometry;

@end
