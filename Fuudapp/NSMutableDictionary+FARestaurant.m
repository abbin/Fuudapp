//
//  NSMutableDictionary+FARestaurant.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FARestaurant.h"

@implementation NSMutableDictionary (FARestaurant)

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant{
     self = [self init];
    if (self) {
        @try {
            [self setObject:[restaurant objectForKey:@"formatted_address"] forKey:@"formatted_address"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"formatted_address"];
        }
        
        @try {
            [self setObject:[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] forKey:@"lat"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"lat"];
        }
        
        @try {
            [self setObject:[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] forKey:@"lng"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"lng"];
        }
        
        @try {
            [self setObject:[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] forKey:@"lng"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"lng"];
        }
        
        @try {
            [self setObject:[restaurant objectForKey:@"international_phone_number"] forKey:@"international_phone_number"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"international_phone_number"];
        }
        
        @try {
            [self setObject:[restaurant objectForKey:@"name"] forKey:@"name"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"name"];
        }
        
        @try {
            [self setObject:[[restaurant objectForKey:@"opening_hours"] objectForKey:@"periods"] forKey:@"opening_hours"];
        } @catch (NSException *exception) {
            [self setObject:@"" forKey:@"opening_hours"];
        }
        
        @try {
            NSArray *filtered = [restaurant[@"address_components"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(types CONTAINS[cd] %@)", @"locality"]];
            NSDictionary *item = [filtered objectAtIndex:0];
            [self setObject:item[@"long_name"] forKey:@"locality"];
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
