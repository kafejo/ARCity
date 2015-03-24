//
//  TableViewCell.h
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

+ (NSString *)identifier;
+ (CGFloat)preferredHeight;

@end
