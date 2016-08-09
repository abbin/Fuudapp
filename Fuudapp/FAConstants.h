//
//  FAConstants.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

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
FOUNDATION_EXPORT NSString *const kFAItemCappedNameKey;
FOUNDATION_EXPORT NSString *const kFAItemPriceKey;
FOUNDATION_EXPORT NSString *const kFAItemCurrencyKey;
FOUNDATION_EXPORT NSString *const kFAItemDescriptionKey;
FOUNDATION_EXPORT NSString *const kFAItemRestaurantKey;
FOUNDATION_EXPORT NSString *const kFAItemRatingKey;
FOUNDATION_EXPORT NSString *const kFAItemImagesKey;
FOUNDATION_EXPORT NSString *const kFAItemIdKey;
FOUNDATION_EXPORT NSString *const kFAItemReviewsKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image -

FOUNDATION_EXPORT NSString *const kFAItemImagesURLKey;
FOUNDATION_EXPORT NSString *const kFAItemImagesTimeStampKey;
FOUNDATION_EXPORT NSString *const kFAItemImagesVoteKey;
FOUNDATION_EXPORT NSString *const kFAItemImagesPathKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Review -

FOUNDATION_EXPORT NSString *const kFAReviewTextKey;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Restaurant -

FOUNDATION_EXPORT NSString *const kFARestaurantNameKey;
FOUNDATION_EXPORT NSString *const kFARestaurantAddressKey;
FOUNDATION_EXPORT NSString *const kFARestaurantLatitudeKey;
FOUNDATION_EXPORT NSString *const kFARestaurantLongitudeKey;
FOUNDATION_EXPORT NSString *const kFARestaurantPhoneNumberKey;
FOUNDATION_EXPORT NSString *const kFARestaurantWorkingHoursKey;
FOUNDATION_EXPORT NSString *const kFARestaurantIdKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Events -

FOUNDATION_EXPORT NSString *const kFAAnalyticsAddPhotosKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsAddItemKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsAddRestaurantKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsAddCompletedKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsFailureKey;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Parameters Keys -

FOUNDATION_EXPORT NSString *const kFAAnalyticsNetworkTimeKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsScreenTimeKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsImageCountKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsImageSourceKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsUserItemKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsUserRestaurantKey;

FOUNDATION_EXPORT NSString *const kFAAnalyticsReasonKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsSectionKey;

FOUNDATION_EXPORT NSString *const kFAAnalyticsSucessKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsResultCountKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsResultTimeKey;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Parameters Values-

FOUNDATION_EXPORT NSString *const kFAAnalyticsStorageTaskKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsInitRestaurantKey;
FOUNDATION_EXPORT NSString *const kFAAnalyticsRestaurantSearchKey;

@end
