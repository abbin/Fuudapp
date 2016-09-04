//
//  FAAnalyticsManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 06/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

FOUNDATION_EXPORT NSString * __nonnull const FAAnalyticsImageSourceGallery;
FOUNDATION_EXPORT NSString * __nonnull const FAAnalyticsImageSourceCamera;

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
@property (strong, nonatomic,nullable) NSString *userItem;
@property (strong, nonatomic,nullable) NSString *userRestaurant;
@property (strong, nonatomic,nullable) NSString *imageSource;

@end
