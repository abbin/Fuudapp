//
//  FAConstants.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAConstants : NSObject

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Server -

FOUNDATION_EXPORT NSString *const kFAGoogleServerKey;
FOUNDATION_EXPORT NSString *const kFAGoogleMapsKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Firebase Path -

FOUNDATION_EXPORT NSString *const kFAItemPathKey;
FOUNDATION_EXPORT NSString *const kFARestaurantPathKey;
FOUNDATION_EXPORT NSString *const kFAStoragePathKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Item -

FOUNDATION_EXPORT NSString *const kFAItemNameKey;
FOUNDATION_EXPORT NSString *const kFAItemPriceKey;
FOUNDATION_EXPORT NSString *const kFAItemCurrencyKey;
FOUNDATION_EXPORT NSString *const kFAItemDescriptionKey;
FOUNDATION_EXPORT NSString *const kFAItemRestaurantKey;
FOUNDATION_EXPORT NSString *const kFAItemRatingKey;
FOUNDATION_EXPORT NSString *const kFAItemImagesKey;
FOUNDATION_EXPORT NSString *const kFAItemIdKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Restaurant -

FOUNDATION_EXPORT NSString *const kFARestaurantNameKey;
FOUNDATION_EXPORT NSString *const kFARestaurantAddressKey;
FOUNDATION_EXPORT NSString *const kFARestaurantLatitudeKey;
FOUNDATION_EXPORT NSString *const kFARestaurantLongitudeKey;
FOUNDATION_EXPORT NSString *const kFARestaurantPhoneNumberKey;
FOUNDATION_EXPORT NSString *const kFARestaurantWorkingHoursKey;
FOUNDATION_EXPORT NSString *const kFARestaurantIdKey;

@end
