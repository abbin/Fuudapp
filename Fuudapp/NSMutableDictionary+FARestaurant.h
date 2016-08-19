//
//  NSMutableDictionary+FARestaurant.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FARestaurant)

@property (strong, nonatomic) NSString *restaurantName;
@property (strong, nonatomic) NSString *restaurantAddress;
@property (strong, nonatomic) NSNumber *restaurantlatitude;
@property (strong, nonatomic) NSNumber *restaurantLongitude;
@property (strong, nonatomic) NSString *restaurantGeohash;
@property (strong, nonatomic) NSMutableArray *restaurantPhoneNumbers;
@property (strong, nonatomic) NSMutableArray *restaurantWorkingHours;
@property (strong, nonatomic) NSString *restaurantID;

-(instancetype)initRestaurantWithDictionary:(NSDictionary*)dictionary;

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSMutableArray*)workingDays from:(NSString*)from till:(NSString*)till;

@end
