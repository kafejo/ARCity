//
//  Plot+DataAccess.m
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "Plot+DataAccess.h"
#import "GameSession.h"

@implementation Plot (DataAccess)

+ (instancetype)plotWithMarkerId:(NSUInteger)markerId forSession:(GameSession *)session {
    
    Plot *plot = [Plot MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(markerId = %@) AND (gameSession = %@)", @(markerId), session]];
    
    if (!plot) {
        plot = [Plot MR_createEntity];
        plot.markerId = @(markerId);
        plot.gameSession = session;
    }
    
    return plot;
}

- (void)removeZone {
    
    if (self.plotZone) {
        self.plotZone = nil;
    }
    
}


@end
