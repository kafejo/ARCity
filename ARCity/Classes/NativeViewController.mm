// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NativeViewController.h"

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
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"templatesContent_crossplatform"];
	if (trackingDataFile)
	{
        const bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8([trackingDataFile UTF8String]));
		if (!success)
		{
			NSLog(@"Failed to load tracking configuration");
		}
	}
	else
	{
		NSLog(@"File not found");
	}

	metaio::Vector3d scale = metaio::Vector3d(11.f);
	metaio::Rotation rotation = metaio::Rotation(metaio::Vector3d(M_PI_2, 0.f, 0.f));

	// load content
	NSString* earthModel = [[NSBundle mainBundle] pathForResource:@"Earth" ofType:@"zip" inDirectory:@"templatesContent_crossplatform"];

	if (earthModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
		m_earth =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8([earthModel UTF8String]));
		if (m_earth)
		{
			// scale it a bit down
			m_earth->setScale(scale);
			m_earth->setRotation(rotation);
		}
		else
		{
			NSLog(@"error, could not load %@", earthModel);
		}
	}
	else
	{
		NSLog(@"File not found");
	}

	// load content
	NSString* earthOcclusionModel = [[NSBundle mainBundle] pathForResource:@"Earth_Occlusion" ofType:@"zip" inDirectory:@"templatesContent_crossplatform"];

	if (earthOcclusionModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
		m_earthOcclusion =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8([earthOcclusionModel UTF8String]));
		if (m_earthOcclusion)
		{
			// scale it a bit down
			m_earthOcclusion->setScale(scale);
			m_earthOcclusion->setRotation(rotation);
			m_earthOcclusion->setOcclusionMode(true);
		}
		else
		{
			NSLog(@"error, could not load %@", earthOcclusionModel);
		}
	}
	else
	{
		NSLog(@"File not found");
	}

	// load content
	NSString* earthIndicatorsModel = [[NSBundle mainBundle] pathForResource:@"EarthIndicators" ofType:@"zip" inDirectory:@"templatesContent_crossplatform"];

	if (earthIndicatorsModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
		m_earthIndicators =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8([earthIndicatorsModel UTF8String]));
		if (m_earthIndicators)
		{
			// scale it a bit down
			m_earthIndicators->setScale(scale);
			m_earthIndicators->setRotation(rotation);
		}
		else
		{
			NSLog(@"error, could not load %@", earthIndicatorsModel);
		}
	}
	else
	{
		NSLog(@"File not found");
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

	if (geometry && geometry != m_earthOcclusion)
	{
		if (!m_earthOpened)
		{
			m_earth->startAnimation("Open", false);
			m_earthIndicators->startAnimation("Grow", false);
			m_earthOpened = true;
		}
		else
		{
			m_earth->startAnimation("Close", false);
			m_earthIndicators->startAnimation("Shrink", false);
			m_earthOpened = false;
		}
	}
}

@end
