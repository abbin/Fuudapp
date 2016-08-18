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

@dynamic localityName,lat,lng;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setLocalityName:(NSString *)localityName{
    [self setObject:localityName forKey:kFALocalityNameKey];
}

-(void)setLat:(NSNumber *)lat{
    [self setObject:lat forKey:kFALocalityLatitudeKey];
}

-(void)setLng:(NSNumber *)lng{
    [self setObject:lng forKey:kFALocalityLongitudeKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)localityName{
    return [self objectForKey:kFALocalityNameKey];
}

-(NSNumber *)lat{
    return [self objectForKey:kFALocalityLatitudeKey];
}


-(NSNumber *)lng{
    return [self objectForKey:kFALocalityLongitudeKey];
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
            self.lat = [NSNumber numberWithDouble:[[[[locality objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]];
        } @catch (NSException *exception) {
        }
        
        @try {
            self.lng = [NSNumber numberWithDouble:[[[[locality objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
        } @catch (NSException *exception) {
        }
        
    }
    return self;
}

@end
