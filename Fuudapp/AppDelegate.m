//
//  AppDelegate.m
//  Fuudapp
//
//  Created by Abbin Varghese on 25/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "AppDelegate.h"
#import "FAConstants.h"
#import "FAManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FAManager.h"
#import "FALocationViewController.h"

@import GoogleMaps;
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    [GMSServices provideAPIKey:kFAGoogleMapsKey];
    [FAManager remoteConfig];
    [FIRDatabase database].persistenceEnabled = YES;
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKLoginButton class];
    
//    NSError *error;
//    [[FIRAuth auth] signOut:&error];
//    if (!error) {
//        // Sign-out succeeded
//    }
    
    [[UINavigationBar appearance] setBarTintColor:[FAColor mainColor]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:17.0]}];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]} forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTintColor:[FAColor mainColor]];
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[FAColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15.0]} forState:UIControlStateNormal];
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:[UIFont systemFontSize]]];
    
    if ([FAManager isFirstLaunch]) {
        if ([FIRAuth auth].currentUser == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FASignInViewController"];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController = rootViewController;
            [self.window makeKeyAndVisible];
        }
        else if (![FAManager isLocationSet]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FALocationViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FALocationViewController"];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController = rootViewController;
            [self.window makeKeyAndVisible];
        }
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
