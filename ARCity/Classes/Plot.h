//
//  Building.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/MetaioSDKViewController.h>
#import "Building.h"

FOUNDATION_EXPORT NSUInteger const kPlotMarkerIdNone;

@interface Plot : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *modelPathName;
@property (assign) NSInteger population;
@property (nonatomic) metaio::IGeometry *geometry;
@property (nonatomic, strong) Building *building;

+ (instancetype)plotWithMarkerId:(NSUInteger)marker_id;
+ (instancetype)plot;

- (void)setMarkerId:(NSUInteger)markerId;
- (NSUInteger)markerId;

- (void)removeBuilding;

@end
