//
//  FAManager.m
//  Fuudapp
//
//  Created by Abbin Varghese on 04/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAManager.h"
#import "FAConstants.h"
#import "FAAnalyticsManager.h"
#import "NSMutableDictionary+FALocality.h"
#import <UIKit/UIKit.h>
#import "FAColor.h"
#import "FARemoteConfig.h"

@import CoreLocation;

@implementation FAManager

+ (NSString *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

+ (NSString*)geoHashFromLatitude:(double)latitude andLongitude:(double)longitude{
    
    #define BITS_PER_BASE32_CHAR 5
    static const char BASE_32_CHARS[] = "0123456789bcdefghjkmnpqrstuvwxyz";
    
    double longitudeRange[] = { -180 , 180 };
    double latitudeRange[] = { -90 , 90 };
    
    NSInteger precision = kFAGeoHashPrecisionKey;
    
    char buffer[precision+1];
    buffer[precision] = 0;
    
    for (NSUInteger i = 0; i < precision; i++) {
        NSUInteger hashVal = 0;
        for (NSUInteger j = 0; j < BITS_PER_BASE32_CHAR; j++) {
            BOOL even = ((i*BITS_PER_BASE32_CHAR)+j) % 2 == 0;
            double val = (even) ? longitude : latitude;
            double* range = (even) ? longitudeRange : latitudeRange;
            double mid = (range[0] + range[1])/2;
            if (val > mid) {
                hashVal = (hashVal << 1) + 1;
                range[0] = mid;
            } else {
                hashVal = (hashVal << 1) + 0;
                range[1] = mid;
            }
        }
        buffer[i] = BASE_32_CHARS[hashVal];
    }
    return [NSString stringWithUTF8String:buffer];
}

+(NSMutableArray*)addArrayP:(NSArray*)newArray toOldArray:(NSMutableArray*)oldArray{
    NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:kFAItemImagesVoteKey ascending:NO];
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:kFAItemImagesTimeStampKey ascending:NO];
    
    NSMutableArray *finalArray = [NSMutableArray new];
    NSMutableArray *existingArray = oldArray;
    
    [existingArray sortUsingDescriptors:@[voteDescriptor,dateDescriptor]];
    [finalArray addObjectsFromArray:[existingArray subarrayWithRange:NSMakeRange(0, MIN(5,existingArray.count))]];
    
    [existingArray removeObjectsInRange:NSMakeRange(0, MIN(5,existingArray.count))];
    [existingArray addObjectsFromArray:newArray];
    [existingArray sortUsingDescriptors:@[dateDescriptor]];
    [finalArray addObjectsFromArray:existingArray];
    
    NSArray *result = [finalArray subarrayWithRange:NSMakeRange(0, MIN(10, finalArray.count))];
    [finalArray removeObjectsInRange:NSMakeRange(0, MIN(10, finalArray.count))];
//    for (NSDictionary *dict in finalArray) {
//        FIRStorageReference *storageRefdel = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@%@",kFAStoragePathKey,[dict objectForKey:kFAItemImagesPathKey]]];
//        // Delete the file
//        [storageRefdel deleteWithCompletion:^(NSError *error){
//            if (error) {
//                [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
//                                          parameters:@{kFAAnalyticsReasonKey:error.localizedDescription,
//                                                       kFAAnalyticsSectionKey:kFAAnalyticsStorageDeleteTaskKey}];
//            }
//        }];
//    }
    return [result mutableCopy];
}

+(void)observeEventWithCompletion:(void (^)(NSMutableArray *items))completion{
    NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults]objectForKey:kFASelectedLocalityKey];
    
    double lat = [loc.localityLatitude doubleValue];
    double lng = [loc.localityLongitude doubleValue];
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:lat longitude:lng];
    PFQuery *query = [PFQuery queryWithClassName:kFAItemPathKey];
    [query includeKeys:@[@"itemRestaurant",@"itemUser"]];
    [query whereKey:@"itemLocation" nearGeoPoint:userGeoPoint withinKilometers:10];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count>0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completion([self sortAndModifyArray:objects]);
            });
        }
        else{
            completion([NSMutableArray new]);
        }
    }];
}

