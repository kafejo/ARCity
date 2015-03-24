//
//  GameViewController.m
//  ARCity
//
//  Created by Aleš Kocur on 28/03/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "GameViewController.h"
#import <metaioSDK/MetaioSDKViewController.h>

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
    
    
    if (!m_metaioSDK) {
        NSLog(@"SDK instance is 0x0. Please check the license string");
        return;
    }
    
    
    // load our tracking configuration
    NSString *trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml"];
	
    if (trackingDataFile) {
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:@"selection" ofType:@"zip" inDirectory:MODEL_PATH];
    metaio::IGeometry *model = nil;
    
    if (modelPath) {
        model = m_metaioSDK->createGeometry([modelPath UTF8String]);
    } else {
        NSLog(@"Cannot find model");
    }
    model->setScale(metaio::Vector3d(6, 6, 6));
    model->setRotation(metaio::Rotation(M_PI_2, 0, 0));
    model->setCoordinateSystemID(1);
    model->setTransparency(0.4f);
    model->setVisible(false);
    model->setAnimationSpeed(12.0f);
    [[Engine sharedEngine] setSelection:model];
    
    self.nameLabel.text = @"";
    self.populationLabel.text = @"";
    
    for (int i = 1;i <= 20;i++) {
    
        // First family house initialization
        Building *building1 = [Building building];
        building1.name = @"Karel's house";
        building1.modelPathName = @"family-house-tex";
        building1.population = 4;
        
        // Load building into game world
        [self loadBuilding:building1 forID:i];
    }
    
   
    
    
}

- (void)loadBuilding:(Building *)building forID:(NSInteger)markerID{
    
    // .ZIP model path, archive with geometry, textures and animations
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:building.modelPathName ofType:@"zip" inDirectory:MODEL_PATH];
    
    metaio::IGeometry *model = nil;
    
    // Test if path exist
    if (modelPath) {
        model = m_metaioSDK->createGeometry([modelPath UTF8String]);
    } else {
        NSLog(@"Cannot find model");
    }
    
    // Test if geometry was loaded
    if (model) {
        building.model = model;
        building.markerID = markerID;
        
        // Add whole building to gameboard
        [[[Engine sharedEngine] buildings] addObject:building];
    } else {
        NSLog(@"Cannot load model at path: %@", modelPath);
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask SDK if the user picked an object
	// the 'true' flag tells SDK to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* geometry = m_metaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale);
//    metaio::IGeometry* geometry = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if (geometry) {
    
    metaio::IGeometry *selection = [[Engine sharedEngine] selection];
        
        if (selection->isVisible()) {
            selection->setVisible(false);
            selection->stopAnimation();
            self.nameLabel.text = @"";
            self.populationLabel.text = @"";
        } else {
            Building *building = [[Engine sharedEngine] buildingForGeometry:geometry];
            if (building) {
                self.nameLabel.text = building.name;
                self.populationLabel.text = [NSString stringWithFormat:@"Population: %ld", (long)building.population];
            }
            
            selection->setCoordinateSystemID(geometry->getCoordinateSystemID());
            selection->setVisible(true);
            selection->startAnimation("Take 001", true);
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

- (void)dealloc {
    [_menuBar release];
    [_nameLabel release];
    [_populationLabel release];
    [super dealloc];
}
@end
