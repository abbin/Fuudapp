//
//  NSMutableDictionary+FARestaurant.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FARestaurant.h"
#import "FAConstants.h"
#import <Crashlytics/Crashlytics.h>

@import FirebaseAnalytics;

@implementation NSMutableDictionary (FARestaurant)

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant{
    self = [self init];
    if (self) {
        @try {
            [self setObject:[restaurant objectForKey:@"name"] forKey:kFARestaurantNameKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantNameKey];
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
        @try {
            [self setObject:[restaurant objectForKey:@"formatted_address"] forKey:kFARestaurantAddressKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantAddressKey];
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
        @try {
            [self setObject:[NSNumber numberWithDouble:[[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]] forKey:kFARestaurantLatitudeKey];
        } @catch (NSException *exception) {
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
        @try {
            [self setObject:[NSNumber numberWithDouble:[[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]] forKey:kFARestaurantLongitudeKey];
        } @catch (NSException *exception) {
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
        @try {
            [self setObject:@[[restaurant objectForKey:@"formatted_phone_number"]] forKey:kFARestaurantPhoneNumberKey];
        } @catch (NSException *exception) {
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
        @try {
            NSArray *periods = [[restaurant objectForKey:@"opening_hours"] objectForKey:@"periods"];
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *dict in periods) {
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSArray *daySymbols = dateFormatter.standaloneWeekdaySymbols;
                
                NSInteger dayIndex = [[[dict objectForKey:@"close"] objectForKey:@"day"] integerValue]; // 0 = Sunday, ... 6 = Saturday
                NSString *dayName = daySymbols[dayIndex];
                
                NSMutableDictionary *close = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [[dict objectForKey:@"close"] objectForKey:@"day"],@"day",
                                              [[dict objectForKey:@"close"] objectForKey:@"time"],@"time",
                                              dayName, @"dayName", nil];
                
                NSMutableDictionary *open = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [[dict objectForKey:@"open"] objectForKey:@"day"],@"day",
                                             [[dict objectForKey:@"open"] objectForKey:@"time"],@"time",
                                             dayName, @"dayName", nil];
                
                NSMutableDictionary *mainDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:close,@"close",open,@"open", nil];
                [array addObject:mainDict];
            }
            [self setObject:array forKey:@"opening_hours"];
        } @catch (NSException *exception) {
            [Answers logCustomEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                           customAttributes:@{kFAAnalyticsReasonKey:exception.reason}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsGoogleRestaurantExceptionKey
                                parameters:@{kFAAnalyticsReasonKey:exception.reason}];
        }
        
    }
    return self;
}

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSArray*)workingDays from:(NSString*)from till:(NSString*)till{
    self = [self init];
    if (self) {
        [self setObject:[NSNumber numberWithBool:YES] forKey:kFAUserAddedRestaurantKey];
        [self setObject:name forKey:kFARestaurantNameKey];
        [self setObject:address forKey:kFARestaurantAddressKey];
        [self setObject:latitude forKey:kFARestaurantLatitudeKey];
        [self setObject:longitude forKey:kFARestaurantLongitudeKey];
        if (phoneNumber.count>0) {
            [self setObject:phoneNumber forKey:kFARestaurantPhoneNumberKey];
        }
        if (workingDays.count>0) {
            for (NSMutableDictionary *dict in workingDays) {
                [[dict objectForKey:@"close"] setObject:till forKey:@"time"];
                [[dict objectForKey:@"open"] setObject:from forKey:@"time"];
            }
            [self setObject:workingDays forKey:kFARestaurantWorkingHoursKey];
        }
    }
    return self;
}

@end
