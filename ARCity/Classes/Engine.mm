//
//  Engine.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Engine.h"
#import "Plot+DataAccess.h"
#import "GraphicsCore.h"
#import "Player.h"
#import "GlobalConfig.h"

@interface Engine ()<GraphicsCoreDelegate>


@property (nonatomic, strong) GraphicsCore *graphicsCore;
@property (nonatomic, strong) NSTimer *gameClock;

@end

@implementation Engine

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

+ (instancetype)sharedEngine {
    static Engine * sharedEngine;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[Engine alloc] init];
    });
    
    return sharedEngine;
}

- (NSTimer *)gameClock {
    if (!_gameClock) {
        _gameClock = [NSTimer scheduledTimerWithTimeInterval:[GlobalConfig gameSpeed] target:self selector:@selector(gameTick) userInfo:nil repeats:YES];
    }
    return _gameClock;
}

- (void)setupWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK gameSession:(GameSession *)session{
    
    self.session = session;
    
    // If it's new game, add plots according to gameboard size
    if (self.session.plots.count == 0) {
        for (int i = 1; i <= GAMEBOARD_SIZE ; i++) {
            [self.session addPlotsObject:[Plot plotWithMarkerId:i forSession:self.session]];
        }
        
    }
    
    self.session.last_played = [NSDate new];
    [self.session.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    // Init graphics core
    self.graphicsCore = [GraphicsCore graphicsCoreWithMetaioSDK:metaioSDK];
    self.graphicsCore.delegate = self;
    
    // Start drawing session
    [self.graphicsCore startDrawingGameSession:self.session];
    
    [[self gameClock] fire];
}

- (Plot *)plotForMarkerId:(NSUInteger)markerId {
    
    Plot *plot = [Plot plotWithMarkerId:markerId forSession:self.session];
    return plot;
}

- (void)removeZoneAtPlot:(Plot *)plot {
//    if (plot.building) {
//        self.metaioSDK->unloadGeometry(plot.building.geometry);
//    }
}

- (void)processTouchAtPoint:(CGPoint)touchPoint {
    
    NSNumber *markerId = [self.graphicsCore markerIdWithTouchPoint:touchPoint];
    
    if (markerId) {
        
        [self.graphicsCore selectMarkerId:markerId.integerValue];
        
    } else {
        
        [self.graphicsCore deselectSelectedMarker];
        
    }
}

- (BOOL)isSelectedPlot {
    return [self.graphicsCore isSelectedMarker];
}

- (Plot *)selectedPlot {
    NSNumber *markerId = [self.graphicsCore selectedMarkerId];
    if (markerId) {
        return [self plotForMarkerId:markerId.integerValue];
    } else {
        return nil;
    }
}

- (void)buildZone:(ZoneType)type atPlot:(Plot *)plot completion:(void(^)(BOOL success))completion {
    
    NSNumber *zonePrice = [GlobalConfig priceForZone:type level:ZoneLevel1];
    
    if ([self canSubctactMoney:zonePrice]) {
        Zone *zone = [Zone zoneWithType:type];
        plot.plotZone = zone;
        zone.plot = plot;
        
        if ([self subtractMoneyIfPossible:zonePrice]) {
            completion(YES);
            if (self.delegate && type == ZoneTypeHouse) {
                [self.delegate didChangePopulation:self.session.player.population maximum:[self populationMaximum]];
            }
        } else {
            NSLog(@"Error! Cannot subtract money");
            plot.plotZone = nil;
            zone.plot = nil;
            [zone MR_deleteEntity];
            completion(NO);
        }
        
        [self.session.managedObjectContext MR_saveOnlySelfAndWait];
    } else {
        completion(NO);
    }
}

- (BOOL)canUpgradeZone:(Zone *)zone {
    return zone.level != [GlobalConfig maximumLevel];
}

- (void)upgradeZoneAtPlot:(Plot *)plot completion:(void(^)(BOOL success))completion {
    
//    NSAssert(plot.plotZone != nil, @"Plot have to have plotZone for upgrade!");
    
    if (![self canUpgradeZone:plot.plotZone]) {
        return ;
    }
    
    NSNumber *zoneUpgradePrice = [GlobalConfig priceForZone:plot.plotZone.type level:(ZoneLevel)(plot.plotZone.level+1)];
    
    if ([self canSubctactMoney:zoneUpgradePrice]) {
        plot.plotZone.level = (ZoneLevel)(plot.plotZone.level + 1);
        
        if ([self subtractMoneyIfPossible:zoneUpgradePrice]) {
            completion(YES);
            
            if (self.delegate) {
                [self.delegate didChangeMoney:[self money]];
            }
            
            if (plot.plotZone.type == ZoneTypeHouse) {
                if (self.delegate) {
                    [self.delegate didChangePopulation:self.session.player.population maximum:[self populationMaximum]];
                }
            }
            
            
        } else {
            plot.plotZone.level = (ZoneLevel)(plot.plotZone.level - 1);
            completion(NO);
        }
        
        [self.session.managedObjectContext MR_saveOnlySelfAndWait];
        
    } else {
        completion(NO);
    }
    
}

#pragma mark - Statistics

- (void)calculateSatisfaction {
    
    CGFloat calculatedSatisfaction = [self newSatisfaction];
    CGFloat difference = - (self.session.player.satisfaction.floatValue - calculatedSatisfaction);
    
    NSLog(@"Satisfaction current %0.2f calculated:%0.2f diff: (%0.2f)", self.session.player.satisfaction.floatValue, calculatedSatisfaction, difference);
    self.session.player.satisfaction = @(self.session.player.satisfaction.floatValue + (difference * 0.4));
    
    if (self.delegate) {
        [self.delegate didChangeSatisfaction:self.session.player.satisfaction];
    }
}

- (NSSet *)zonesForZoneTypes:(NSSet *)zoneTypes {
    return [[self.session.plots filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(plotZone != nil) AND (plotZone.type_id IN %@)", zoneTypes]] valueForKey:@"plotZone"];
}

- (CGFloat)satisfaction {
    return [self.session.player.satisfaction floatValue];
}

- (CGFloat)newSatisfaction {
    
    CGFloat population = self.session.player.population.integerValue;
    
    NSSet *jobZones = [self zonesForZoneTypes:[NSSet setWithObjects:@(ZoneTypeIndustry), @(ZoneTypeShopping), nil]];
    
    NSUInteger jobVacancies = 0;
    
    for (Zone *zone in jobZones) {
        jobVacancies += [[GlobalConfig jobVacanciesFaktorForZone:zone.type level:zone.level] integerValue];
    }
    
    CGFloat diff = 1.0;

    if (population > jobVacancies) {
        diff = MAX(0, (2.0 - (population / jobVacancies)));
    }

    NSSet *satisfyingZones = [self zonesForZoneTypes:[NSSet setWithObjects:@(ZoneTypeCultural), @(ZoneTypeShopping), nil]];
    
    NSUInteger satisfactionLevel = 0;
    
    for (Zone *zone in satisfyingZones) {
        satisfactionLevel += [[GlobalConfig satisfactionFactorForZone:zone.type level:zone.level] integerValue];
    }
    
    CGFloat commonSatisfaction = 1.0;
    
    if (population > satisfactionLevel) {
       commonSatisfaction = MAX(0, (2.0 - (population / satisfactionLevel)));
    }
    

    return (diff + commonSatisfaction) / 2;
    
}

- (void)calculatePopulation {
    
    NSUInteger maximumPopulation = [[self populationMaximum] integerValue];
    
    NSUInteger expectedPopulation = maximumPopulation * [self satisfaction];
    
    NSUInteger currentPopulation = [self.session.player.population unsignedIntegerValue];
    
    NSInteger populationDiff = expectedPopulation - currentPopulation;
    
    self.session.player.population = @(currentPopulation + (populationDiff * 0.3));
    
    if (self.delegate) {
        [self.delegate didChangePopulation:self.session.player.population maximum:[self populationMaximum]];
    }
    
}

- (NSNumber *)populationMaximum {
    
    NSSet *houseZones = [[self.session.plots filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(plotZone != nil) AND (plotZone.type_id IN %@)", @[@(ZoneTypeHouse), @(ZoneTypeCityHall)]]] valueForKey:@"plotZone"];
    NSUInteger count = 0;
    for (Zone *zone in houseZones) {
        count += [GlobalConfig populationFaktorForZone:zone.type level:zone.level].integerValue;
    }
    
    return @(count);
    
}

#pragma mark - Player helpers


- (BOOL)canSubctactMoney:(NSNumber *)money {
    return self.session.player.money.integerValue >= money.integerValue;
}

- (BOOL)subtractMoneyIfPossible:(NSNumber *)money {
    if ([self canSubctactMoney:money]) {
        
        self.session.player.money = @(self.session.player.money.integerValue - money.integerValue);
        if (self.delegate) {
            [self.delegate didChangeMoney:self.session.player.money];
        }
        return YES;
    }
    
    return NO;
}

- (NSNumber *)money {
    return self.session.player.money;
}

#pragma mark - Graphics core delegate

- (void)didDeselectMarker:(NSNumber *)markerId {
    if (self.delegate) {
        [self.delegate didDeselectPlot:[self plotForMarkerId:markerId.integerValue]];
    }
}

- (void)didSelectMarker:(NSNumber *)markerId {
    if (self.delegate) {
        [self.delegate didSelectPlot:[self plotForMarkerId:markerId.integerValue]];
    }
}

#pragma mark - Game run loop

- (void)gameTick {
    [self calculateSatisfaction];
    [self calculatePopulation];
}

- (void)pauseGame {
    [self.gameClock invalidate];
    self.gameClock = nil;
}

- (void)unpauseGame {
    [self.gameClock fire];
}

@end
