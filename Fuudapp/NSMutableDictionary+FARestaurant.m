//
//  NSMutableDictionary+FARestaurant.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FARestaurant.h"
#import "FAConstants.h"
#import "FAAnalyticsManager.h"

@implementation NSMutableDictionary (FARestaurant)

@dynamic restaurantName,restaurantAddress,restaurantlatitude,restaurantLongitude,restaurantGeohash,restaurantPhoneNumbers,restaurantWorkingHours,restaurantID;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setRestaurantName:(NSString *)restaurantName{
    [self setObject:restaurantName forKey:kFARestaurantNameKey];
}

-(void)setRestaurantAddress:(NSString *)restaurantAddress{
    [self setObject:restaurantAddress forKey:kFARestaurantAddressKey];
}

-(void)setRestaurantlatitude:(NSNumber *)restaurantlatitude{
    [self setObject:restaurantlatitude forKey:kFARestaurantLatitudeKey];
}

-(void)setRestaurantLongitude:(NSNumber *)restaurantLongitude{
    [self setObject:restaurantLongitude forKey:kFARestaurantLongitudeKey];
}

-(void)setRestaurantGeohash:(NSString *)restaurantGeohash{
    [self setObject:restaurantGeohash forKey:kFARestaurantLGeoHashKey];
}

-(void)setRestaurantPhoneNumbers:(NSMutableArray *)restaurantPhoneNumbers{
    [self setObject:restaurantPhoneNumbers forKey:kFARestaurantPhoneNumberKey];
}

-(void)setRestaurantWorkingHours:(NSMutableArray *)restaurantWorkingHours{
    [self setObject:restaurantWorkingHours forKey:kFARestaurantWorkingHoursKey];
}

-(void)setRestaurantID:(NSString *)restaurantID{
    [self setObject:restaurantID forKey:kFARestaurantIdKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)restaurantName{
    return [self objectForKey:kFARestaurantNameKey];
}

-(NSString *)restaurantAddress{
    return [self objectForKey:kFARestaurantAddressKey];
}

-(NSNumber *)restaurantlatitude{
    return [self objectForKey:kFARestaurantLatitudeKey];
}

-(NSNumber *)restaurantLongitude{
    return [self objectForKey:kFARestaurantLongitudeKey];
}

-(NSString *)restaurantGeohash{
    return [self objectForKey:kFARestaurantLGeoHashKey];
}

-(NSMutableArray *)restaurantPhoneNumbers{
    return [self objectForKey:kFARestaurantPhoneNumberKey];
}

-(NSMutableArray *)restaurantWorkingHours{
    return [self objectForKey:kFARestaurantWorkingHoursKey];
}

-(NSString *)restaurantID{
    return [self objectForKey:kFARestaurantIdKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init Methods -

-(instancetype)initRestaurantWithDictionary:(NSDictionary*)dictionary{
    self = [self init];
    if (self) {
        @try {
            self.restaurantName = [dictionary objectForKey:@"name"];
        } @catch (NSException *exception) {
            self.restaurantName = @"";
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.restaurantAddress = [dictionary objectForKey:@"formatted_address"];
        } @catch (NSException *exception) {
            self.restaurantAddress = @"";
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.restaurantlatitude = [NSNumber numberWithDouble:[[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
            self.restaurantLongitude = [NSNumber numberWithDouble:[[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
            self.restaurantGeohash = [self geoHashFromLatitude:[self.restaurantlatitude doubleValue] andLongitude:[self.restaurantLongitude doubleValue]];
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.restaurantPhoneNumbers = [NSMutableArray arrayWithObject:[dictionary objectForKey:@"formatted_phone_number"]];
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }

        @try {
            NSArray *periods = [[dictionary objectForKey:@"opening_hours"] objectForKey:@"periods"];
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
            self.restaurantWorkingHours = array;
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        self.restaurantID = [dictionary objectForKey:@"id"];
        
    }
    return self;
}

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSMutableArray*)workingDays from:(NSString*)from till:(NSString*)till{
    self = [self init];
    if (self) {
        self.restaurantID = [self uuid];
        self.restaurantName = name;
        self.restaurantAddress = address;
        self.restaurantlatitude = latitude;
        self.restaurantLongitude = longitude;
        self.restaurantGeohash = [self geoHashFromLatitude:[self.restaurantlatitude doubleValue] andLongitude:[self.restaurantLongitude doubleValue]];
        if (phoneNumber.count>0) {
            self.restaurantPhoneNumbers = phoneNumber;
        }
        if (workingDays.count>0) {
            for (NSMutableDictionary *dict in workingDays) {
                [[dict objectForKey:@"close"] setObject:till forKey:@"time"];
                [[dict objectForKey:@"open"] setObject:from forKey:@"time"];
            }
            self.restaurantWorkingHours = workingDays;
        }
    }
    return self;
}


- (NSString*)geoHashFromLatitude:(double)latitude andLongitude:(double)longitude{
    
    #define BITS_PER_BASE32_CHAR 5
    static const char BASE_32_CHARS[] = "0123456789bcdefghjkmnpqrstuvwxyz";
    
    double longitudeRange[] = { -180 , 180 };
    double latitudeRange[] = { -90 , 90 };
    
    NSInteger precision = kFAGeoHashPrecisionKey;
    
    char buffer[precision+1];
    buffer[precision] = 0;
    
    for (NSUInteger i = 0; i < precision; i++) {
        NSUInteger hashVal = 0;
        for (NSUInteger j = 0; j < BITS_PER_BASE32_CHAR; j++) {
            BOOL even = ((i*BITS_PER_BASE32_CHAR)+j) % 2 == 0;
            double val = (even) ? longitude : latitude;
            double* range = (even) ? longitudeRange : latitudeRange;
            double mid = (range[0] + range[1])/2;
            if (val > mid) {
                hashVal = (hashVal << 1) + 1;
                range[0] = mid;
            } else {
                hashVal = (hashVal << 1) + 0;
                range[1] = mid;
            }
        }
        buffer[i] = BASE_32_CHARS[hashVal];
    }
    return [NSString stringWithUTF8String:buffer];
}

- (NSString *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
