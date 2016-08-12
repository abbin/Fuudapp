//
//  FAColor.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAConstants.h"

@import FirebaseRemoteConfig;

@implementation FAColor

+(UIColor *)mainColor{
    return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigMainColorHexKey].stringValue];
}

+(UIColor *)activityIndicatorColor{
    return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigActivityIndicatorColorHexKey].stringValue];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
