// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NativeViewController.h"
#import "Engine.h"

@implementation NativeViewController


#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (!m_pMetaioSDK)
	{
		NSLog(@"SDK instance is NULL. Please check the license string");
		return;
	}


	// load our tracking configuration
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker" ofType:@"xml"];
    
	if (trackingDataFile) {
        const bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8([trackingDataFile UTF8String]));
        
		if (!success) {
			NSLog(@"Failed to load tracking configuration");
		}
	} else {
		NSLog(@"File not found");
	}

    
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:@"selection" ofType:@"zip"];
    metaio::IGeometry *model = nil;
    
    if (modelPath) {
        model = m_pMetaioSDK->createGeometry([modelPath UTF8String]);
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
    
//    self.nameLabel.text = @"";
//    self.populationLabel.text = @"";
    
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


#pragma mark - @protocol metaioSDKDelegate


- (void)onSDKReady
{
	NSLog(@"The SDK is ready");
}


- (void)onAnimationEnd:(metaio::IGeometry*) geometry  andName:(const NSString*) animationName
{
	 NSLog(@"animation ended: %@", animationName);
}


- (void)onMovieEnd:(metaio::IGeometry*)geometry andMoviePath:(const NSString*) moviePath
{
	NSLog(@"movie ended: %@", moviePath);
}


- (void)onNewCameraFrame:(metaio::ImageStruct*) cameraFrame
{
	NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}


- (void)onCameraImageSaved:(const NSString*) filepath
{
	NSLog(@"a new camera frame image is saved to %@", filepath);
}

- (void) onRenderEvent:(const metaio::RenderEvent&) renderEvent
{
}

- (void)onScreenshotImage:(metaio::ImageStruct*) image
{
	NSLog(@"screenshot image is received %f", image->timestamp);
}


- (void)onScreenshotImageIOS:(UIImage*)image
{
	NSLog(@"screenshot image is received %@", [image description]);
}


- (void)onScreenshotSaved:(const NSString*) filepath
{
	NSLog(@"screenshot is saved to %@", filepath);
}


- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&) trackingValues
{
	NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}


- (void)onInstantTrackingEvent:(bool)success file:(const NSString*) filepath
{
	if (success)
	{
		NSLog(@"Instant tracking is successful");
	}
	else
	{
		NSLog(@"Instant tracking failed, try again");
	}
}


- (void)onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(const metaio::stlcompat::Vector<metaio::VisualSearchResponse>&) response
{
	if (success)
	{
		NSLog(@"Visual search is successful");
	}
}


- (void)onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
	if (state == metaio::EVSS_SERVER_COMMUNICATION)
	{
		NSLog(@"Visual search is currently communicating with the server");
	}
}

- (void)loadBuilding:(Building *)building forID:(NSInteger)markerID{
    
    // .ZIP model path, archive with geometry, textures and animations
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:building.modelPathName ofType:@"zip"];
    
    metaio::IGeometry *model = nil;
    
    // Test if path exist
    if (modelPath) {
        model = m_pMetaioSDK->createGeometry([modelPath UTF8String]);
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



#pragma mark - Handling Touches


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self.glkView];

	// get the scale factor (will be 2 for retina screens)
	const float scale = self.glkView.contentScaleFactor;

	// ask SDK if the user picked an object
	// the 'true' flag tells SDK to actually use the vertices for a hit-test, instead of just the bounding box
	 metaio::IGeometry* geometry = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, true);

    if (geometry) {
        
        metaio::IGeometry *selection = [[Engine sharedEngine] selection];
        
        if (selection->isVisible()) {
            selection->setVisible(false);
            selection->stopAnimation();
//            self.nameLabel.text = @"";
//            self.populationLabel.text = @"";
        } else {
            Building *building = [[Engine sharedEngine] buildingForGeometry:geometry];
            if (building) {
//                self.nameLabel.text = building.name;
//                self.populationLabel.text = [NSString stringWithFormat:@"Population: %ld", (long)building.population];
            }
            
            selection->setCoordinateSystemID(geometry->getCoordinateSystemID());
            selection->setVisible(true);
            selection->startAnimation("Take 001", true);
        }
    }

}

@end
