//
//  FAColor.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation FAColor

+(UIColor *)mainColor{
    return UIColorFromRGB(0xF44336);
}

+(UIColor *)imagePickerBorderColor{
    return UIColorFromRGB(0x4CAF50);
}

+(UIColor*)alertRed{
    return UIColorFromRGB(0xD32F2F);
}
@end