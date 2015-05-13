// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "GameViewController.h"
#import "Engine.h"
#import "ZoneMenu.h"
#import "Plot+DataAccess.h"
#import "ZoneInfoView.h"
#import "LoadingView.h"
#import "GlobalConfig.h"

@interface GameViewController()<EngineDelegate, ZoneMenuDelegate, ZoneInfoDelegate>
@property (strong, nonatomic) IBOutlet ZoneMenu *zoneMenuView;

@property (strong, nonatomic) IBOutlet UIButton *moneyButton;
@property (strong, nonatomic) IBOutlet UIButton *populationButton;
@property (strong, nonatomic) IBOutlet UIButton *satisfactionButton;
@property (strong, nonatomic) IBOutlet UIButton *jobButton;
@property (strong, nonatomic) IBOutlet UIButton *taxButton;


@property (strong, nonatomic) IBOutlet ZoneInfoView *zoneInfoView;
@property (strong, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) Engine *engine;

@end

@implementation GameViewController


#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.loadingView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LoadingView class]) owner:nil options:nil] firstObject];
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    self.loadingView.frame = [UIScreen mainScreen].bounds;
    
    self.zoneInfoView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!m_pMetaioSDK) {
        NSLog(@"SDK instance is NULL. Please check the license string");
        return;
    }
    
    [self loadTrackingConfiguration];
    self.engine = [[Engine alloc] init];
    [self.engine setupWithMetaioSDK:m_pMetaioSDK gameSession:self.session];
    self.engine.delegate = self;
    
    self.zoneMenuView.delegate = self;
    self.zoneMenuView.hidden = YES;
    self.zoneInfoView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.loadingView show];
    
    [self didChangeMoney:self.engine.money];
    [self didChangeTax:self.engine.tax];
    [self didChangeJobVacancies:@(self.engine.jobVacancies)];
    
}


- (void)loadTrackingConfiguration {
    // load tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml"];
    
    if (trackingDataFile) {
        const bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8([trackingDataFile UTF8String]));
        
        if (!success) {
            NSLog(@"Failed to load tracking configuration");
        }
    } else {
        NSLog(@"File not found");
    }

}

- (void)dealloc {
    NSLog(@"DEALOc!");
    [self.engine stop];
    
    std::vector<metaio::IGeometry *> geometries = m_pMetaioSDK->getLoadedGeometries();
    
    for (auto it = geometries.begin(); it != geometries.end(); ++it ) {
        m_pMetaioSDK->unloadGeometry(*it);
    }
    
}

#pragma mark - Zone menu delegate

- (void)zoneMenu:(ZoneMenu *)menu didSelectZoneType:(ZoneType)zoneType {
    
    
    if ([self.engine isSelectedPlot]) {
        [self.engine buildZone:zoneType atPlot:[self.engine selectedPlot] completion:^(BOOL success) {
            
            if (success) {
                NSLog(@"Built!");
                [self showMenuByPlot:[self.engine selectedPlot]];
            } else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NOT_ENOUGH_MONEY", nil) message:NSLocalizedString(@"NOT_ENOUGH_MONEY_FOR_ZONE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show];
            }
        }];
    }
}


#pragma mark - Engine delegate

- (void)didSelectPlot:(Plot *)plot {
    NSLog(@"Did select plot at index: %lu", (unsigned long)plot.markerId.integerValue);
    [self showMenuByPlot:plot];
    
}

- (void)showMenuByPlot:(Plot *)plot {
    
    if ([plot hasZone]) {
        
        [self.zoneInfoView setupWithZone:plot.plotZone];
        self.zoneInfoView.hidden = NO;
        self.zoneMenuView.hidden = YES;
    } else {
        self.zoneMenuView.hidden = NO;
        self.zoneInfoView.hidden = YES;
    }
}

- (void)didDeselectPlot:(Plot *)plot {
    NSLog(@"Did deselect plot at index: %lu", (unsigned long)plot.markerId.integerValue);
    self.zoneMenuView.hidden = YES;
    self.zoneInfoView.hidden = YES;
}

- (void)didChangeMoney:(NSNumber *)money {
    [self.moneyButton setTitle:[[GlobalConfig currencyFormatter] stringFromNumber:money] forState:UIControlStateNormal];
}

- (void)didChangeSatisfaction:(NSNumber *)satisfaction {
    [self.satisfactionButton setTitle:[NSString stringWithFormat:@"%0.0f%%", satisfaction.floatValue * 100.0] forState:UIControlStateNormal];
}

