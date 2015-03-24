//
//  BuildingMenu.h
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Building+DataAccess.h"

@class BuildingMenu;

@protocol BuildingMenuDelegate <NSObject>

- (void)buildingMenu:(BuildingMenu *)menu didSelectBuildingType:(BuildingType)buildingType;

@end

@interface BuildingMenu : UIView

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic) id<BuildingMenuDelegate> delegate;

@end
