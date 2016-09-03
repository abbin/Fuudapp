//
//  FARestaurantObject.h
//  Fuudapp
//
//  Created by Abbin Varghese on 03/09/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Parse/Parse.h>

@interface FARestaurantObject : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (strong, nonatomic) NSString *restaurantName;
@property (strong, nonatomic) NSString *restaurantAddress;
@property (strong, nonatomic) PFGeoPoint *restaurantLocation;
@property (strong, nonatomic) NSMutableArray *restaurantPhoneNumbers;
@property (strong, nonatomic) NSMutableArray *restaurantWorkingHours;

+(FARestaurantObject*)initWithDictionary:(NSDictionary*)dictionary;
+(FARestaurantObject*)initWithName:(NSString*)name address:(NSString*)address latitude:(double)latitude longitude:(double)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSMutableArray*)workingDays from:(NSString*)from till:(NSString*)till;

@end
