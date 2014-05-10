//
//  SCAppDelegate.m
//  Ubike
//
//  Created by Prince on 5/10/14.
//  Copyright (c) 2014 wpsteak. All rights reserved.
//

#import "SCAppDelegate.h"
#import "MovesAPI.h"
#import "SCLoginViewController.h"
#import "SCMainViewController.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"uR6lNJB6eonp607A825z03Otg13AqlqdYX7jyi37"
                  clientKey:@"m4ZOmVdzB1lNwcoZt6d0xTUv6kjIyRpEmD3ZmA6K"];

    [[MovesAPI sharedInstance] setShareMovesOauthClientId:@"IJg69GS6DEqZUXoW57zcAZRNPPggjg_6"
                                        oauthClientSecret:@"73VJ389fUwgP013i0qeZx9h5Ykk1GU70c19N33Wmrja2300Xb8t0853lKFAp7gqA"
                                        callbackUrlScheme:@"CityBike"];
    
    [GMSServices provideAPIKey:@"AIzaSyA0fm2XcANWwxF23Mhf4LyDUpqWrFLwBBc"];

//    SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
    
    SCMainViewController *mainViewController=[[SCMainViewController alloc] initWithNibName:@"SCMainViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[MovesAPI sharedInstance] canHandleOpenUrl:url]) {
        return YES;
    }
    // Other 3rdParty Apps Handle Url Method...
    
    
    return NO;
}

@end
