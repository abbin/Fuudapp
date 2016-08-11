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

@dynamic name,address,latitude,longitude,geoHash,phoneNumbers,workingHours,restId;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setName:(NSString *)name{
    [self setObject:name forKey:kFARestaurantNameKey];
}

-(void)setAddress:(NSString *)address{
    [self setObject:address forKey:kFARestaurantAddressKey];
}

-(void)setLatitude:(NSNumber *)latitude{
    [self setObject:latitude forKey:kFARestaurantLatitudeKey];
}

-(void)setLongitude:(NSNumber *)longitude{
    [self setObject:longitude forKey:kFARestaurantLongitudeKey];
}

-(void)setGeoHash:(NSString *)geoHash{
    [self setObject:geoHash forKey:kFARestaurantLGeoHashKey];
}

-(void)setPhoneNumbers:(NSMutableArray *)phoneNumbers{
    [self setObject:phoneNumbers forKey:kFARestaurantPhoneNumberKey];
}

-(void)setWorkingHours:(NSMutableArray *)workingHours{
    [self setObject:workingHours forKey:kFARestaurantWorkingHoursKey];
}

-(void)setRestId:(NSString *)restId{
    [self setObject:restId forKey:kFARestaurantIdKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)name{
    return [self objectForKey:kFARestaurantNameKey];
}

-(NSString *)address{
    return [self objectForKey:kFARestaurantAddressKey];
}

-(NSNumber *)latitude{
    return [self objectForKey:kFARestaurantLatitudeKey];
}

-(NSNumber *)longitude{
    return [self objectForKey:kFARestaurantLongitudeKey];
}

-(NSString *)geoHash{
    return [self objectForKey:kFARestaurantLGeoHashKey];
}

-(NSMutableArray *)phoneNumbers{
    return [self objectForKey:kFARestaurantPhoneNumberKey];
}

-(NSMutableArray *)workingHours{
    return [self objectForKey:kFARestaurantWorkingHoursKey];
}

-(NSString *)restId{
    return [self objectForKey:kFARestaurantIdKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init Methods -

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant{
    self = [self init];
    if (self) {
        @try {
            self.name = [restaurant objectForKey:@"name"];
        } @catch (NSException *exception) {
            self.name = @"";
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.address = [restaurant objectForKey:@"formatted_address"];
        } @catch (NSException *exception) {
            self.address = @"";
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.latitude = [NSNumber numberWithDouble:[[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
            self.longitude = [NSNumber numberWithDouble:[[[[restaurant objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
            self.geoHash = [self geoHashFromLatitude:[self.latitude doubleValue] andLongitude:[self.longitude doubleValue]];
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        @try {
            self.phoneNumbers = [NSMutableArray arrayWithObject:[restaurant objectForKey:@"formatted_phone_number"]];
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
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
            self.workingHours = array;
        } @catch (NSException *exception) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:exception.reason,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsInitRestaurantKey}];
        }
        
        self.restId = [restaurant objectForKey:@"id"];
        
    }
    return self;
}

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSMutableArray*)workingDays from:(NSString*)from till:(NSString*)till{
    self = [self init];
    if (self) {
        self.restId = [self uuid];
        self.name = name;
        self.address = address;
        self.latitude = latitude;
        self.longitude = longitude;
        self.geoHash = [self geoHashFromLatitude:[self.latitude doubleValue] andLongitude:[self.longitude doubleValue]];
        if (phoneNumber.count>0) {
            self.phoneNumbers = phoneNumber;
        }
        if (workingDays.count>0) {
            for (NSMutableDictionary *dict in workingDays) {
                [[dict objectForKey:@"close"] setObject:till forKey:@"time"];
                [[dict objectForKey:@"open"] setObject:from forKey:@"time"];
            }
            self.workingHours = workingDays;
        }
    }
    return self;
}


- (NSString*)geoHashFromLatitude:(double)latitude andLongitude:(double)longitude{
    
    #define BITS_PER_BASE32_CHAR 5
    static const char BASE_32_CHARS[] = "0123456789bcdefghjkmnpqrstuvwxyz";
    
    double longitudeRange[] = { -180 , 180 };
    double latitudeRange[] = { -90 , 90 };
    
    NSInteger precision = 10;
    
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
