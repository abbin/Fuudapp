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
NSString *const kFAItemCappedNameKey                = @"item_capped_name";
NSString *const kFAItemPriceKey                     = @"item_price";
NSString *const kFAItemCurrencyKey                  = @"item_currency";
NSString *const kFAItemCurrencySymbolKey            = @"item_currency_symbol";
NSString *const kFAItemDescriptionKey               = @"item_description";
NSString *const kFAItemRestaurantKey                = @"item_restaurant";
NSString *const kFAItemRatingKey                    = @"item_rating";
NSString *const kFAItemImagesKey                    = @"item_images";
NSString *const kFAItemIdKey                        = @"item_id";
NSString *const kFAItemReviewsKey                   = @"item_reviews";
NSString *const kFAItemImageMetaDataKey             = @"item_image_metadata";
NSString *const kFAItemUserIDKey                    = @"item_user_id";
NSString *const kFAItemUserPhotoURLKey              = @"item_user_photourl";
NSString *const kFAItemUserNameKey                  = @"item_user_name";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image -

NSString *const kFAItemImagesURLKey                 = @"item_image_url";
NSString *const kFAItemImagesTimeStampKey           = @"item_image_timeStamp";
NSString *const kFAItemImagesVoteKey                = @"item_image_vote";
NSString *const kFAItemImagesPathKey                = @"item_image_path";
NSString *const kFAItemImagesHeightKey              = @"item_image_height";
NSString *const kFAItemImagesWidthKey               = @"item_image_width";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Review -

NSString *const kFAReviewTextKey                    = @"review_text";


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Restaurant -

NSString *const kFARestaurantNameKey                = @"restaurant_name";
NSString *const kFARestaurantAddressKey             = @"restaurant_address";
NSString *const kFARestaurantLatitudeKey            = @"restaurant_latitude";
NSString *const kFARestaurantLongitudeKey           = @"restaurant_longitude";
NSString *const kFARestaurantLGeoHashKey            = @"restaurant_geohash";
NSString *const kFARestaurantPhoneNumberKey         = @"restaurant_phone_number";
NSString *const kFARestaurantWorkingHoursKey        = @"restaurant_working_hours";
NSString *const kFARestaurantIdKey                  = @"restaurant_id";



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Locality -

NSString *const kFALocalityNameKey                  = @"locality_name";
NSString *const kFALocalityLongitudeKey             = @"locality_longitude";
NSString *const kFALocalityLatitudeKey              = @"locality_latitude";




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - APP -

NSString *const kFASelectedLocalityKey              = @"user_locality";
NSInteger const kFAGeoHashPrecisionKey              = 22;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Events -

NSString *const kFAAnalyticsAddPhotosKey            = @"add_photos";
NSString *const kFAAnalyticsAddItemKey              = @"add_item";
NSString *const kFAAnalyticsAddRestaurantKey        = @"add_restaurant";
NSString *const kFAAnalyticsAddCompletedKey         = @"add_completed";
NSString *const kFAAnalyticsFailureKey              = @"failure";




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Parameters Keys -

NSString *const kFAAnalyticsNetworkTimeKey          = @"network_time";
NSString *const kFAAnalyticsScreenTimeKey           = @"screen_time";
NSString *const kFAAnalyticsImageCountKey           = @"image_count";
NSString *const kFAAnalyticsImageSourceKey          = @"image_source";
NSString *const kFAAnalyticsUserItemKey             = @"user_item";
NSString *const kFAAnalyticsUserRestaurantKey       = @"user_restaurant";

NSString *const kFAAnalyticsReasonKey               = @"reason";
NSString *const kFAAnalyticsSectionKey              = @"section";

NSString *const kFAAnalyticsSucessKey               = @"sucess";
NSString *const kFAAnalyticsResultCountKey          = @"result_count";
NSString *const kFAAnalyticsResultTimeKey           = @"result_time";


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Analytics Parameters Values-

NSString *const kFAAnalyticsStorageDeleteTaskKey    = @"image_delete_task";
NSString *const kFAAnalyticsStorageTaskKey          = @"image_upload_task";
NSString *const kFAAnalyticsInitRestaurantKey       = @"init_restaurant";
NSString *const kFAAnalyticsRestaurantSearchKey     = @"restaurant_search";



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Config Keys -

#pragma mark - Fonts -
NSString *const kFARemoteConfigPrimaryFontKey                   = @"primaryFont";
NSString *const kFARemoteConfigSecondaryKey                     = @"secondaryFont";

#pragma mark - Colors -
NSString *const kFARemoteConfigMainColorHexKey                  = @"mainColorHex";
NSString *const kFARemoteConfigOpenGreenColorHexKey             = @"openGreenColorHex";
NSString *const kFARemoteConfigClosedRedColorHexKey             = @"closedRedColorHex";
NSString *const kFARemoteConfigRatingOneColorHexKey             = @"ratingOneColorHex";
NSString *const kFARemoteConfigRatingTwoColorHexKey             = @"ratingTwoColorHex";
NSString *const kFARemoteConfigRatingThreeColorHexKey           = @"ratingThreeColorHex";
NSString *const kFARemoteConfigRatingFourColorHexKey            = @"ratingFourColorHex";
NSString *const kFARemoteConfigRatingFiveColorHexKey            = @"ratingFiveColorHex";

@end
