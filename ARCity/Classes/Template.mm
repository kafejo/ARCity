//
//  Template.m
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#import "Template.h"
#import "EAGLView.h"

@implementation Template


#pragma mark - UIViewController lifecycle

- (void)dealloc
{
    [super dealloc];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if( !m_metaioSDK )
    {
        NSLog(@"SDK instance is 0x0. Please check the license string");
        return;
    }
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets"];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
	
	metaio::Vector3d scale = metaio::Vector3d(11.0, 11.0, 11.0);
	metaio::Rotation rotation = metaio::Rotation(metaio::Vector3d(M_PI_2, 0.0, 0.0));

    // load content
    NSString* earthModel = [[NSBundle mainBundle] pathForResource:@"Earth" ofType:@"zip" inDirectory:@"Assets"];
    
	if(earthModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
        m_earth =  m_metaioSDK->createGeometry([earthModel UTF8String]);
        if( m_earth )
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
    // load content
    NSString* earthOcclusionModel = [[NSBundle mainBundle] pathForResource:@"Earth_Occlusion" ofType:@"zip" inDirectory:@"Assets"];
    
	if(earthOcclusionModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
        m_earthOcclusion =  m_metaioSDK->createGeometry([earthOcclusionModel UTF8String]);
        if( m_earthOcclusion )
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
	
    // load content
    NSString* earthIndicatorsModel = [[NSBundle mainBundle] pathForResource:@"EarthIndicators" ofType:@"zip" inDirectory:@"Assets"];
    
	if(earthIndicatorsModel)
	{
		// if this call was successful, m_earth will contain a pointer to the 3D model
        m_earthIndicators =  m_metaioSDK->createGeometry([earthIndicatorsModel UTF8String]);
        if( m_earthIndicators )
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

	//setup splash image (shown till metaio SDK is loaded)
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

#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask SDK if the user picked an object
	// the 'true' flag tells SDK to actually use the vertices for a hit-test, instead of just the bounding box
	 metaio::IGeometry* geometry = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( geometry && geometry != m_earthOcclusion )
	{
        if ( !m_earthOpened )
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
