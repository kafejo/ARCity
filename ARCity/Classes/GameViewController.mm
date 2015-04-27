// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "GameViewController.h"
#import "Engine.h"
#import "ZoneMenu.h"

@interface GameViewController()<EngineProtocol, ZoneMenuDelegate>
@property (strong, nonatomic) IBOutlet ZoneMenu *zoneMenuView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *zoneMenuRightConstraint;

@property (strong, nonatomic) IBOutlet UIButton *moneyButton;
@property (strong, nonatomic) IBOutlet UIButton *populationButton;
@property (strong, nonatomic) IBOutlet UIButton *satisfactionButton;

@end

@implementation GameViewController


#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (!m_pMetaioSDK) {
		NSLog(@"SDK instance is NULL. Please check the license string");
		return;
	}
    
    [self loadTrackingConfiguration];
    Engine *engine = [Engine sharedEngine];
    [engine setupWithMetaioSDK:m_pMetaioSDK gameSession:self.session];
    engine.delegate = self;
    
    self.zoneMenuView.delegate = self;
    [self toggleBuildingMenu:false animated:false];
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

#pragma mark - Building menu delegate

- (void)zoneMenu:(ZoneMenu *)menu didSelectZoneType:(ZoneType)zoneType {
    Engine *engine = [Engine sharedEngine];
    
    if ([engine isSelectedPlot]) {
        [engine buildZone:zoneType atPlot:[engine selectedPlot]];
    }
}


#pragma mark - Engine delegate

- (void)didSelectPlot:(Plot *)plot {
    NSLog(@"Did select plot at index: %lu", (unsigned long)plot.markerId);
    
    [self toggleBuildingMenu:YES];
    
}

- (void)didDeselectPlot:(Plot *)plot {
    NSLog(@"Did deselect plot at index: %lu", (unsigned long)plot.markerId);
    [self toggleBuildingMenu:NO];
}


#pragma mark - @protocol metaioSDKDelegate

- (void)onSDKReady
{
	NSLog(@"The SDK is ready");
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

- (void)toggleBuildingMenu:(BOOL)show {
    [self toggleBuildingMenu:show animated:YES];
}

- (void)toggleBuildingMenu:(BOOL)show animated:(BOOL)animated {
    
    if (show && self.zoneMenuRightConstraint.constant != 0) {
        self.zoneMenuRightConstraint.constant = 0;
        
        if (animated) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.zoneMenuView layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
        
    } else if(!show && self.zoneMenuRightConstraint.constant != -self.zoneMenuView.frame.size.width) {
        self.zoneMenuRightConstraint.constant = -self.zoneMenuView.frame.size.width;
        
        if (animated) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.zoneMenuView layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }
    
}

#pragma mark - Handling Touches


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.glkView];
    
    // get the scale factor (will be 2 for retina screens)
    const float scale = self.glkView.contentScaleFactor;
    
    
    [[Engine sharedEngine] processTouchAtPoint:CGPointMake(loc.x * scale, loc.y * scale)];
	
}

#pragma mark - Actions 

- (IBAction)showMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
