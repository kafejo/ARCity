//
//  GameSession+DataAccess.h
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GameSession.h"

@interface GameSession (DataAccess)

+ (instancetype)lastGameSession;
+ (instancetype)newSession;


@end
