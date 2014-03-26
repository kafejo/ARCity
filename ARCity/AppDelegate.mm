//
//  AppDelegate.m
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "ARELViewController.h"
#import "Template.h"

// With this macro you can decide whether you want to use the native or AREL-based template view
// controller (implemented in Template.mm or ARELViewController.mm, respectively)
//#define NATIVE

@implementation AppDelegate

- (void)dealloc
{
	[_window release];
	[_viewController release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

#ifdef NATIVE
    self.viewController = [[[Template alloc] initWithNibName:@"Template" bundle:nil] autorelease];
#else
	NSString* arelConfigFile = [NSString stringWithFormat:@"arelConfig"];
	NSString *arelDir = [NSString stringWithFormat:@"GameSrc"];
	NSString *arelConfigFilePath = [[NSBundle mainBundle] pathForResource:arelConfigFile ofType:@"xml" inDirectory:arelDir];
    NSLog(@"Will load AREL from %@", arelConfigFilePath);
	self.viewController = [[[ARELViewController alloc] initWithNibName:@"ARELViewController" bundle:nil instructions:arelConfigFilePath] autorelease];
#endif

	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
