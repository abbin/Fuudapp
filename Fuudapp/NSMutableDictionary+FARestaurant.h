//
//  NSMutableDictionary+FARestaurant.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FARestaurant)

-(instancetype)initWithRestaurant:(NSDictionary*)restaurant;

-(instancetype)initRestaurantWithName:(NSString*)name address:(NSString*)address latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude phonumber:(NSMutableArray*)phoneNumber workingDays:(NSArray*)workingDays from:(NSString*)from till:(NSString*)till;

@end
