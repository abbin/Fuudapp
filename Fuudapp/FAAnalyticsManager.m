//
//  FAAnalyticsManager.m
//  Fuudapp
//
//  Created by Abbin Varghese on 06/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAnalyticsManager.h"
@import FirebaseAnalytics;

@implementation FAAnalyticsManager

+ (void)logEventWithName:(nonnull NSString *)name
              parameters:(nullable NSDictionary<NSString *, NSObject *> *)parameters{
    [Answers logCustomEventWithName:name
                   customAttributes:parameters];
    
    [FIRAnalytics logEventWithName:name
                        parameters:parameters];
}

+ (void)logSearchWithQuery:(nullable NSString *)query
          customAttributes:(nullable NSMutableDictionary*)customAttributes{
    
    [Answers logSearchWithQuery:query
               customAttributes:customAttributes];
    
    [customAttributes setObject:query forKey:kFIRParameterSearchTerm];
    [FIRAnalytics logEventWithName:kFIREventSearch
                        parameters:customAttributes];
}

+ (id)sharedManager {
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


@end
