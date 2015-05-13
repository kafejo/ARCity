//
//  Zone.h
//  ARCity
//
//  Created by Aleš Kocur on 13/05/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plot;

@interface Zone : NSManagedObject

@property (nonatomic, retain) NSNumber * currentPopulation;
@property (nonatomic, retain) NSNumber * levelId;
@property (nonatomic, retain) NSNumber * typeId;
@property (nonatomic, retain) Plot *plot;

@end
