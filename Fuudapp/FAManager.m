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
#import <UIKit/UIKit.h>

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
    
    NSInteger precision = 10;
    
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

+(void)observeEventWithCompletion:(void (^)(NSArray *items))completion{
    double lat = 9.976250;
    double lng = 76.293778;
    
    NSString *hash = [self geoHashFromLatitude:lat andLongitude:lng];
    
    NSRange stringRange = {0, MIN([hash length], 5)};
    
    // adjust the range to include dependent chars
    stringRange = [hash rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [hash substringWithRange:stringRange];
    
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:kFAItemPathKey];
    [[[[ref queryOrderedByChild:kFARestaurantLGeoHashKey] queryStartingAtValue:shortString] queryEndingAtValue:[NSString stringWithFormat:@"%@\uf8ff",shortString]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            completion([snapshot.value allValues]);
        }
        else{
            completion([NSArray new]);
        }
     }];
}

+(void)saveReview:(NSString*)review rating:(NSInteger)rating forItem:(NSMutableDictionary*)item withImages:(NSArray*)images{
    
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
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            
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
            }];
            
            // Errors only occur in the "Failure" case
            [uploadTask2 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot2) {
                if (snapshot2.error != nil) {
                    
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                              parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
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
                    }];
                    
                    // Errors only occur in the "Failure" case
                    [uploadTask3 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                                  parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
                                                               kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];
                        
                        
                        if (snapshot3.error != nil) {
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
                        
                        item.imageArray = [self addArray:imageArray toOldArray:item.imageArray];
                        
                        NSMutableArray *reviewArray = item.reviewArray;
                        if (reviewArray == nil) {
                            reviewArray = [NSMutableArray new];
                        }
                        [reviewArray addObject:@{kFAReviewTextKey:review}];
                        item.reviewArray = reviewArray;
                        
                        NSInteger oldRting = [item.rating integerValue];
                        NSInteger newRating = (oldRting + rating)/2;
                        item.rating = [NSNumber numberWithInteger:newRating];
                        
                        NSString * itemKey = item.itemId;
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
                        [ref updateChildValues:childUpdates];
                        
                        [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                                  parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                               kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                               kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:3],
                                                               kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                               kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                               kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                        
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
                    
                    item.imageArray = [self addArray:imageArray toOldArray:item.imageArray];
                    
                    NSMutableArray *reviewArray = item.reviewArray;
                    if (reviewArray == nil) {
                        reviewArray = [NSMutableArray new];
                    }
                    [reviewArray addObject:@{kFAReviewTextKey:review}];
                    item.reviewArray = reviewArray;
                    
                    NSInteger oldRting = [item.rating integerValue];
                    NSInteger newRating = (oldRting + rating)/2;
                    item.rating = [NSNumber numberWithInteger:newRating];
                    
                    NSString * itemKey = item.itemId;
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
                    [ref updateChildValues:childUpdates];
                    
                    [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                              parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                           kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                           kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:2],
                                                           kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                           kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                           kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                    
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
            
            item.imageArray = [self addArray:imageArray toOldArray:item.imageArray];
            
            NSMutableArray *reviewArray = item.reviewArray;
            if (reviewArray == nil) {
                reviewArray = [NSMutableArray new];
            }
            [reviewArray addObject:@{kFAReviewTextKey:review}];
            item.reviewArray = reviewArray;
            
            NSInteger oldRting = [item.rating integerValue];
            NSInteger newRating = (oldRting + rating)/2;
            item.rating = [NSNumber numberWithInteger:newRating];
            
            NSString * itemKey = item.itemId;
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item};
            [ref updateChildValues:childUpdates];
            
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:1],
                                                   kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            
            NSLog(@"All Uploads Finished");
        }
    }];
}

+(void)saveItem:(NSMutableDictionary*)item andRestaurant:(NSMutableDictionary*)restaurant withImages:(NSArray*)images{
    
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
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            
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
            }];
            
            // Errors only occur in the "Failure" case
            [uploadTask2 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot2) {
                if (snapshot2.error != nil) {
                    
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                              parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
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
                    }];
                    
                    // Errors only occur in the "Failure" case
                    [uploadTask3 observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot3) {
                        
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsFailureKey
                                                  parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription,
                                                               kFAAnalyticsSectionKey:kFAAnalyticsStorageTaskKey}];

                        
                        if (snapshot3.error != nil) {
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
                        
                        NSString *restKey = restaurant.restId;
                        
                        item.restaurant = restaurant;
                        item.imageArray = imageArray;
                        item.latitude = restaurant.latitude;
                        item.longitude = restaurant.longitude;
                        item.geoHash = restaurant.geoHash;
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                                       [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                        
                        [ref updateChildValues:childUpdates];
                        
                        [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                        [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                                  parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                               kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                               kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:3],
                                                               kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                               kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                               kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                        
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
                    
                    NSString *restKey = restaurant.restId;
                    
                    item.restaurant = restaurant;
                    item.imageArray = imageArray;
                    item.latitude = restaurant.latitude;
                    item.longitude = restaurant.longitude;
                    item.geoHash = restaurant.geoHash;
                    
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                                   [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                    
                    [ref updateChildValues:childUpdates];
                    
                    [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
                    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                              parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                           kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                           kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:2],
                                                           kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                           kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                           kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
                    
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
            
            NSString *restKey = restaurant.restId;
            
            item.restaurant = restaurant;
            item.imageArray = imageArray;
            item.latitude = restaurant.latitude;
            item.longitude = restaurant.longitude;
            item.geoHash = restaurant.geoHash;
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,item.itemId]: item,
                                           [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
            
            [ref updateChildValues:childUpdates];
            
            [FAAnalyticsManager sharedManager].networkTimeEnd = [NSDate date];
            [FAAnalyticsManager logEventWithName:kFAAnalyticsAddCompletedKey
                                      parameters:@{kFAAnalyticsNetworkTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].networkTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].networkTimeStart]],
                                                   kFAAnalyticsScreenTimeKey: [NSNumber numberWithDouble:[[FAAnalyticsManager sharedManager].screenTimeEnd timeIntervalSinceDate:[FAAnalyticsManager sharedManager].screenTimeStart]],
                                                   kFAAnalyticsImageCountKey: [NSNumber numberWithInteger:1],
                                                   kFAAnalyticsImageSourceKey: [NSNumber numberWithInteger:[FAAnalyticsManager sharedManager].imageSource],
                                                   kFAAnalyticsUserItemKey: [FAAnalyticsManager sharedManager].userItem,
                                                   kFAAnalyticsUserRestaurantKey: [FAAnalyticsManager sharedManager].userRestaurant}];
            
            NSLog(@"All Uploads Finished");
        }
    }];
}

@end
