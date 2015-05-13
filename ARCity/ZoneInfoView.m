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
    
    if (zone.type == ZoneTypeCityHall) {
        self.upgradeButton.hidden = YES;
        self.increaseButton.hidden = NO;
        self.decreaseButton.hidden = NO;
        self.zoneNextLevelLabel.hidden = YES;
        self.zoneCurrentLevelLabel.hidden = YES;
    } else {
        self.upgradeButton.hidden = NO;
        self.increaseButton.hidden = YES;
        self.decreaseButton.hidden = YES;
        self.zoneNextLevelLabel.hidden = NO;
        self.zoneCurrentLevelLabel.hidden = NO;
    }
    
}

- (IBAction)updateTax:(id)sender {
    
    if (sender == self.increaseButton) {
        if (self.delegate) {
            [self.delegate increaseTax];
        }
    } else if (sender == self.decreaseButton) {
        if (self.delegate) {
            [self.delegate decreaseTax];
        }
    }
    
}

@end
