//
//  Zone.h
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plot;

@interface Zone : NSManagedObject

@property (nonatomic, retain) NSNumber * type_id;
@property (nonatomic, retain) Plot *plot;

@end
