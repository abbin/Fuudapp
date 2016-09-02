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
#import "NSMutableDictionary+FAItem.h"
#import "NSMutableDictionary+FARestaurant.h"
#import "NSMutableDictionary+FALocality.h"
#import <UIKit/UIKit.h>
#import "FAColor.h"

@import CoreLocation;
@import FirebaseDatabase;
@import FirebaseStorage;
@import FirebaseRemoteConfig;

@implementation FAManager

+ (void)remoteConfig{
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
#ifdef DEBUG
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    remoteConfig.configSettings = remoteConfigSettings;
#else
#endif
    [remoteConfig setDefaultsFromPlistFileName:@"RemoteConfigDefaults"];
    [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            [remoteConfig activateFetched];
        }
    }];
}

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

+(NSMutableArray*)addArray:(NSArray*)newArray toOldArray:(NSMutableArray*)oldArray{
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
    for (NSDictionary *dict in finalArray) {
        FIRStorageReference *storageRefdel = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@%@",kFAStoragePathKey,[dict objectForKey:kFAItemImagesPathKey]]];
        // Delete the file
        [storageRefdel deleteWithCompletion:^(NSError *error){
            if (error) {
                [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                          parameters:@{kFAAnalyticsReasonKey:error.localizedDescription,
                                                       kFAAnalyticsSectionKey:kFAAnalyticsStorageDeleteTaskKey}];
            }
        }];
    }
    return [result mutableCopy];
}

+(void)observeEventWithCompletion:(void (^)(NSMutableArray *items))completion{
    NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults]objectForKey:kFASelectedLocalityKey];
    
    double lat = [loc.localityLatitude doubleValue];
    double lng = [loc.localityLongitude doubleValue];
    
    NSString *hash = [self geoHashFromLatitude:lat andLongitude:lng];
    
    NSRange stringRange = {0, MIN([hash length], 4)};
    
    // adjust the range to include dependent chars
    stringRange = [hash rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [hash substringWithRange:stringRange];

    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:kFAItemPathKey];
    [[[[ref queryOrderedByChild:kFARestaurantLGeoHashKey] queryStartingAtValue:shortString] queryEndingAtValue:[NSString stringWithFormat:@"%@\uf8ff",shortString]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completion([self sortAndModifyArray:[snapshot.value allValues]]);
            });
        }
        else{
            completion([NSMutableArray new]);
        }
     }];
}

