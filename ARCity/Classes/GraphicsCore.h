//
//  GraphicsCore.h
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/MetaioSDKViewController.h>

#define GAMEBOARD_SIZE 20

@class GameSession;

@protocol GraphicsCoreDelegate <NSObject>

- (void)didDeselectMarker:(NSNumber *)markerId;
- (void)didSelectMarker:(NSNumber *)markerId;

@end

@interface GraphicsCore : NSObject

@property (nonatomic, weak) id<GraphicsCoreDelegate> delegate;

+ (instancetype)graphicsCoreWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK;

- (NSNumber *)markerIdWithTouchPoint:(CGPoint)touchPoint;
- (void)selectMarkerId:(NSInteger)markerId;
- (void)startDrawingGameSession:(GameSession *)session;
- (void)stopDrawingCurrentGameSession;
- (BOOL)isSelectedMarker;
- (NSNumber *)selectedMarkerId;
- (NSNumber *)deselectSelectedMarker;

@end
