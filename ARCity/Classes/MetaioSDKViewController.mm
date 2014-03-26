//
//  MetaioSDKViewController.m
//  metaioSDK
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <metaioSDK/IGeometry.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"



@interface MetaioSDKViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end



@implementation MetaioSDKViewController
@synthesize glView;
@synthesize animating, context, displayLink;


#pragma mark - UIViewController lifecycle

- (void)dealloc
{
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    // delete SDK instance
    if( m_metaioSDK )
    {
        delete m_metaioSDK;
        m_metaioSDK = NULL;
    }

    // delete our sensors component
    if( m_sensors )
    {
        delete m_sensors;
        m_sensors = NULL;
    }
    
    
    [context release];
    
    [glView release];
    [super dealloc];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    if( !context )
    {
        EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!aContext)
            NSLog(@"Failed to create ES context");
        else if (![EAGLContext setCurrentContext:aContext])
            NSLog(@"Failed to set ES context current");
        
        self.context = aContext;
        [aContext release];
    }
    
    
    // set the openGL context
    [glView setContext:context];
    [glView setFramebuffer];
    animating = FALSE;
    self.displayLink = nil;
    
    // limit OpenGL framerate to 30FPS, as the camera has a maximum of 30FPS anyway
    animationFrameInterval = 2;

	// Listen to app pause/resume events because in those events we have to pause/resume the SDK
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onApplicationWillResignActive:)
	 name:UIApplicationWillResignActiveNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onApplicationDidBecomeActive:)
	 name:UIApplicationDidBecomeActiveNotification
	 object:nil];
    
    // get the license string from the plist file
    NSString* SDKLicense = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MetaioLicenseString"];
    // create SDK instance
    m_metaioSDK = metaio::CreateMetaioSDKIOS([SDKLicense UTF8String]);
    if( !m_metaioSDK )
    {
        NSLog(@"SDK instance could not be created. Please verify the signature string");
        return;
    }
    
    m_sensors = metaio::CreateSensorsComponent();
    m_metaioSDK->registerSensorsComponent( m_sensors );

    // Create our SDK instance
    float scaleFactor = [UIScreen mainScreen].scale;
    metaio::Vector2d screenSize;
    screenSize.x = self.glView.bounds.size.width * scaleFactor;
    screenSize.y = self.glView.bounds.size.height * scaleFactor;

	m_metaioSDK->initializeRenderer(
		screenSize.x,
		screenSize.y,
		metaio::getScreenRotationForInterfaceOrientation(self.interfaceOrientation),
		metaio::ERENDER_SYSTEM_OPENGL_ES_2_0,
		context);
    
    // register our callback method for animations
    m_metaioSDK->registerDelegate(self);
    
}


- (void)viewWillAppear:(BOOL)animated
{	
    [super viewWillAppear:animated];
    
	// if the renderer appears we start rendering and capturing the camera
    [self startAnimation]; 
    if( m_metaioSDK )
    {
		std::vector<metaio::Camera> cameras = m_metaioSDK->getCameraList();
        if(cameras.size()>0)
		{
			cameras[0].resolution = metaio::Vector2di(480,360);
			m_metaioSDK->startCamera(cameras[0]);
		}
    }
    
    
    // if we start up in landscape mode after having portrait before, we want to make sure that the renderer is rotated correctly
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;    
    [self willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0];
}


- (void) viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];

}


- (void)viewWillDisappear:(BOOL)animated
{
	// as soon as the view disappears, we stop rendering and stop the camera
    [self stopAnimation];	
    if( m_metaioSDK )
    {
        m_metaioSDK->stopCamera();
    }
    
    [super viewWillDisappear:animated];	
}


- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:UIApplicationWillResignActiveNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:UIApplicationDidBecomeActiveNotification
	 object:nil];

    // Release any retained subviews of the main view.
    [self setGlView:nil];
    [super viewDidUnload];
}


- (void)onApplicationWillResignActive:(NSDictionary*)userInfo
{
	if (m_metaioSDK)
		m_metaioSDK->pause();
}


- (void)onApplicationDidBecomeActive:(NSDictionary*)userInfo
{
	if (m_metaioSDK)
		m_metaioSDK->resume();
}


- (void) viewDidLayoutSubviews
{
	float scale = [UIScreen mainScreen].scale;
	m_metaioSDK->resizeRenderer(self.glView.bounds.size.width*scale, self.glView.bounds.size.height*scale);
}


// Force fullscreen without status bar on iOS 7
- (BOOL)prefersStatusBarHidden
{
	return YES;
}


#pragma mark - Rotation handling


// pre-iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self shouldAutorotate] && ([self supportedInterfaceOrientations] & (1 << toInterfaceOrientation));
}


// iOS 6+
- (BOOL)shouldAutorotate
{
	return YES;
}


// iOS 6+
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}


// We will keep the renderer always in the same orientation
// However, if the interface changes, we need to compensate the UI rotation by applying an inverse rotation
// This method is also being called on viewWillAppear
//
// If you don't want your interface to rotate, just return 'NO' in shouldAutorotateToInterfaceOrientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // adjust the rotation based on the interface orientation
    m_metaioSDK->setScreenRotation( metaio::getScreenRotationForInterfaceOrientation(interfaceOrientation) );
    
    // on ios5, we handle this in didLayoutSubView
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if( version < 5.0)
	{
		float scale = [UIScreen mainScreen].scale;
		m_metaioSDK->resizeRenderer(self.glView.bounds.size.width*scale, self.glView.bounds.size.height*scale);
	}

}




#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

#pragma mark - @protocol metaioSDKDelegate

- (void) onSDKReady
{
    // Implement if reaction to SDK initialization is needed
    // Please implement in the subclass-->template.mm
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    // Implement if reaction to animation termination is needed
    // Please implement in the subclass-->template.mm
}

- (void) onMovieEnd:(metaio::IGeometry *)geometry andName:(NSString *)movieName
{
    // Implement if reaction to movie termination is needed
    // Please implement in the subclass-->template.mm
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    // Implement if camera image is needed
    // Please implement in the subclass-->template.mm
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    // Implement if camera image (filename and path) is needed
    // Please implement in the subclass-->template.mm
}

- (void) onScreenshotImage:(metaio::ImageStruct *)image
{
    // Implement if screenshot image is needed
    // Please implement in the subclass-->template.mm
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    // Implement if screenshot image is needed
    // Please implement in the subclass-->template.mm
}

- (void) onScreenshot:(NSString *)filepath
{
    // Implemenmt if screenshot image file is needed
    // Please implement in the subclass-->template.mm
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    // Implement if new poses are needed
    // Please implement in the subclass-->template.mm
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    // Implement if reaction to instant 3D tracking is needed
    // Please implement in the subclass-->template.mm
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    // Implement if visual search result is needed
    // Please implement in the subclass-->template.mm
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    // Implement if reaction to visual search state change is needed
    // Please implement in the subclass-->template.mm
}

#pragma mark - OpenGL related
//
// You usually don't have to change anything for the methods below
//

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [glView setFramebuffer];
    
    // tell SDK to render
    if( m_metaioSDK )
    {
        m_metaioSDK->render();    
    }
    
    [glView presentFramebuffer];
}

@end