+(NSMutableArray*)sortAndModifyArray:(NSArray*)itemsArray{
    for (NSMutableDictionary *dict in itemsArray) {
        double lat = [dict.itemLatitude doubleValue];
        double lng = [dict.itemLongitude doubleValue];
        dict.itemDistance = [self distanceBetweenstatLat:lat lon:lng];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *predicateString = [NSString stringWithFormat:@"close.dayName like '%@'",dayName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
        NSArray *result = [dict.itemRestaurant.restaurantWorkingHours filteredArrayUsingPredicate:pred];
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
                                 value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                dict.itemOpenHours = atString;
            }
            else{
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                                 range:NSMakeRange(0, 10)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor closedRed]
                                 range:NSMakeRange(0, 10)];
                
                dict.itemOpenHours = atString;
            }
        }
        else{
            NSInteger midnightSecond = 23*60*60 + 59*60 + 59;
            if (nowSecond>openSecond && nowSecond < midnightSecond) {
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                dict.itemOpenHours = atString;
            }
            else if (nowSecond >= 0 && nowSecond <closeSecond){
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                                 range:NSMakeRange(0, 8)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor openGreen]
                                 range:NSMakeRange(0, 8)];
                
                dict.itemOpenHours = atString;
            }
            else{
                NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
                [atString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                                 range:NSMakeRange(0, 10)];
                [atString addAttribute:NSForegroundColorAttributeName
                                 value:[FAColor closedRed]
                                 range:NSMakeRange(0, 10)];
                
                dict.itemOpenHours = atString;
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

+(void)saveReview:(NSString*)review rating:(float)rating forItem:(NSMutableDictionary*)item withImages:(NSArray*)images{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveNotificationKey object:self];
    
    __block double progressCheck = 0;
    __block double progress = 0;
    
    [FAAnalyticsManager sharedManager].networkTimeStart = [NSDate date];
    [FAAnalyticsManager sharedManager].screenTimeEnd = [NSDate date];
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM"];
    NSString *myMonthString = [df stringFromDate:[NSDate date]];
    [df setDateFormat:@"yyyy"];
    NSString *myYearString = [df stringFromDate:[NSDate date]];
    
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
    
    UIImage *imageOne = images[0];
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    metadata.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageOne.size.height],
                                     kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageOne.size.width]};
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [storageRef putData:UIImageJPEGRepresentation(imageOne, 0.5) metadata:metadata];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload reported progress
        double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
        NSLog(@"First = %f",percentComplete);
        progressCheck = progress + percentComplete/images.count;
        NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            
            NSDictionary *userInfo = @{@"error":snapshot.error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
            
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
            
            switch (snapshot.error.code) {
                case FIRStorageErrorCodeObjectNotFound:
                    // File doesn't exist
                    break;
                    
                case FIRStorageErrorCodeUnauthorized:
                    // User doesn't have permission to access file
                    break;
                    
                case FIRStorageErrorCodeCancelled:
                    // User canceled the upload
                    break;
                    
                case FIRStorageErrorCodeUnknown:
                    // Unknown error occurred, inspect the server response
                    break;
            }
        }
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        progress = progressCheck;
        if (images.count>1) {
            
            FIRStorageReference *storageRef2 = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
            
            UIImage *imageTwo = images[1];
            // Create the file metadata
            FIRStorageMetadata *metadataTwo = [[FIRStorageMetadata alloc] init];
            metadataTwo.contentType = @"image/jpeg";
            metadataTwo.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageTwo.size.height],
                                        kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageTwo.size.width]};
            
            FIRStorageUploadTask *uploadTask2 = [storageRef2 putData:UIImageJPEGRepresentation(imageTwo, 0.5) metadata:metadataTwo];
            
            [uploadTask2 observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot2) {
                // Upload reported progress
                double percentComplete = 100.0 * (snapshot2.progress.completedUnitCount) / (snapshot2.progress.totalUnitCount);
                NSLog(@"Second = %f",percentComplete);
                progressCheck = progress + percentComplete/images.count;
                NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
                [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
            }];
            
            // Errors only occur in the "Failure" case
            [uploadTask2 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot2) {
                if (snapshot2.error != nil) {
                    
                    NSDictionary *userInfo = @{@"error":snapshot2.error.localizedDescription};
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
                    
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                              parameters:@{kFAAnalyticsReasonKey:snapshot2.error.localizedDescription,
                                                           kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
                    
                    
                    switch (snapshot2.error.code) {
                        case FIRStorageErrorCodeObjectNotFound:
                            // File doesn't exist
                            break;
                            
                        case FIRStorageErrorCodeUnauthorized:
                            // User doesn't have permission to access file
                            break;
                            
                        case FIRStorageErrorCodeCancelled:
                            // User canceled the upload
                            break;
                            
                        case FIRStorageErrorCodeUnknown:
                            // Unknown error occurred, inspect the server response
                            break;
                    }
                }
            }];
            
            [uploadTask2 observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot2) {
                progress = progressCheck;
                if (images.count>2) {
                    
                    FIRStorageReference *storageRef3 = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
                    
                    UIImage *imageThree = images[2];
                    // Create the file metadata
                    FIRStorageMetadata *metadataThree = [[FIRStorageMetadata alloc] init];
                    metadataThree.contentType = @"image/jpeg";
                    metadataThree.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageThree.size.height],
                                                   kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageThree.size.width]};
                    
                    FIRStorageUploadTask *uploadTask3 = [storageRef3 putData:UIImageJPEGRepresentation(imageThree, 0.5) metadata:metadataThree];
                    
                    [uploadTask3 observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        // Upload reported progress
                        double percentComplete = 100.0 * (snapshot3.progress.completedUnitCount) / (snapshot3.progress.totalUnitCount);
                        NSLog(@"Thrid = %f",percentComplete);
                        progressCheck = progress + percentComplete/images.count;
                        NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
                    }];
                    
                    // Errors only occur in the "Failure" case
                    [uploadTask3 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        if (snapshot3.error != nil) {
                            
                            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                                      parameters:@{kFAAnalyticsReasonKey:snapshot3.error.localizedDescription,
                                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
                            
                            NSDictionary *userInfo = @{@"error":snapshot3.error.localizedDescription};
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
                            
                            switch (snapshot3.error.code) {
                                case FIRStorageErrorCodeObjectNotFound:
                                    // File doesn't exist
                                    break;
                                    
                                case FIRStorageErrorCodeUnauthorized:
                                    // User doesn't have permission to access file
                                    break;
                                    
                                case FIRStorageErrorCodeCancelled:
                                    // User canceled the upload
                                    break;
                                    
                                case FIRStorageErrorCodeUnknown:
                                    // Unknown error occurred, inspect the server response
                                    break;
                            }
                        }
                    }];
                    
                    [uploadTask3 observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        progress = progressCheck;
                        
                        NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
                        NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                                      @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                        kFAItemImagesTimeStampKey:timeStamp,
                                                        kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                        kFAItemImagesPathKey:snapshot.metadata.path,
                                                        kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                        kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                                      @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                        kFAItemImagesTimeStampKey:timeStamp,
                                                        kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                        kFAItemImagesPathKey:snapshot2.metadata.path,
                                                        kFAItemImagesHeightKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                        kFAItemImagesWidthKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                                      @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],
                                                        kFAItemImagesTimeStampKey:timeStamp,
                                                        kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                        kFAItemImagesPathKey:snapshot3.metadata.path,
                                                        kFAItemImagesHeightKey:[snapshot3.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                        kFAItemImagesWidthKey:[snapshot3.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
                        
                        item.itemImageArray = [self addArray:imageArray toOldArray:item.itemImageArray];
                        
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
                        
                        NSString * itemKey = item.itemId;
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
                        [ref updateChildValues:childUpdates];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
                        
                        [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                                  parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                               kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                               kFAAnalyticsImageCountKey: @"3",
                                                               kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                               kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                               kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                        [[FAAnalyticsManager sharedManager]resetManager];
                        
                        NSLog(@"All Uploads Finished");
                    }];
                }
                else{
                    
                    NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
                    NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                                  @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                    kFAItemImagesTimeStampKey:timeStamp,
                                                    kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                    kFAItemImagesPathKey:snapshot.metadata.path,
                                                    kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                    kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                                  @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                    kFAItemImagesTimeStampKey:timeStamp,
                                                    kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                    kFAItemImagesPathKey:snapshot2.metadata.path,
                                                    kFAItemImagesHeightKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                    kFAItemImagesWidthKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
                    
                    item.itemImageArray = [self addArray:imageArray toOldArray:item.itemImageArray];
                    
                    NSMutableArray *reviewArray = item.itemReviewArray;
                    if (reviewArray == nil) {
                        reviewArray = [NSMutableArray new];
                    }
                    [reviewArray addObject:@{kFAReviewTextKey:review}];
                    item.itemReviewArray = reviewArray;
                    
                    NSInteger oldRting = [item.itemRating integerValue];
                    NSInteger newRating = (oldRting + rating)/2;
                    item.itemRating = [NSNumber numberWithInteger:newRating];
                    
                    NSString * itemKey = item.itemId;
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
                    [ref updateChildValues:childUpdates];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
                    
                    [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                              parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                           kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                           kFAAnalyticsImageCountKey: @"2",
                                                           kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                           kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                           kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                    [[FAAnalyticsManager sharedManager]resetManager];
                    
                    NSLog(@"All Uploads Finished");
                }
            }];
            
        }
        else{
            
            NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
            NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                          @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                            kFAItemImagesTimeStampKey:timeStamp,
                                            kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                            kFAItemImagesPathKey:snapshot.metadata.path,
                                            kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                            kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
            
            item.itemImageArray = [self addArray:imageArray toOldArray:item.itemImageArray];
            
            NSMutableArray *reviewArray = item.itemReviewArray;
            if (reviewArray == nil) {
                reviewArray = [NSMutableArray new];
            }
            [reviewArray addObject:@{kFAReviewTextKey:review}];
            item.itemReviewArray = reviewArray;
            
            NSInteger oldRting = [item.itemRating integerValue];
            NSInteger newRating = (oldRting + rating)/2;
            item.itemRating = [NSNumber numberWithInteger:newRating];
            
            NSString * itemKey = item.itemId;
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
            [ref updateChildValues:childUpdates];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
            
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: @"1",
                                                   kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            [[FAAnalyticsManager sharedManager]resetManager];
            
            NSLog(@"All Uploads Finished");
        }
    }];
}

