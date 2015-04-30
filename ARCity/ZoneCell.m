//
//  ZoneCell.m
//  ARCity
//
//  Created by Aleš Kocur on 27/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "ZoneCell.h"
#import "GlobalConfig.h"

@implementation ZoneCell

- (void)awakeFromNib {
    // Initialization code
}

+ (CGSize)preferredSize {
    return CGSizeMake(192, 192);
}

+ (NSString *)identifier {
    return @"ZoneCellIdentifier";
}

- (void)configureWithZoneType:(ZoneType)type {
    self.zoneType = type;
    switch (type) {
        case ZoneTypeHouse:
            self.zoneImage.image = [UIImage imageNamed:@"house_zone"];
            self.zoneName.text = NSLocalizedString(@"HOUSE_ZONE", nil);

            break;
        case ZoneTypeIndustry:
            self.zoneImage.image = [UIImage imageNamed:@"industrial_zone"];
            self.zoneName.text = NSLocalizedString(@"INDUSTRIAL_ZONE", nil);
            
            break;
        case ZoneTypeShopping:
            self.zoneImage.image = [UIImage imageNamed:@"shopping_zone"];
            self.zoneName.text = NSLocalizedString(@"SHOPPING_ZONE", nil);
            
            break;
        case ZoneTypeCultural:
            self.zoneImage.image = [UIImage imageNamed:@"cultural_zone"];
            self.zoneName.text = NSLocalizedString(@"CULTURAL_ZONE", nil);
            
            break;
            
        default:
            break;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.currencySymbol = @"$";
    numberFormatter.maximumFractionDigits = 0;
    self.zonePrice.text = [numberFormatter stringFromNumber:[GlobalConfig priceForZone:type level:ZoneLevel1]];
    
}

@end
