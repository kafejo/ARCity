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

@interface GraphicsCore : NSObject

+ (instancetype)graphicsCoreWithMetaioSDK:(metaio::IMetaioSDKIOS *)metaioSDK;

- (NSInteger)markerIdWithTouchPoint:(CGPoint)touchPoint;
- (void)selectPlotAtMarkerId:(NSInteger)markerId;
- (void)startDrawingGameSession:(GameSession *)session;
- (void)stopDrawingCurrentGameSession;

@end
