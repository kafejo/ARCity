//
//  GameSession.h
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plot;

@interface GameSession : NSManagedObject

@property (nonatomic, retain) NSDate * last_played;
@property (nonatomic, retain) NSSet *plots;
@end

@interface GameSession (CoreDataGeneratedAccessors)

- (void)addPlotsObject:(Plot *)value;
- (void)removePlotsObject:(Plot *)value;
- (void)addPlots:(NSSet *)values;
- (void)removePlots:(NSSet *)values;

@end
