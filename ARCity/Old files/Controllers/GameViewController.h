//
//  GameViewController.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import <metaioSDK/MetaioSDKViewController.h>
#import "Engine.h"

@interface GameViewController : MetaioSDKViewController

@property (nonatomic, assign) IBOutlet UIImageView *splashImageView;
@property (retain, nonatomic) IBOutlet UIView *menuBar;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *populationLabel;

@end
