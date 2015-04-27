//
//  BuildingMenu.m
//  ARCity
//
//  Created by Aleš Kocur on 21/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "ZoneMenu.h"
#import "ZoneCell.h"
#import "Zone+DataAccess.h"

NSString * const kZoneMenuItemNameKey = @"name";
NSString * const kZoneMenuItemImageKey = @"image";
NSString * const kZoneMenuItemEnumKey = @"zone_id";

@interface ZoneMenu()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation ZoneMenu

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ZoneCell class]) bundle:nil] forCellWithReuseIdentifier:[ZoneCell identifier]];
    
    self.items = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZoneMenuItems" ofType:@"plist"]];
    
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZoneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ZoneCell identifier] forIndexPath:indexPath];
    
    [cell configureWithZoneType:(ZoneType)[self.items[indexPath.item][kZoneMenuItemEnumKey] integerValue]];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ZoneCell preferredSize];
}

//#pragma mark - UITableView delegate 
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BuildingCell *cell = [tableView dequeueReusableCellWithIdentifier:[BuildingCell identifier] forIndexPath:indexPath];
//    cell.titleLabel.text = self.items[indexPath.row][kBuildingMenuItemNameKey];
//    cell.iconView.image = [UIImage imageNamed:self.items[indexPath.row][kBuildingMenuItemImageKey]];
//    return cell;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.items.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [BuildingCell preferredHeight];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.0f;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.delegate) {
//        [self.delegate buildingMenu:self didSelectBuildingType:(BuildingType)[self.items[indexPath.row][kBuildingMenuItemEnumKey] integerValue]];
//    }
//}

@end
