//
//  GlobalConfig.m
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "GlobalConfig.h"

@implementation GlobalConfig

+ (instancetype)config {
    static GlobalConfig *config;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[GlobalConfig alloc] init];
    });
    
    return config;
}

+ (NSNumber *)priceForZone:(ZoneType)zoneType level:(ZoneLevel)level {
    if (level == ZoneLevel1) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @50000;
                break;
            case ZoneTypeIndustry:
                return @100000;
                break;
            case ZoneTypeShopping:
                return @150000;
                break;
            case ZoneTypeCultural:
                return @70000;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
            default:
                return nil;
                break;
        }
    } else if (level == ZoneLevel2) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @100000;
                break;
            case ZoneTypeIndustry:
                return @140000;
                break;
            case ZoneTypeShopping:
                return @200000;
                break;
            case ZoneTypeCultural:
                return @100000;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
            default:
                return nil;
                break;
        }

    } else if (level == ZoneLevel3) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @140000;
                break;
            case ZoneTypeIndustry:
                return @200000;
                break;
            case ZoneTypeShopping:
                return @250000;
                break;
            case ZoneTypeCultural:
                return @150000;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
            default:
                return nil;
                break;
        }
    }

    return nil;
}

+ (NSNumber *)satisfactionFactorForZone:(ZoneType)zoneType level:(ZoneLevel)level {
    if (level == ZoneLevel1) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @400;
                break;
            case ZoneTypeCultural:
                return @1200;
                break;
            case ZoneTypeCityHall:
                return @0.0;
                break;
                
            default:
                return nil;
                break;
        }
    } else if (level == ZoneLevel2) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @600;
                break;
            case ZoneTypeCultural:
                return @1500;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
                
            default:
                return nil;
                break;
        }
        
    } else if (level == ZoneLevel3) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @800;
                break;
            case ZoneTypeCultural:
                return @2000;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
            default:
                return nil;
                break;
        }
    }
    
    return nil;
}

+ (NSNumber *)populationFaktorForZone:(ZoneType)zoneType level:(ZoneLevel)level {
    if (level == ZoneLevel1) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @1000;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @0;
                break;
            case ZoneTypeCultural:
                return @0;
                break;
            case ZoneTypeCityHall:
                return @100;
                break;
                
                
            default:
                return nil;
                break;
        }
    } else if (level == ZoneLevel2) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @2000;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @0;
                break;
            case ZoneTypeCultural:
                return @0;
                break;
            case ZoneTypeCityHall:
                return @200;
                break;
                
                
            default:
                return nil;
                break;
        }
        
    } else if (level == ZoneLevel3) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @3000;
                break;
            case ZoneTypeIndustry:
                return @0;
                break;
            case ZoneTypeShopping:
                return @0;
                break;
            case ZoneTypeCultural:
                return @0;
                break;
            case ZoneTypeCityHall:
                return @300;
                break;
                
            default:
                return nil;
                break;
        }
    }
    
    return nil;
}

+ (NSNumber *)jobVacanciesFaktorForZone:(ZoneType)zoneType level:(ZoneLevel)level {
    if (level == ZoneLevel1) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @1000;
                break;
            case ZoneTypeShopping:
                return @500;
                break;
            case ZoneTypeCultural:
                return @200;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
            default:
                return nil;
                break;
        }
    } else if (level == ZoneLevel2) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @1500;
                break;
            case ZoneTypeShopping:
                return @800;
                break;
            case ZoneTypeCultural:
                return @300;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
                
            default:
                return nil;
                break;
        }
        
    } else if (level == ZoneLevel3) {
        switch (zoneType) {
            case ZoneTypeHouse:
                return @0;
                break;
            case ZoneTypeIndustry:
                return @2000;
                break;
            case ZoneTypeShopping:
                return @1000;
                break;
            case ZoneTypeCultural:
                return @500;
                break;
            case ZoneTypeCityHall:
                return @0;
                break;
                
                
            default:
                return nil;
                break;
        }
    }
    
    return nil;
}



+ (NSNumber *)startingPlayerMoney {
    return @500000;
}

+ (NSNumber *)defaultTaxValue {
    return @0.15;
}

+ (NSNumber *)defaultSatisfaction {
    return @0.0;
}

+ (UIImage *)iconForZoneType:(ZoneType)zoneType {
    
    switch (zoneType) {
        case ZoneTypeHouse:
            return [UIImage imageNamed:@"house_zone"];
            break;
            
        case ZoneTypeIndustry:
            return [UIImage imageNamed:@"industrial_zone"];
            break;
            
        case ZoneTypeShopping:
            [UIImage imageNamed:@"shopping_zone"];
            break;
            
        case ZoneTypeCultural:
            return [UIImage imageNamed:@"cultural_zone"];
            break;

        case ZoneTypeCityHall:
            return [UIImage imageNamed:@"city_hall"];
            break;
            

        default:
            break;
    }
    
    return nil;
}

+ (NSString *)pathToModelForZoneType:(ZoneType)zoneType level:(ZoneLevel)level {
    
    NSString *baseName = nil;
    
    switch (zoneType) {
        case ZoneTypeHouse:
            baseName = @"house_zone";
            break;
            
        case ZoneTypeIndustry:
            baseName = @"industrial_zone";
            break;
            
        case ZoneTypeShopping:
            baseName = @"shopping_zone";
            break;
            
        case ZoneTypeCultural:
            baseName = @"cultural_zone";
            break;
            
        case ZoneTypeCityHall:
            baseName = @"main_zone";
            break;
            
        default:
            break;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%lu", baseName, (unsigned long)level + 1] ofType:@"zip"];
    
    NSAssert(path, @"Path to model not found");
    
    return path;
}

+ (NSTimeInterval)gameSpeed {
    return 3;
}

+ (NSNumber *)defaultPopulation {
    return @1;
}

+ (NSNumberFormatter *)currencyFormatter {
    static NSNumberFormatter * currencyFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.currencySymbol = @"$";
        currencyFormatter.maximumFractionDigits = 0;
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    });
    
    return currencyFormatter;
}

+ (ZoneLevel)maximumLevel {
    return ZoneLevel3;
}

@end
