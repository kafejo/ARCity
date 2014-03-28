//
//  GameViewController.h
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface GameViewController : MetaioSDKViewController {
    metaio::IGeometry *m_house;
}

@property (nonatomic, assign) IBOutlet UIImageView *splashImageView;

@end
