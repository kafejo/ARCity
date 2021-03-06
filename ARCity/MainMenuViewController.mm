//
//  MainMenuViewController.m
//  ARCity
//
//  Created by Aleš Kocur on 20/03/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenuCell.h"
#import "GameSession+DataAccess.h"
#import "GameViewController.h"
#import <TFTableDescriptor.h>


static NSString * const kRowTagContinue = @"RowTagContinue";
static NSString * const kRowTagNewGame = @"RowTagNewGame";
static NSString * const kRowTagAbout = @"RowTagAbout";

@interface MainMenuViewController ()<TFTableDescriptorDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) GameSession *session;

@property (nonatomic, strong) TFTableDescriptor *tableDescriptor;

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.session = [GameSession lastGameSession];
    REGISTER_CELL_FOR_TABLE(MainMenuCell, self.tableView);
    
    TFTableDescriptor *table = [TFTableDescriptor descriptorWithTable:self.tableView];
    TFSectionDescriptor *section = [TFSectionDescriptor descriptorWithData:nil];
    
    
    if (self.session) {
        [section addRow:[TFRowDescriptor descriptorWithRowClass:[MainMenuCell class] data:NSLocalizedString(@"CONTINUE_GAME", @"Menu item for continuing in last played game") tag:kRowTagContinue]];
    }
    
    [section addRow:[TFRowDescriptor descriptorWithRowClass:[MainMenuCell class] data:NSLocalizedString(@"NEW_GAME", @"Menu item for creating new game") tag:kRowTagNewGame]];
    
    [section addRow:[TFRowDescriptor descriptorWithRowClass:[MainMenuCell class] data:NSLocalizedString(@"ABOUT", @"Menu item for showing about") tag:kRowTagAbout]];

    [table addSection:section];
    self.tableDescriptor = table;
    self.tableDescriptor.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([GameSession lastGameSession] && !self.session && [self.tableDescriptor rowForTag:kRowTagContinue] == nil) {
        self.session = [GameSession lastGameSession];
        [self.tableDescriptor insertRow:[TFRowDescriptor descriptorWithRowClass:[MainMenuCell class] data:NSLocalizedString(@"CONTINUE_GAME", @"Menu item for continuing in last played game") tag:kRowTagContinue] inFrontOfRow:[self.tableDescriptor rowForTag:kRowTagNewGame]];
    }
    
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
// 
//}

#pragma mark - TFTableDescritor delegate

- (void)tableDescriptor:(TFTableDescriptor *)descriptor didSelectRow:(TFRowDescriptor *)rowDescriptor {
    
    if ([rowDescriptor.tag isEqualToString:kRowTagNewGame]) {
        self.session = [GameSession newSession];
        [self pushToGameController];
    } else if ([rowDescriptor.tag isEqualToString:kRowTagAbout]) {
        [self performSegueWithIdentifier:@"about" sender:self];
    } else if ([rowDescriptor.tag isEqualToString:kRowTagContinue]) {
        [self pushToGameController];
    }
    

}

#pragma mark - Navigation

- (void)pushToGameController {
    
    GameViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GameViewControllerID"];
    
    if (!self.session) {
        self.session = [GameSession newSession];
    }
    controller.session = self.session;
    
    [self.navigationController pushViewController:controller animated:NO];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
