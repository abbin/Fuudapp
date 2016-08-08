//
//  FAAnalyticsManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 06/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

typedef NS_ENUM(NSInteger, FAAnalyticsImageSource){
    FAAnalyticsImageSourceGallery,
    FAAnalyticsImageSourceCamera,
};

@import FirebaseAnalytics;

@interface FAAnalyticsManager : NSObject

+ (nonnull instancetype)sharedManager;

+ (void)logEventWithName:(nonnull NSString *)name
              parameters:(nullable NSDictionary<NSString *, NSObject *> *)parameters;

+ (void)logSearchWithQuery:(nullable NSString *)query
          customAttributes:(nullable NSMutableDictionary *)customAttributes;

-(void)resetManager;

@property (strong, nonatomic,nullable) NSDate *networkTimeStart;
@property (strong, nonatomic,nullable) NSDate *networkTimeEnd;
@property (strong, nonatomic,nullable) NSDate *screenTimeStart;
@property (strong, nonatomic,nullable) NSDate *screenTimeEnd;
@property (strong, nonatomic,nullable) NSNumber *userItem;
@property (strong, nonatomic,nullable) NSNumber *userRestaurant;
@property (assign, nonatomic) NSInteger imageSource;

@end
