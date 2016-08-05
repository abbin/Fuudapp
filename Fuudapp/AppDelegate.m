//
//  AppDelegate.m
//  Fuudapp
//
//  Created by Abbin Varghese on 25/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@import GoogleMaps;
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UINavigationBar appearance] setBarTintColor:[FAColor whiteColor]];
    [[UITabBar appearance] setTintColor:[FAColor mainColor]];
    [[UIBarButtonItem appearance] setTintColor:[FAColor blackColor]];
    
    [Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    [GMSServices provideAPIKey:@"AIzaSyD6PMkkD1Ecqyhm1E3BWAag-JX-5tQbRU4"];
    
    return YES;
}

@end
