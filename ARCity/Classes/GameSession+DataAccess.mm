//
//  GameSession+DataAccess.m
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GameSession+DataAccess.h"
#import "Player.h"
#import "GlobalConfig.h"

@implementation GameSession (DataAccess)

+ (instancetype)lastGameSession {
    NSArray *session = [GameSession MR_findAllSortedBy:@"lastPlayed" ascending:NO];
    
    if (session && session.count != 0) {
        return [session firstObject];
    } else {
        return nil;
    }
    
}

+ (instancetype)newSession {

    GameSession *session = [GameSession MR_createEntity];
    session.player = [Player MR_createEntity];
    session.player.money = [GlobalConfig startingPlayerMoney];
    session.player.tax = [GlobalConfig defaultTaxValue];
    session.player.satisfaction = [GlobalConfig defaultSatisfaction];
    session.player.population = [GlobalConfig defaultPopulation];
    
    [session.managedObjectContext MR_saveToPersistentStoreAndWait];
    return session;
}

@end
