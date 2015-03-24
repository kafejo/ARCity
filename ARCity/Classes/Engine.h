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
#import "GameSession+DataAccess.h"
#import "Building+DataAccess.h"

@protocol EngineProtocol<NSObject>

- (void)didSelectPlot:(Plot *)plot;
- (void)didDeselectPlot:(Plot *)plot;

@end

@interface Engine : NSObject

@property (nonatomic) id<EngineProtocol> delegate;
@property (nonatomic) GameSession *session;

+ (instancetype)sharedEngine;

/// Main setup for game engine
- (void)setupWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK gameSession:(GameSession *)session;

/// Removes building from plot and scene
- (void)removeBuildingAtPlot:(Plot *)plot;

/// Process touch and call appropriate delegate method if needed
- (void)processTouchAtPoint:(CGPoint)touchPoint;

- (BOOL)isSelectedPlot;

/// Selected plot if any, otherwise nil
- (Plot *)selectedPlot;

/// Build house
- (void)buildBuilding:(BuildingType)type atPlot:(Plot *)plot;

@end
