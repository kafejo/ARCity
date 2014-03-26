//
// ARELViewController.h
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//


#import "MetaioSDKViewController.h"
#import <metaioSDK/GestureHandlerIOS.h>
#import <metaioSDK/IARELInterpreterIOS.h>

// forward declarations
@class EAGLView;

@interface ARELViewController : MetaioSDKViewController<UIGestureRecognizerDelegate, IARELInterpreterIOSDelegate>
{	
	metaio::IARELInterpreterIOS*	m_ArelInterpreter;
	GestureHandlerIOS*				m_pGestureHandlerIOS;
	NSString*						m_arelFile;
}

@property (nonatomic, retain) IBOutlet UIWebView* m_arelWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil instructions:(NSString *)arelTutorialConfig;

- (void) onSDKReady;

@end

