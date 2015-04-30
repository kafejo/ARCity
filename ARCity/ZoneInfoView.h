//
//  ZoneInfo.h
//  ARCity
//
//  Created by Aleš Kocur on 28/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Zone;

@interface ZoneInfoView : UIView

@property (strong, nonatomic) IBOutlet UILabel *zoneNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *zoneDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *zoneCurrentLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *zoneNextLevelLabel;
@property (strong, nonatomic) IBOutlet UIButton *upgradeButton;
@property (strong, nonatomic) IBOutlet UIImageView *zoneIconView;

- (void)setupWithZone:(Zone *)zone;

@end
