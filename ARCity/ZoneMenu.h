//
//  BuildingMenu.h
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zone+DataAccess.h"

@class ZoneMenu;

@protocol ZoneMenuDelegate <NSObject>

- (void)zoneMenu:(ZoneMenu *)menu didSelectZoneType:(ZoneType)zoneType;

@end

@interface ZoneMenu : UIView

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, assign) id<ZoneMenuDelegate> delegate;

@end
