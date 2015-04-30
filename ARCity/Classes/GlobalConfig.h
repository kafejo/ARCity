//
//  GlobalConfig.h
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Zone+DataAccess.h"

@interface GlobalConfig : NSObject

//+ (instancetype)config;

+ (NSNumber *)priceForZone:(ZoneType)zoneType level:(ZoneLevel)level;

+ (NSNumber *)satisfactionFactorForZone:(ZoneType)zoneType level:(ZoneLevel)level;
+ (NSNumber *)populationFaktorForZone:(ZoneType)zoneType level:(ZoneLevel)level;
+ (NSNumber *)jobVacanciesFaktorForZone:(ZoneType)zoneType level:(ZoneLevel)level;

+ (NSNumber *)startingPlayerMoney;
+ (NSNumber *)defaultTaxValue;
+ (NSNumber *)defaultSatisfaction;

+ (UIImage *)iconForZoneType:(ZoneType)zoneType;

+ (NSString *)pathToModelForZoneType:(ZoneType)zoneType level:(ZoneLevel)level;

+ (NSTimeInterval)gameSpeed;
+ (NSNumberFormatter *)currencyFormatter;
+ (ZoneLevel)maximumLevel;
+ (NSNumber *)defaultPopulation;

@end
