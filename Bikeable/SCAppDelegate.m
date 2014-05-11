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
//    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

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
