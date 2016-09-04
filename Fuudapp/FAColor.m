//
//  FAColor.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAConstants.h"
#import "FARemoteConfig.h"

@implementation FAColor

+(UIColor *)mainColor{
    return [self colorFromHexString:[FARemoteConfig mainColorHex]];
}

+(UIColor *)openGreen{
    return [self colorFromHexString:[FARemoteConfig openGreenColorHex]];
}

+(UIColor *)closedRed{
    return [self colorFromHexString:[FARemoteConfig closedRedColorHex]];
}

+(UIColor *)colorWithRating:(id)rating{
    NSInteger rate = [rating integerValue];
    if (rate>4) {
        return [self colorFromHexString:[FARemoteConfig fiveColorHex]];
    }
    else if (rate>3){
        return [self colorFromHexString:[FARemoteConfig fourColorHex]];
    }
    else if (rate>2){
        return [self colorFromHexString:[FARemoteConfig threeColorHex]];
    }
    else if (rate>1){
        return [self colorFromHexString:[FARemoteConfig twoColorHex]];
    }
    else{
        return [self colorFromHexString:[FARemoteConfig oneColorHex]];
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
