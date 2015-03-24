//
//  GameSession+DataAccess.m
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GameSession+DataAccess.h"

@implementation GameSession (DataAccess)

+ (instancetype)lastGameSession {
    NSArray *session = [GameSession MR_findAllSortedBy:@"last_played" ascending:NO];
    
    if (session && session.count != 0) {
        return [session firstObject];
    } else {
        return nil;
    }
    
}

+ (instancetype)newSession {

    GameSession *session = [GameSession MR_createEntity];
    [session.managedObjectContext MR_saveToPersistentStoreAndWait];
    return session;
}

@end
