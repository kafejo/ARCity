//
//  TableViewCell.m
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "BuildingCell.h"

@implementation BuildingCell

+ (NSString *)identifier {
    return @"BuildingCellIdentifier";
}

+ (CGFloat)preferredHeight {
    return 120.0;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
