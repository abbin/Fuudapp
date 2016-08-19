//
//  NSMutableDictionary+FALocality.m
//  Fuudapp
//
//  Created by Abbin Varghese on 18/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FALocality.h"
#import "FAConstants.h"

@implementation NSMutableDictionary (FALocality)

@dynamic localityName,localityLatitude,localityLongitude;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setLocalityName:(NSString *)localityName{
    [self setObject:localityName forKey:kFALocalityNameKey];
}

-(void)setLocalityLatitude:(NSNumber *)localityLatitude{
    [self setObject:localityLatitude forKey:kFALocalityLatitudeKey];
}

-(void)setLocalityLongitude:(NSNumber *)localityLongitude{
    [self setObject:localityLongitude forKey:kFALocalityLongitudeKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)localityName{
    return [self objectForKey:kFALocalityNameKey];
}

-(NSNumber *)localityLongitude{
    return [self objectForKey:kFALocalityLongitudeKey];
}

-(NSNumber *)localityLatitude{
    return [self objectForKey:kFALocalityLatitudeKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init Methods -

-(instancetype)initWithLocality:(NSDictionary*)locality{
    self = [self init];
    if (self) {
        @try {
            self.localityName = [locality objectForKey:@"formatted_address"];
        } @catch (NSException *exception) {
            self.localityName = @"";
        }
        @try {
            self.localityLatitude = [NSNumber numberWithDouble:[[[[locality objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
        } @catch (NSException *exception) {
        }
        
        @try {
            self.localityLongitude = [NSNumber numberWithDouble:[[[[locality objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
        } @catch (NSException *exception) {
        }
        
    }
    return self;
}

@end
