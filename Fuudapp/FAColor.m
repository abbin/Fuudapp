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

+(UIColor *)openGreen{
    return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigOpenGreenColorHexKey].stringValue];
}

+(UIColor *)closedRed{
    return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigClosedRedColorHexKey].stringValue];
}

+(UIColor *)colorWithRating:(id)rating{
    NSInteger rate = [rating integerValue];
    if (rate>4) {
        return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigRatingFiveColorHexKey].stringValue];
    }
    else if (rate>3){
        return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigRatingFourColorHexKey].stringValue];
    }
    else if (rate>2){
        return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigRatingThreeColorHexKey].stringValue];
    }
    else if (rate>1){
        return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigRatingTwoColorHexKey].stringValue];
    }
    else{
        return [self colorFromHexString:[FIRRemoteConfig remoteConfig][kFARemoteConfigRatingOneColorHexKey].stringValue];
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
