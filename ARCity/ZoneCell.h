//
//  ZoneCell.h
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zone+DataAccess.h"

@interface ZoneCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *zoneImage;
@property (strong, nonatomic) IBOutlet UILabel *zoneName;
@property (strong, nonatomic) IBOutlet UILabel *zonePrice;

- (void)configureWithZoneType:(ZoneType)type;

+ (CGSize)preferredSize;
+ (NSString *)identifier;

@end