+(NSMutableArray*)sortAndModifyArray:(NSArray*)itemsArray{
    for (FAItemObject *item in itemsArray) {
        double lat = item.itemLocation.latitude;
        double lng = item.itemLocation.longitude;
        item.itemDistance = [self distanceBetweenstatLat:lat lon:lng];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *predicateString = [NSString stringWithFormat:@"close.dayName like '%@'",dayName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
        NSArray *result = [item.itemRestaurant.restaurantWorkingHours filteredArrayUsingPredicate:pred];
        NSMutableDictionary *todayDict = [result firstObject];
        
        NSString *closeString = [[todayDict objectForKey:@"close"] objectForKey:@"time"];
        NSString *openString = [[todayDict objectForKey:@"open"] objectForKey:@"time"];
        
        [dateFormatter setDateFormat:@"HHmm"];
        NSString *nowString = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDate *openDate = [dateFormatter dateFromString:openString];
        NSDate *closeDate = [dateFormatter dateFromString:closeString];
        
        [dateFormatter setDateFormat:@"h:mm a"];
        
        NSString *openingHour = [dateFormatter stringFromDate:openDate];
        NSString *closingHour = [dateFormatter stringFromDate:closeDate];
        
        NSInteger nowSecond = [self dictTimeToSeconds:nowString];
        NSInteger closeSecond = [self dictTimeToSeconds:closeString];
        NSInteger openSecond = [self dictTimeToSeconds:openString];
        
        if (openSecond-closeSecond<0){
            if (nowSecond>openSecond && nowSecond<closeSecond) {
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                item.itemOpenHours = [atString string];
            }
            else{
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]
                                 range:NSMakeRange(0, 10)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor closedRed]
                                 range:NSMakeRange(0, 10)];
                
                item.itemOpenHours = [atString string];
            }
        }
        else{
            NSInteger midnightSecond = 23*60*60 + 59*60 + 59;
            if (nowSecond>openSecond && nowSecond < midnightSecond) {
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                item.itemOpenHours = [atString string];
            }
            else if (nowSecond >= 0 && nowSecond <closeSecond){
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                item.itemOpenHours = [atString string];
            }
            else{
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10.0]
                                 range:NSMakeRange(0, 10)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor closedRed]
                                 range:NSMakeRange(0, 10)];
                
                item.itemOpenHours = [atString string];
            }
        }
        
    }
    NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:kFAItemRatingKey ascending:NO];
    NSArray *sortedArray = [itemsArray sortedArrayUsingDescriptors:@[voteDescriptor]];
    return [sortedArray mutableCopy];
}

+ (NSInteger)dictTimeToSeconds:(id)dictTime{
    NSInteger time = [dictTime integerValue];
    NSInteger hours = time / 100;
    NSInteger minutes = time % 100;
    return (hours * 60 * 60) + (minutes * 60);
}

+(NSString*)distanceBetweenstatLat:(double)lat lon:(double)lng{
    NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults] objectForKey:kFASelectedLocalityKey];
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[loc.localityLatitude doubleValue] longitude:[loc.localityLongitude doubleValue]];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    if (distance>1000) {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:0];
        return [NSString stringWithFormat:@"%@ km away",[formatter stringFromNumber:[NSNumber numberWithDouble:distance/1000]]];
    }
    else{
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:0];
        return [NSString stringWithFormat:@"%@ meters away",[formatter stringFromNumber:[NSNumber numberWithDouble:distance]]];
    }
}

+(void)savePItem:(FAItemObject*)item andRestaurant:(FARestaurantObject*)restaurant withImages:(NSArray*)images{
    
    [FAAnalyticsManager sharedManager].networkTimeStart = [NSDate date];
    [FAAnalyticsManager sharedManager].screenTimeEnd = [NSDate date];
    
    NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    NSMutableArray *imageArray = [NSMutableArray new];
    for (UIImage *image in images) {
        NSDictionary *dict = @{kFAItemImagesFileKey:[PFFile fileWithName:@"name.jpeg" data:UIImageJPEGRepresentation(image, 0.5)],
                               kFAItemImagesTimeStampKey:timeStamp,
                               kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0]};
        [imageArray addObject:dict];
    }
    item.itemRestaurant = restaurant;
    item.itemImageArray = imageArray;
    item.itemLocation = restaurant.restaurantLocation;
    
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:error.localizedDescription,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];

        }
        else{
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: [NSNumber numberWithUnsignedInteger:item.itemImageArray.count],
                                                   kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            [[FAAnalyticsManager sharedManager]resetManager];
        }
    }];
    
    [restaurant saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:error.localizedDescription,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];

        }
    }];
}

+(void)saveReviewP:(NSString*)review rating:(float)rating forItem:(FAItemObject*)item withImages:(NSArray*)images{
    
    [FAAnalyticsManager sharedManager].networkTimeStart = [NSDate date];
    [FAAnalyticsManager sharedManager].screenTimeEnd = [NSDate date];
    
    NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    NSMutableArray *imageArray = [NSMutableArray new];
    for (UIImage *image in images) {
        NSDictionary *dict = @{kFAItemImagesFileKey:[PFFile fileWithName:@"name.jpeg" data:UIImageJPEGRepresentation(image, 0.5)],
                               kFAItemImagesTimeStampKey:timeStamp,
                               kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0]};
        [imageArray addObject:dict];
    }
    item.itemImageArray = [self addArrayP:imageArray toOldArray:item.itemImageArray];
    NSMutableArray *reviewArray = item.itemReviewArray;
    if (reviewArray == nil) {
        reviewArray = [NSMutableArray new];
    }
    [reviewArray addObject:@{kFAReviewTextKey:review}];
    item.itemReviewArray = reviewArray;
    
    if (item.itemRating) {
        float oldRting = [item.itemRating floatValue];
        float newRating = (oldRting + rating)/2;
        item.itemRating = [NSNumber numberWithFloat:newRating];
    }
    else{
        item.itemRating = [NSNumber numberWithFloat:rating];
    }
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:error.localizedDescription,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
        }
        else{
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: [NSNumber numberWithUnsignedInteger:item.itemImageArray.count],
                                                   kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            [[FAAnalyticsManager sharedManager]resetManager];

        }
    }];
}


+(BOOL)isLocationSet{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFASelectedLocalityKey]) {
        return YES;
    }
    else{
        return NO;
    }
}

@end
