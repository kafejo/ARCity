//
//  Plot.h
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Building, GameSession;

@interface Plot : NSManagedObject

@property (nonatomic, retain) NSNumber * markerId;
@property (nonatomic, retain) Building *building;
@property (nonatomic, retain) GameSession *gameSession;

@end
