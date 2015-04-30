//
//  ZoneInfo.m
//  ARCity
//
//  Created by Aleš Kocur on 28/04/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "ZoneInfoView.h"
#import "Zone+DataAccess.h"
#import "GlobalConfig.h"

@implementation ZoneInfoView

- (void)setupWithZone:(Zone *)zone {
    switch (zone.type) {
        case ZoneTypeHouse:
            self.zoneNameLabel.text = NSLocalizedString(@"HOUSE_ZONE", nil);
            self.zoneDescriptionLabel.text = NSLocalizedString(@"HOUSE_ZONE_DESC", nil);
            
            break;
        
        case ZoneTypeIndustry:
            self.zoneNameLabel.text = NSLocalizedString(@"INDUSTRIAL_ZONE", nil);
            self.zoneDescriptionLabel.text = NSLocalizedString(@"INDUSTRIAL_ZONE_DESC", nil);
            
            break;
        
        case ZoneTypeShopping:
            self.zoneNameLabel.text = NSLocalizedString(@"SHOPPING_ZONE", nil);
            self.zoneDescriptionLabel.text = NSLocalizedString(@"SHOPPING_ZONE_DESC", nil);
            
            break;
        
        case ZoneTypeCultural:
            self.zoneNameLabel.text = NSLocalizedString(@"CULTURAL_ZONE", nil);
            self.zoneDescriptionLabel.text = NSLocalizedString(@"CULTURAL_ZONE_DESC", nil);
            
            break;
        
        case ZoneTypeCityHall:
            self.zoneNameLabel.text = NSLocalizedString(@"CITYHALL_ZONE", nil);
            self.zoneDescriptionLabel.text = NSLocalizedString(@"CITYHALL_ZONE_DESC", nil);
            
            break;
            
            
        default:
            break;
    }
    
    self.zoneIconView.image = [GlobalConfig iconForZoneType:zone.type];
    
    self.zoneCurrentLevelLabel.text = [NSString stringWithFormat:@"Level %lu", (unsigned long)zone.level + 1];
    
    if (zone.level == [GlobalConfig maximumLevel]) {
        self.zoneNextLevelLabel.text = @"";
        self.upgradeButton.hidden = YES;
    } else {
    
        self.zoneNextLevelLabel.text = [NSString stringWithFormat:@"Level %lu for %@", (unsigned long)zone.level + 2, [[GlobalConfig currencyFormatter] stringFromNumber:[GlobalConfig priceForZone:zone.type level:zone.level + 1]]];
        self.upgradeButton.hidden = NO;
    }
    
}

@end
