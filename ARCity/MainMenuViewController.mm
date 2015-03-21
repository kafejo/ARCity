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

typedef NS_ENUM(NSInteger, MainMenuItemTag) {
    MainMenuItemTagContinue,
    MainMenuItemTagNewGame
};

@interface MainMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) GameSession *session;

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.session = [GameSession lastGameSession];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(MainMenuCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    
    if (self.session && indexPath.row == 0) {
        cell.titleLabel.text =  NSLocalizedString(@"CONTINUE_GAME", @"Menu item for continuing in last played game");
        cell.tag = MainMenuItemTagContinue;
        
    } else if ((self.session && indexPath.row == 1) || (self.session == nil && indexPath.row == 0)) {
        cell.titleLabel.text =  NSLocalizedString(@"NEW_GAME", @"Menu item for creating new game");
        cell.tag = MainMenuItemTagNewGame;
    }
    

}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MainMenuCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"mainMenuCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.session ? 2 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    MainMenuCell *cell = (MainMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.tag == MainMenuItemTagNewGame) {
        self.session = [GameSession newSession];
    }
    
    [self performSegueWithIdentifier:@"showGame" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showGame"]) {
        GameViewController *controller = segue.destinationViewController;
        
        if (!self.session) {
            self.session = [GameSession newSession];
        }
        controller.session = self.session;
    }
    
}


@end
