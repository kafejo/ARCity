//
//  ARELViewController.m
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#import "ARELViewController.h"


#include "TargetConditionals.h"		// to know if we're building for SIMULATOR
#include <metaioSDK/IMetaioSDKIOS.h>
#include <metaioSDK/IARELInterpreterIOS.h>
#include <metaioSDK/GestureHandler.h>

 
#import "EAGLView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface MetaioTouchesRecognizer : UIGestureRecognizer
{
    UIViewController* theLiveViewController;
}
- (void) setTheLiveViewController:(UIViewController*) controller;
@end


@implementation MetaioTouchesRecognizer

- (void) setTheLiveViewController:(UIViewController*) controller
{
    theLiveViewController = controller;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( theLiveViewController )
    {
        [theLiveViewController touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( theLiveViewController && ([self numberOfTouches] == 1) )
    {
        [theLiveViewController touchesMoved:touches withEvent:event];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( theLiveViewController )
    {
        [theLiveViewController touchesEnded:touches withEvent:event];
    }
}

@end


@implementation ARELViewController

@synthesize m_arelWebView;

#define DLog(...) NSLog(__VA_ARGS__)

#pragma mark -
#pragma mark Reload on shake

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil instructions:(NSString *)arelTutorialConfig
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        m_arelFile = [[NSString alloc] initWithString:arelTutorialConfig];
    }
    return self;
}

#pragma mark -
#pragma mark SDK callbacks

- (void) onSDKReady
{
	// load the AREL file after the SDK is ready
	m_ArelInterpreter->loadARELFile([m_arelFile UTF8String]);
}

#pragma mark -
#pragma mark Live View UI

/*
- (void) presentWebViewController: (WebViewViewController*) webviewcontroller
{
//    webviewcontroller.shouldAutomaticallyRotate = NO;   // 
    [self presentModalViewController:webviewcontroller animated:YES];
}*/


 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	float version = [[[UIDevice currentDevice] systemVersion] floatValue]; 
    if( version >= 5.0 )
    {
        m_arelWebView.scrollView.bounces = NO;
    }
    else
    {
        for (id subview in m_arelWebView.subviews)
        {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            {
                ((UIScrollView *)subview).bounces = NO;
            }
        }
        
        [m_arelWebView setBackgroundColor:[UIColor clearColor]];
    }

	
    MetaioTouchesRecognizer* recognizer = [[MetaioTouchesRecognizer alloc] init];
	[recognizer setTheLiveViewController:self];
    [recognizer setDelegate:self];
	[m_arelWebView addGestureRecognizer:recognizer];
   	[recognizer release];
	
    m_pGestureHandlerIOS = [[GestureHandlerIOS alloc] initWithSDK:m_metaioSDK
														 withView:m_arelWebView
													 withGestures:metaio::GestureHandler::GESTURE_ALL];
    
    m_ArelInterpreter = metaio::CreateARELInterpreterIOS(m_arelWebView, self);
	
    m_ArelInterpreter->initialize( m_metaioSDK, m_pGestureHandlerIOS->m_pGestureHandler );
    
    m_ArelInterpreter->setRadarProperties(metaio::IGeometry::ANCHOR_TL, metaio::Vector3d(1), metaio::Vector3d(1));
	
	m_ArelInterpreter->registerDelegate(self);
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    NSLog(@"arelFile=%@", m_arelFile);
    
    [self startAnimation];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void) viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}   



- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
}

- (void) viewDidLayoutSubviews
{
	float scale = [UIScreen mainScreen].scale;
	m_metaioSDK->resizeRenderer(self.glView.bounds.size.width*scale, self.glView.bounds.size.height*scale);
}


- (void)dealloc
{	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
/*
    if( arelInerpreter )
    {
	delete junaioPoiManager;
        junaioPoiManager = NULL;
    }
*/
    delete m_ArelInterpreter;
    [m_arelFile release];
    
    [super dealloc];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{

    m_metaioSDK->setScreenRotation( metaio::getScreenRotationForInterfaceOrientation(interfaceOrientation) ); 
    
    // on ios5, we handle this in didLayoutSubView
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if( version < 5.0)
	{
		float scale = [UIScreen mainScreen].scale;
		m_metaioSDK->resizeRenderer(self.glView.bounds.size.width*scale, self.glView.bounds.size.height*scale);
	}
 
}


#pragma mark -
#pragma mark Touches



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [m_pGestureHandlerIOS touchesBegan:touches withEvent:event withView:glView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
	[m_pGestureHandlerIOS touchesMoved:touches withEvent:event withView:glView];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [m_pGestureHandlerIOS touchesEnded:touches withEvent:event withView:glView];
}





#pragma mark - Tracking file loading





#pragma mark -






- (void)drawFrame
{
	[glView setFramebuffer];
    
    // tell sdk to render
    if( m_ArelInterpreter )
    {
		m_ArelInterpreter->update();
    }
    
    [glView presentFramebuffer];
}




@end



