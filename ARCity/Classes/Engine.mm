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

@interface Engine ()<GraphicsCoreDelegate>


@property (nonatomic, strong) GraphicsCore *graphicsCore;

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
}

- (Plot *)plotForMarkerId:(NSUInteger)markerId {
    
    Plot *plot = [Plot plotWithMarkerId:markerId forSession:self.session];
    return plot;
}

- (void)removeBuildingAtPlot:(Plot *)plot {
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

- (void)buildBuilding:(BuildingType)type atPlot:(Plot *)plot {
    Building *building = [Building buildingWithType:type];
    plot.building = building;
    building.plot = plot;
    
    [self.session.managedObjectContext MR_saveOnlySelfAndWait];
    
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


@end
