//
//  Engine.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plot.h"
#import <metaioSDK/MetaioSDKViewController.h>

#define GAMEBOARD_SIZE 20

@protocol EngineProtocol<NSObject>

- (void)didSelectPlot:(Plot *)plot;

@end

@interface Engine : NSObject

@property (nonatomic, strong) NSArray *plots;
@property metaio::IGeometry *selection;
@property (nonatomic) id<EngineProtocol> delegate;


+ (instancetype)sharedEngine;

/// Setter for metaio SDK, it provides Augmeted reality functions
- (void)setupWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK;

/// Getter for metaio SDK
- (metaio::IMetaioSDKIOS *)metaioSDK;

/// Returns Plot object for given geometry
- (Plot *)plotForGeometry:(metaio::IGeometry *)geometry;

/// Removes building from plot and scene
- (void)removeBuildingAtPlot:(Plot *)plot;

/// Process touch and call appropriate delegate method if needed
- (void)processTouchAtPoint:(CGPoint)touchPoint;

@end
