//
//  Plot+DataAccess.h
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Plot.h"

@class GameSession;

@interface Plot (DataAccess)

/// Fetch or create plot
+ (instancetype)plotWithMarkerId:(NSUInteger)markerId forSession:(GameSession *)session;

- (void)removeBuilding;


@end