+(void)saveItem:(NSMutableDictionary*)item andRestaurant:(NSMutableDictionary*)restaurant withImages:(NSArray*)images{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveNotificationKey object:self];
    
    __block double progressCheck = 0;
    __block double progress = 0;
    
    [FAAnalyticsManager sharedManager].networkTimeStart = [NSDate date];
    [FAAnalyticsManager sharedManager].screenTimeEnd = [NSDate date];
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM"];
    NSString *myMonthString = [df stringFromDate:[NSDate date]];
    [df setDateFormat:@"yyyy"];
    NSString *myYearString = [df stringFromDate:[NSDate date]];
    
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
    
    UIImage *imageOne = images[0];
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    metadata.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageOne.size.height],
                                kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageOne.size.width]};
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [storageRef putData:UIImageJPEGRepresentation(imageOne, 0.5) metadata:metadata];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload reported progress
        double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
        NSLog(@"First = %f",percentComplete);
        progressCheck = progress + percentComplete/images.count;
        NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            
            NSDictionary *userInfo = @{@"error":snapshot.error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
            
            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                      parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
            
            switch (snapshot.error.code) {
                case FIRStorageErrorCodeObjectNotFound:
                    // File doesn't exist
                    break;
                    
                case FIRStorageErrorCodeUnauthorized:
                    // User doesn't have permission to access file
                    break;
                    
                case FIRStorageErrorCodeCancelled:
                    // User canceled the upload
                    break;
                    
                case FIRStorageErrorCodeUnknown:
                    // Unknown error occurred, inspect the server response
                    break;
            }
        }
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        progress = progressCheck;
        if (images.count>1) {
            
            FIRStorageReference *storageRef2 = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
            
            UIImage *imageTwo = images[1];
            // Create the file metadata
            FIRStorageMetadata *metadataTwo = [[FIRStorageMetadata alloc] init];
            metadataTwo.contentType = @"image/jpeg";
            metadataTwo.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageTwo.size.height],
                                        kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageTwo.size.width]};
            
            FIRStorageUploadTask *uploadTask2 = [storageRef2 putData:UIImageJPEGRepresentation(imageTwo, 0.5) metadata:metadataTwo];
            
            [uploadTask2 observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot2) {
                // Upload reported progress
                double percentComplete = 100.0 * (snapshot2.progress.completedUnitCount) / (snapshot2.progress.totalUnitCount);
                NSLog(@"Second = %f",percentComplete);
                progressCheck = progress + percentComplete/images.count;
                NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
                [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
            }];
            
            // Errors only occur in the "Failure" case
            [uploadTask2 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot2) {
                if (snapshot2.error != nil) {
                    
                    NSDictionary *userInfo = @{@"error":snapshot2.error.localizedDescription};
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
                    
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                              parameters:@{kFAAnalyticsReasonKey:snapshot2.error.localizedDescription,
                                                           kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];

                    
                    switch (snapshot2.error.code) {
                        case FIRStorageErrorCodeObjectNotFound:
                            // File doesn't exist
                            break;
                            
                        case FIRStorageErrorCodeUnauthorized:
                            // User doesn't have permission to access file
                            break;
                            
                        case FIRStorageErrorCodeCancelled:
                            // User canceled the upload
                            break;
                            
                        case FIRStorageErrorCodeUnknown:
                            // Unknown error occurred, inspect the server response
                            break;
                    }
                }
            }];
            
            [uploadTask2 observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot2) {
                progress = progressCheck;
                if (images.count>2) {
                    
                    FIRStorageReference *storageRef3 = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@item_images/%@%@/%@.jpg",kFAStoragePathKey,myYearString,myMonthString,[self uuid]]];
                    
                    UIImage *imageThree = images[2];
                    // Create the file metadata
                    FIRStorageMetadata *metadataThree = [[FIRStorageMetadata alloc] init];
                    metadataThree.contentType = @"image/jpeg";
                    metadataThree.customMetadata = @{kFAItemImagesHeightKey:[NSNumber numberWithFloat:imageThree.size.height],
                                                   kFAItemImagesWidthKey:[NSNumber numberWithFloat:imageThree.size.width]};
                    
                    FIRStorageUploadTask *uploadTask3 = [storageRef3 putData:UIImageJPEGRepresentation(imageThree, 0.5) metadata:metadataThree];
                    
                    [uploadTask3 observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        // Upload reported progress
                        double percentComplete = 100.0 * (snapshot3.progress.completedUnitCount) / (snapshot3.progress.totalUnitCount);
                        NSLog(@"Thrid = %f",percentComplete);
                        progressCheck = progress + percentComplete/images.count;
                        NSDictionary *userInfo = @{@"progress":[NSNumber numberWithDouble:progressCheck]};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveProgressNotificationKey object:self userInfo:userInfo];
                    }];
                    
                    // Errors only occur in the "Failure" case
                    [uploadTask3 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        if (snapshot3.error != nil) {
                            
                            [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                                      parameters:@{kFAAnalyticsReasonKey:snapshot3.error.localizedDescription,
                                                                   kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
                            
                            NSDictionary *userInfo = @{@"error":snapshot3.error.localizedDescription};
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveFailNotificationKey object:self userInfo:userInfo];
                            
                            switch (snapshot3.error.code) {
                                case FIRStorageErrorCodeObjectNotFound:
                                    // File doesn't exist
                                    break;
                                    
                                case FIRStorageErrorCodeUnauthorized:
                                    // User doesn't have permission to access file
                                    break;
                                    
                                case FIRStorageErrorCodeCancelled:
                                    // User canceled the upload
                                    break;
                                    
                                case FIRStorageErrorCodeUnknown:
                                    // Unknown error occurred, inspect the server response
                                    break;
                            }
                        }
                    }];
                    
                    [uploadTask3 observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        progress = progressCheck;
                        NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
                        NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot.metadata.path,
                                                 kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                 kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot2.metadata.path,
                                                 kFAItemImagesHeightKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                 kFAItemImagesWidthKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot3.metadata.path,
                                                 kFAItemImagesHeightKey:[snapshot3.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                 kFAItemImagesWidthKey:[snapshot3.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
                        
                        NSString *restKey = restaurant.restaurantID;
                        
                        item.itemRestaurant = restaurant;
                        item.itemImageArray = imageArray;
                        item.itemLatitude = restaurant.restaurantlatitude;
                        item.itemLongitude = restaurant.restaurantLongitude;
                        item.itemGeoHash = restaurant.restaurantGeohash;
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                                       [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                        
                        [ref updateChildValues:childUpdates];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
                        
                        [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                                  parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                               kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                               kFAAnalyticsImageCountKey: @"3",
                                                               kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                               kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                               kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                        [[FAAnalyticsManager sharedManager]resetManager];
                        
                        NSLog(@"All Uploads Finished");
                    }];
                }
                else{
                    
                    NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
                    NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                                  @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                    kFAItemImagesTimeStampKey:timeStamp,
                                                    kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                    kFAItemImagesPathKey:snapshot.metadata.path,
                                                    kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                    kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},
                                                  @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                    kFAItemImagesTimeStampKey:timeStamp,
                                                    kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                    kFAItemImagesPathKey:snapshot2.metadata.path,
                                                    kFAItemImagesHeightKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                                    kFAItemImagesWidthKey:[snapshot2.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
                    
                    NSString *restKey = restaurant.restaurantID;
                    
                    item.itemRestaurant = restaurant;
                    item.itemImageArray = imageArray;
                    item.itemLatitude = restaurant.restaurantlatitude;
                    item.itemLongitude = restaurant.restaurantLongitude;
                    item.itemGeoHash = restaurant.restaurantGeohash;
                    
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                                   [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                    
                    [ref updateChildValues:childUpdates];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
                    
                    [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                              parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                           kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                           kFAAnalyticsImageCountKey: @"2",
                                                           kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                           kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                           kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                    [[FAAnalyticsManager sharedManager]resetManager];
                    
                    NSLog(@"All Uploads Finished");
                }
            }];
            
        }
        else{
            
            NSNumber *timeStamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
            NSMutableArray *imageArray = [NSMutableArray arrayWithObjects:
                                          @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                            kFAItemImagesTimeStampKey:timeStamp,
                                            kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                            kFAItemImagesPathKey:snapshot.metadata.path,
                                            kFAItemImagesHeightKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesHeightKey],
                                            kFAItemImagesWidthKey:[snapshot.metadata.customMetadata objectForKey: kFAItemImagesWidthKey]},nil];
            
            NSString *restKey = restaurant.restaurantID;
            
            item.itemRestaurant = restaurant;
            item.itemImageArray = imageArray;
            item.itemLatitude = restaurant.restaurantlatitude;
            item.itemLongitude = restaurant.restaurantLongitude;
            item.itemGeoHash = restaurant.restaurantGeohash;
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                           [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
            
            [ref updateChildValues:childUpdates];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFASaveCompleteNotificationKey object:self];
            
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSString stringWithFormat:@"%f",[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: @"1",
                                                   kFAAnalyticsImageSourceKey: [FAAnalyticsManager sharedManager].imageSource,
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            [[FAAnalyticsManager sharedManager]resetManager];
            
            NSLog(@"All Uploads Finished");
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