- (void)didChangePopulation:(NSNumber *)population maximum:(NSNumber *)populationMaximum {
    [self.populationButton setTitle:[NSString stringWithFormat:@"%@/%@", population, populationMaximum] forState:UIControlStateNormal];

}

- (void)didChangeJobVacancies:(NSNumber *)jobVacancies {
    [self.jobButton setTitle:jobVacancies.stringValue forState:UIControlStateNormal];
}

- (void)didChangeTax:(NSNumber *)tax {
    [self.taxButton setTitle:[NSString stringWithFormat:@"%0.0f%%", tax.floatValue * 100.0] forState:UIControlStateNormal];
}

#pragma mark - @protocol metaioSDKDelegate

- (void)onSDKReady
{
	NSLog(@"The SDK is ready");
    [self.loadingView hide];
}


- (void)onAnimationEnd:(metaio::IGeometry*)geometry  andName:(const NSString*) animationName
{
//	 NSLog(@"animation ended: %@", animationName);
}


- (void)onMovieEnd:(metaio::IGeometry*)geometry andMoviePath:(const NSString*) moviePath
{
//	NSLog(@"movie ended: %@", moviePath);
}


- (void)onNewCameraFrame:(metaio::ImageStruct*) cameraFrame
{
//	NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}


- (void)onCameraImageSaved:(const NSString*) filepath
{
//	NSLog(@"a new camera frame image is saved to %@", filepath);
}

- (void) onRenderEvent:(const metaio::RenderEvent&) renderEvent
{
}

- (void)onScreenshotImage:(metaio::ImageStruct*) image
{
//	NSLog(@"screenshot image is received %f", image->timestamp);
}


- (void)onScreenshotImageIOS:(UIImage*)image {
//	NSLog(@"screenshot image is received %@", [image description]);
}


- (void)onScreenshotSaved:(const NSString*) filepath {
//	NSLog(@"screenshot is saved to %@", filepath);
}


- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&) trackingValues {
    
	//NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}


- (void)onInstantTrackingEvent:(bool)success file:(const NSString*) filepath {
	if (success)
	{
//		NSLog(@"Instant tracking is successful");
	}
	else
	{
//		NSLog(@"Instant tracking failed, try again");
	}
}


- (void)onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(const metaio::stlcompat::Vector<metaio::VisualSearchResponse>&) response
{
	if (success)
	{
//		NSLog(@"Visual search is successful");
	}
}


- (void)onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
	if (state == metaio::EVSS_SERVER_COMMUNICATION)
	{
//		NSLog(@"Visual search is currently communicating with the server");
	}
}

#pragma mark - Subview manipulations

//- (void)toggleBuildingMenu:(BOOL)show {
//    [self toggleBuildingMenu:show animated:YES];
//}
//
//- (void)toggleBuildingMenu:(BOOL)show animated:(BOOL)animated {
//    
//    if (show && self.zoneMenuBottomConstraint.constant != 0) {
//        self.zoneMenuBottomConstraint.constant = 0;
//        
//        if (animated) {
//            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                [self.zoneMenuView layoutIfNeeded];
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//        
//    } else if(!show && self.zoneMenuBottomConstraint.constant != -self.zoneMenuView.frame.size.height) {
//        self.zoneMenuBottomConstraint.constant = -self.zoneMenuView.frame.size.height;
//        
//        if (animated) {
//            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                [self.zoneMenuView layoutIfNeeded];
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//        
//    }
//    
//}
//
#pragma mark - Handling Touches


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.glkView];
    
    // get the scale factor (will be 2 for retina screens)
    const float scale = self.glkView.contentScaleFactor;
    
    
    [self.engine processTouchAtPoint:CGPointMake(loc.x * scale, loc.y * scale)];
	
}

#pragma mark - Actions 

- (IBAction)showMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)upgradeSelectedZone:(id)sender {
    
    if ([self.engine isSelectedPlot]) {
        Plot *selectedPlot = [self.engine selectedPlot];
        
        [self.engine upgradeZoneAtPlot:selectedPlot completion:^(BOOL success) {
            if (success) {
                [self.zoneInfoView setupWithZone:selectedPlot.plotZone];
            }
        }];
        
    }
    
}

- (void)increaseTax {
    [self.engine increaseTax:0.01];
}

- (void)decreaseTax {
    [self.engine decreaseTax:0.01];
}


@end
