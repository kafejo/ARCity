//
//  BuildingMenu.m
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "BuildingMenu.h"
#import "BuildingCell.h"

NSString * const kBuildingMenuItemNameKey = @"name";
NSString * const kBuildingMenuItemImageKey = @"image";
NSString * const kBuildingMenuItemEnumKey = @"building_id";

@interface BuildingMenu()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation BuildingMenu

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    
    REGISTER_CELL_FOR_TABLE(BuildingCell, self.tableView);
    
    self.items = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BuildingMenuItems" ofType:@"plist"]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

#pragma mark - UITableView delegate 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuildingCell *cell = [tableView dequeueReusableCellWithIdentifier:[BuildingCell identifier] forIndexPath:indexPath];
    cell.titleLabel.text = self.items[indexPath.row][kBuildingMenuItemNameKey];
    cell.iconView.image = [UIImage imageNamed:self.items[indexPath.row][kBuildingMenuItemImageKey]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BuildingCell preferredHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate buildingMenu:self didSelectBuildingType:(BuildingType)[self.items[indexPath.row][kBuildingMenuItemEnumKey] integerValue]];
    }
}

@end
