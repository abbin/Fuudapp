//
//  FAConstants.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAConstants.h"

@implementation FAConstants

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Server -

NSString *const kFAGoogleServerKey                  = @"AIzaSyByWRG1mG39YH7Uxj2DH9I3lLKaL0C15QY";
NSString *const kFAGoogleMapsKey                    = @"AIzaSyD6PMkkD1Ecqyhm1E3BWAag-JX-5tQbRU4";



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Firebase Path -

NSString *const kFAItemPathKey                      = @"items";
NSString *const kFARestaurantPathKey                = @"restaurants";
NSString *const kFAStoragePathKey                   = @"gs://fuudappdev.appspot.com/";



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Item -

NSString *const kFAItemNameKey                      = @"item_name";
NSString *const kFAItemPriceKey                     = @"item_price";
NSString *const kFAItemCurrencyKey                  = @"item_currency";
NSString *const kFAItemDescriptionKey               = @"item_description";
NSString *const kFAItemRestaurantKey                = @"item_restaurant";
NSString *const kFAItemRatingKey                    = @"item_rating";
NSString *const kFAItemImagesKey                    = @"item_images";
NSString *const kFAItemIdKey                        = @"item_id";



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Restaurant -

NSString *const kFARestaurantNameKey = @"restaurant_name";
NSString *const kFARestaurantAddressKey = @"restaurant_address";
NSString *const kFARestaurantLatitudeKey = @"restaurant_latitude";
NSString *const kFARestaurantLongitudeKey = @"restaurant_longitude";
NSString *const kFARestaurantPhoneNumberKey = @"restaurant_phone_number";
NSString *const kFARestaurantWorkingHoursKey = @"restaurant_working_hours";
NSString *const kFARestaurantIdKey = @"restaurant_id";




@end
