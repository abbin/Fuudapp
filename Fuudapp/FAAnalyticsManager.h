//
//  FAAnalyticsManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 06/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

@interface FAAnalyticsManager : NSObject

+ (_Nonnull instancetype)sharedManager;

+ (void)logEventWithName:(nonnull NSString *)name
              parameters:(nullable NSDictionary<NSString *, NSObject *> *)parameters;

+ (void)logSearchWithQuery:(nullable NSString *)query
          customAttributes:(nullable NSMutableDictionary*)customAttributes;

@property (strong, nonatomic, nullable) NSDate *itemMakeStart;
@property (strong, nonatomic, nullable) NSDate *itemMakeEnd;

@property (strong, nonatomic, nullable) NSDate *imageUploadStart;
@property (strong, nonatomic, nullable) NSDate *imageUploadEnd;

@property (strong, nonatomic, nullable) NSString *imageSource;
@property (strong, nonatomic, nullable) NSNumber *uploadedImageCount;

@property (strong, nonatomic, nullable) NSNumber *isNewRestaurant;

@end
