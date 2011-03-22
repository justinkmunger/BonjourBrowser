//
//  BonjourBrowserAppDelegate.m
//  BonjourBrowser
//
//  Created by Justin Munger on 3/16/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "BonjourBrowserAppDelegate.h"
#import "ServiceListViewController.h"

@implementation BonjourBrowserAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
