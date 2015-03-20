// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NativeViewController.h"
#import "Engine.h"

@interface NativeViewController()<EngineProtocol>

@end

@implementation NativeViewController


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
    [engine setupWithMetaioSDK:m_pMetaioSDK];
    engine.delegate = self;
    
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

#pragma mark - Engine delegate

- (void)didSelectPlot:(Plot *)plot {
    NSLog(@"Did select plot at index: %lu", (unsigned long)plot.markerId);
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

- (void)loadBuilding:(Building *)building forID:(NSInteger)markerID{
    
    // .ZIP model path, archive with geometry, textures and animations
   
    
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

@end
