//
//  Plot.h
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GameSession, Zone;

@interface Plot : NSManagedObject

@property (nonatomic, retain) NSNumber * markerId;
@property (nonatomic, retain) Zone *plotZone;
@property (nonatomic, retain) GameSession *gameSession;

@end
