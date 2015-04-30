//
//  Zone.h
//  ARCity
//
//  Created by Aleš Kocur on 28/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plot;

@interface Zone : NSManagedObject

@property (nonatomic, retain) NSNumber * type_id;
@property (nonatomic, retain) NSNumber * currentPopulation;
@property (nonatomic, retain) NSNumber * level_id;
@property (nonatomic, retain) Plot *plot;

@end
