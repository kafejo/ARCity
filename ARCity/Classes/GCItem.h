//
//  GraphicsPlotItem.h
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/MetaioSDKViewController.h>
#import "Zone+DataAccess.h"

@interface GCItem : NSObject

@property (nonatomic) metaio::IGeometry *placeholder;
@property (nonatomic) metaio::IGeometry *object;
@property (nonatomic) ZoneType type;

+ (instancetype)item;

@end
