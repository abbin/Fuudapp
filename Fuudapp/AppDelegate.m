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

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import GoogleMaps;
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setBarTintColor:[FAColor mainColor]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    [[UITabBar appearance] setTintColor:[FAColor mainColor]];
    [[UIBarButtonItem appearance] setTintColor:[FAColor whiteColor]];
    
    
    [Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    [GMSServices provideAPIKey:kFAGoogleMapsKey];

    return YES;
}

@end
