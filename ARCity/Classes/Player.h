//
//  Player.h
//  ARCity
//
//  Created by Aleš Kocur on 13/05/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GameSession;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * money;
@property (nonatomic, retain) NSNumber * population;
@property (nonatomic, retain) NSNumber * satisfaction;
@property (nonatomic, retain) NSNumber * tax;
@property (nonatomic, retain) GameSession *session;

@end
