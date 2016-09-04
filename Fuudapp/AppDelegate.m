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
#import <Parse/Parse.h>
#import "FARemoteConfig.h"

@import GoogleMaps;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    [GMSServices provideAPIKey:kFAGoogleMapsKey];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKLoginButton class];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"0C6B889A28A74B37B3DAC2B14EC0F49C";
        
        configuration.server = @"http://fuudappdevelopment.herokuapp.com/parse";
        
    }]];
    
    [[UINavigationBar appearance] setBarTintColor:[FAColor mainColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FARemoteConfig primaryFontName] size:17.0]}];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]} forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTintColor:[FAColor mainColor]];
    [[UITabBar appearance] setBarTintColor:[FAColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[FAColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:[FARemoteConfig primaryFontName] size:15.0]} forState:UIControlStateNormal];
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setFont:[UIFont fontWithName:[FARemoteConfig secondaryFontName] size:[UIFont systemFontSize]]];
    
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
