//
//  AppDelegate.m
//  APPSortingController-Example
//
//  Created by Anton Pavlyuk on 02.04.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    FirstViewController *firstViewController = [[FirstViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
