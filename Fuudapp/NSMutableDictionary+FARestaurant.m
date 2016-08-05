//
//  NSMutableDictionary+FARestaurant.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FARestaurant.h"
#import "FAConstants.h"

@implementation NSMutableDictionary (FARestaurant)

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant{
     self = [self init];
    if (self) {
        @try {
            [self setObject:[restaurant objectForKey:@"name"] forKey:kFARestaurantNameKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantNameKey];
        }
        
        @try {
            [self setObject:[restaurant objectForKey:@"formatted_address"] forKey:kFARestaurantAddressKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantAddressKey];
        }
        
        @try {
            [self setObject:[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] forKey:kFARestaurantLatitudeKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantLatitudeKey];
        }
        
        @try {
            [self setObject:[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] forKey:kFARestaurantLongitudeKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantLongitudeKey];
        }
        
        @try {
            [self setObject:@[[restaurant objectForKey:@"formatted_phone_number"]] forKey:kFARestaurantPhoneNumberKey];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:kFARestaurantPhoneNumberKey];
        }
        
        @try {
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *dict in [[restaurant objectForKey:@"opening_hours"] objectForKey:@"periods"]) {
                
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
            [self setObject:@"" forKey:@"opening_hours"];
        }
        
        @try {
            NSArray *locality = [restaurant[@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(types CONTAINS[cd] %@)", @"locality"]];
            NSDictionary *locDict = [locality objectAtIndex:0];
            
            NSArray *administrative_area_level_1 = [restaurant[@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(types CONTAINS[cd] %@)", @"administrative_area_level_1"]];
            NSDictionary *adminDict = [administrative_area_level_1 objectAtIndex:0];
            
            NSArray *country = [restaurant[@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(types CONTAINS[cd] %@)", @"country"]];
            NSDictionary *countryDict = [country objectAtIndex:0];
            
            [self setObject:[NSString stringWithFormat:@"%@, %@, %@",locDict[@"long_name"],adminDict[@"long_name"],countryDict[@"long_name"]] forKey:@"locality"];
            
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"locality"];
        }
        
        [self setObject:[self uuid] forKey:@"id"];
    }
    return self;
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
