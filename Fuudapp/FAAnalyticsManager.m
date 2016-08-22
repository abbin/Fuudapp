//
//  FAAnalyticsManager.m
//  Fuudapp
//
//  Created by Abbin Varghese on 06/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAnalyticsManager.h"

NSString *const FAAnalyticsImageSourceGallery                   = @"gallery";
NSString *const FAAnalyticsImageSourceCamera                    = @"camera";

@implementation FAAnalyticsManager

+ (void)logEventWithName:(nonnull NSString *)name
              parameters:(nullable NSDictionary<NSString *, NSObject *> *)parameters{
    
    [FIRAnalytics logEventWithName:name
                        parameters:parameters];
    
    [Answers logCustomEventWithName:name
                   customAttributes:parameters];
}

+ (void)logSearchWithQuery:(nullable NSString *)query
          customAttributes:(nullable NSMutableDictionary *)customAttributes{
    [Answers logSearchWithQuery:query
               customAttributes:customAttributes];
    
    [customAttributes setObject:query forKey:kFIRParameterSearchTerm];
    [FIRAnalytics logEventWithName:kFIREventSearch
                        parameters:customAttributes];
    
}

+ (nonnull instancetype)sharedManager {
    static FAAnalyticsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    return self;
}

-(void)resetManager{
    self.networkTimeStart = nil;
    self.networkTimeEnd = nil;
    self.screenTimeStart = nil;
    self.screenTimeEnd = nil;
    self.userItem = nil;
    self.userRestaurant = nil;
}

@end
