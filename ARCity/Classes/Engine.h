//
//  Engine.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plot.h"
#import "GameSession+DataAccess.h"
#import "Zone+DataAccess.h"

#import <metaioSDK/MetaioSDKViewController.h>

@protocol EngineDelegate<NSObject>

- (void)didSelectPlot:(Plot *)plot;
- (void)didDeselectPlot:(Plot *)plot;

- (void)didChangeSatisfaction:(NSNumber *)satisfaction;
- (void)didChangePopulation:(NSNumber *)population maximum:(NSNumber *)populationMaximum;
- (void)didChangeMoney:(NSNumber *)money;

@end

@interface Engine : NSObject

@property (nonatomic) id<EngineDelegate> delegate;
@property (nonatomic) GameSession *session;

+ (instancetype)sharedEngine;

/// Main setup for game engine
- (void)setupWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK gameSession:(GameSession *)session;

/// Removes building from plot and scene
- (void)removeZoneAtPlot:(Plot *)plot;

/// Process touch and call appropriate delegate method if needed
- (void)processTouchAtPoint:(CGPoint)touchPoint;

- (BOOL)isSelectedPlot;

/// Selected plot if any, otherwise nil
- (Plot *)selectedPlot;

/// Build zone
- (void)buildZone:(ZoneType)type atPlot:(Plot *)plot completion:(void(^)(BOOL success))completion;
- (void)upgradeZoneAtPlot:(Plot *)plot completion:(void(^)(BOOL success))completion;

- (BOOL)canUpgradeZone:(Zone *)zone;

- (void)pauseGame;
- (void)unpauseGame;

#pragma mark - Access stats

- (NSNumber *)money;
- (NSNumber *)populationMaximum;

@end
