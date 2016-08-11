//
//  NSMutableDictionary+FARestaurant.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FARestaurant)

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSString *geoHash;
@property (strong, nonatomic) NSMutableArray *phoneNumbers;
@property (strong, nonatomic) NSMutableArray *workingHours;
@property (strong, nonatomic) NSString *restId;

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant;

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSMutableArray*)workingDays from:(NSString*)from till:(NSString*)till;

@end
