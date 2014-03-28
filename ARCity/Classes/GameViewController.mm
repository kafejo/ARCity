//
//  GameViewController.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "GameViewController.h"
#import "EAGLView.h"

@interface GameViewController () 
@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if( !m_metaioSDK )
    {
        NSLog(@"SDK instance is 0x0. Please check the license string");
        return;
    }
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml"];
	
    if(trackingDataFile) {
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
	
	//metaio::Vector3d scale = metaio::Vector3d(11.0, 11.0, 11.0);
	//metaio::Rotation rotation = metaio::Rotation(metaio::Vector3d(M_PI_2, 0.0, 0.0));
    
    // load content
    NSString* earthModel = [[NSBundle mainBundle] pathForResource:@"test-building" ofType:@"obj" inDirectory:@"Models"];
    
	if(earthModel) {
		// if this call was successful, m_earth will contain a pointer to the 3D model
        m_house =  m_metaioSDK->createGeometry([earthModel UTF8String]);
        if(m_house) {
            // scale it a bit down
            //m_earth->setScale(scale);
			//m_earth->setRotation(rotation);
            m_house->setCoordinateSystemID(1);
            NSLog(@"Loaded");
        } else {
            NSLog(@"Error, could not load %@", earthModel);
        }
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//setup splash image (shown till metaio SDK is loaded)
- (void)loadSplashImage {
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		if ([[[UIScreen mainScreen] currentMode] size].height > 960) {
			self.splashImageView.image = [UIImage imageNamed:@"Default-568h.png"];
		} else {
			self.splashImageView.image = [UIImage imageNamed:@"Default.png"];
		}
	} else {
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
			self.splashImageView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
		} else {
			self.splashImageView.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
		}
	}
}

#pragma mark - @protocol metaioSDKDelegate

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    NSLog(@"animation ended %@", animationName);
}


- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName
{
	NSLog(@"movie ended %@", movieName);
	
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    NSLog(@"a new camera frame image is saved to %@", filepath);
}

-(void) onScreenshotImage:(metaio::ImageStruct *)image
{
    
    NSLog(@"screenshot image is received %f", image->timestamp);
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot image is received %@", [image description]);
}

-(void) onScreenshot:(NSString *)filepath
{
    NSLog(@"screenshot is saved to %@", filepath);
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    if (success)
    {
        NSLog(@"Instant 3D tracking is successful");
    }
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    if (success)
    {
        NSLog(@"Visual search is successful");
    }
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    if (state == metaio::EVSS_SERVER_COMMUNICATION)
    {
        NSLog(@"Visual search is currently communicating with the server");
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
