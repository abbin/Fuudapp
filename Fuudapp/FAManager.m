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

#import <UIKit/UIKit.h>

@import FirebaseDatabase;
@import FirebaseStorage;

@implementation FAManager

+ (NSString *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

+(void)observeEventWithCompletion:(void (^)(BOOL finished))completion{
    
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
    
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [storageRef putData:UIImageJPEGRepresentation(images[0], 0.5) metadata:metadata];
    
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
            FIRStorageUploadTask *uploadTask2 = [storageRef2 putData:UIImageJPEGRepresentation(images[1], 0.5) metadata:metadata];
            
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
                    FIRStorageUploadTask *uploadTask3 = [storageRef3 putData:UIImageJPEGRepresentation(images[2], 0.5) metadata:metadata];
                    
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
                        NSArray *imageArray = [NSArray arrayWithObjects:
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot.metadata.path},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot2.metadata.path},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot3.metadata.path},nil];
                        
                        
        
                        NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_vote" ascending:NO];
                        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_timeStamp" ascending:NO];
                        
                        NSMutableArray *finalArray = [NSMutableArray new];
                        NSMutableArray *existingArray = [item objectForKey:kFAItemImagesKey];
                        
                        [existingArray sortUsingDescriptors:@[voteDescriptor,dateDescriptor]];
                        [finalArray addObjectsFromArray:[existingArray subarrayWithRange:NSMakeRange(0, MIN(5,existingArray.count))]];
                        
                        [existingArray removeObjectsInRange:NSMakeRange(0, MIN(5,existingArray.count))];
                        [existingArray addObjectsFromArray:imageArray];
                        [existingArray sortUsingDescriptors:@[dateDescriptor]];
                        [finalArray addObjectsFromArray:existingArray];
                        
                        NSArray *result = [finalArray subarrayWithRange:NSMakeRange(0, MIN(10, finalArray.count))];
                        [finalArray removeObjectsInRange:NSMakeRange(0, MIN(10, finalArray.count))];
                        for (NSDictionary *dict in finalArray) {
                            FIRStorageReference *storageRefdel = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@%@",kFAStoragePathKey,[dict objectForKey:kFAItemImagesPathKey]]];
                            // Delete the file
                            [storageRefdel deleteWithCompletion:^(NSError *error){
                                if (error) {
                                    NSLog(@"%@",error.localizedDescription);
                                }
                            }];
                        }
                        [item setObject:result forKey:kFAItemImagesKey];
                        
                        NSMutableArray *reviewArray = [item objectForKey:kFAItemReviewsKey];
                        if (reviewArray == nil) {
                            reviewArray = [NSMutableArray new];
                        }
                        [reviewArray addObject:@{kFAReviewTextKey:review}];
                        [item setObject:reviewArray forKey:kFAItemReviewsKey];
                        
                        NSInteger oldRting = [[item objectForKey:kFAItemRatingKey] integerValue];
                        NSInteger newRating = (oldRting + rating)/2;
                        [item setObject:[NSNumber numberWithInteger:newRating] forKey:kFAItemRatingKey];
                        
                        NSString * itemKey = [item objectForKey:kFAItemIdKey];
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
                    NSArray *imageArray = [NSArray arrayWithObjects:
                                           @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                             kFAItemImagesTimeStampKey:timeStamp,
                                             kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                             kFAItemImagesPathKey:snapshot.metadata.path},
                                           @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                             kFAItemImagesTimeStampKey:timeStamp,
                                             kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                             kFAItemImagesPathKey:snapshot2.metadata.path},nil];
                    
                    
                    
                    NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_vote" ascending:NO];
                    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_timeStamp" ascending:NO];
                    
                    NSMutableArray *finalArray = [NSMutableArray new];
                    NSMutableArray *existingArray = [item objectForKey:kFAItemImagesKey];
                    
                    [existingArray sortUsingDescriptors:@[voteDescriptor,dateDescriptor]];
                    [finalArray addObjectsFromArray:[existingArray subarrayWithRange:NSMakeRange(0, MIN(5,existingArray.count))]];
                    
                    [existingArray removeObjectsInRange:NSMakeRange(0, MIN(5,existingArray.count))];
                    [existingArray addObjectsFromArray:imageArray];
                    [existingArray sortUsingDescriptors:@[dateDescriptor]];
                    [finalArray addObjectsFromArray:existingArray];
                    
                    NSArray *result = [finalArray subarrayWithRange:NSMakeRange(0, MIN(10, finalArray.count))];
                    [finalArray removeObjectsInRange:NSMakeRange(0, MIN(10, finalArray.count))];
                    for (NSDictionary *dict in finalArray) {
                        FIRStorageReference *storageRefdel = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@%@",kFAStoragePathKey,[dict objectForKey:kFAItemImagesPathKey]]];
                        // Delete the file
                        [storageRefdel deleteWithCompletion:^(NSError *error){
                            if (error) {
                                NSLog(@"%@",error.localizedDescription);
                            }
                        }];
                    }
                    [item setObject:result forKey:kFAItemImagesKey];
                    
                    NSMutableArray *reviewArray = [item objectForKey:kFAItemReviewsKey];
                    if (reviewArray == nil) {
                        reviewArray = [NSMutableArray new];
                    }
                    [reviewArray addObject:@{kFAReviewTextKey:review}];
                    [item setObject:reviewArray forKey:kFAItemReviewsKey];
                    
                    NSInteger oldRting = [[item objectForKey:kFAItemRatingKey] integerValue];
                    NSInteger newRating = (oldRting + rating)/2;
                    [item setObject:[NSNumber numberWithInteger:newRating] forKey:kFAItemRatingKey];
                    
                    NSString * itemKey = [item objectForKey:kFAItemIdKey];
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
            NSArray *imageArray = [NSArray arrayWithObjects:
                                   @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                     kFAItemImagesTimeStampKey:timeStamp,
                                     kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                     kFAItemImagesPathKey:snapshot.metadata.path},nil];
            
            
            
            NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_vote" ascending:NO];
            NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"item_image_timeStamp" ascending:NO];
            
            NSMutableArray *finalArray = [NSMutableArray new];
            NSMutableArray *existingArray = [item objectForKey:kFAItemImagesKey];
            
            [existingArray sortUsingDescriptors:@[voteDescriptor,dateDescriptor]];
            [finalArray addObjectsFromArray:[existingArray subarrayWithRange:NSMakeRange(0, MIN(5,existingArray.count))]];
            
            [existingArray removeObjectsInRange:NSMakeRange(0, MIN(5,existingArray.count))];
            [existingArray addObjectsFromArray:imageArray];
            [existingArray sortUsingDescriptors:@[dateDescriptor]];
            [finalArray addObjectsFromArray:existingArray];
            
            NSArray *result = [finalArray subarrayWithRange:NSMakeRange(0, MIN(10, finalArray.count))];
            [finalArray removeObjectsInRange:NSMakeRange(0, MIN(10, finalArray.count))];
            for (NSDictionary *dict in finalArray) {
                FIRStorageReference *storageRefdel = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"%@%@",kFAStoragePathKey,[dict objectForKey:kFAItemImagesPathKey]]];
                // Delete the file
                [storageRefdel deleteWithCompletion:^(NSError *error){
                    if (error) {
                        NSLog(@"%@",error.localizedDescription);
                    }
                }];
            }
            [item setObject:result forKey:kFAItemImagesKey];
            
            NSMutableArray *reviewArray = [item objectForKey:kFAItemReviewsKey];
            if (reviewArray == nil) {
                reviewArray = [NSMutableArray new];
            }
            [reviewArray addObject:@{kFAReviewTextKey:review}];
            [item setObject:reviewArray forKey:kFAItemReviewsKey];
            
            NSInteger oldRting = [[item objectForKey:kFAItemRatingKey] integerValue];
            NSInteger newRating = (oldRting + rating)/2;
            [item setObject:[NSNumber numberWithInteger:newRating] forKey:kFAItemRatingKey];
            
            NSString * itemKey = [item objectForKey:kFAItemIdKey];
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
    
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [storageRef putData:UIImageJPEGRepresentation(images[0], 0.5) metadata:metadata];
    
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
            FIRStorageUploadTask *uploadTask2 = [storageRef2 putData:UIImageJPEGRepresentation(images[1], 0.5) metadata:metadata];
            
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
                    FIRStorageUploadTask *uploadTask3 = [storageRef3 putData:UIImageJPEGRepresentation(images[2], 0.5) metadata:metadata];
                    
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
                        NSArray *imageArray = [NSArray arrayWithObjects:
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot.metadata.path},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot2.metadata.path},
                                               @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],
                                                 kFAItemImagesTimeStampKey:timeStamp,
                                                 kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                                 kFAItemImagesPathKey:snapshot3.metadata.path},nil];
                        
                        NSString *itemName = [item objectForKey:kFAItemCappedNameKey];
                        
                        NSArray* words = [itemName componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString* trimmedString = [words componentsJoinedByString:@""];
                        
                        NSString *itemKey = [NSString stringWithFormat:@"%@%@",trimmedString,[[ref child:kFAItemPathKey] childByAutoId].key];
                        NSString *restKey = [restaurant objectForKey:kFARestaurantIdKey];
                        
                        [item setObject:restaurant forKey:kFAItemRestaurantKey];
                        [item setObject:imageArray forKey:kFAItemImagesKey];
                        [item setObject:itemKey forKey:kFAItemIdKey];
                        [item setObject:[restaurant objectForKey:kFARestaurantLatitudeKey] forKey:kFARestaurantLatitudeKey];
                        [item setObject:[restaurant objectForKey:kFARestaurantLongitudeKey] forKey:kFARestaurantLongitudeKey];
                        
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
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
                    NSArray *imageArray = [NSArray arrayWithObjects:
                                           @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                             kFAItemImagesTimeStampKey:timeStamp,
                                             kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                             kFAItemImagesPathKey:snapshot.metadata.path},
                                           @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                             kFAItemImagesTimeStampKey:timeStamp,
                                             kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                             kFAItemImagesPathKey:snapshot2.metadata.path},nil];
                    
                    NSString *itemName = [item objectForKey:kFAItemCappedNameKey];
                    
                    NSArray* words = [itemName componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSString* trimmedString = [words componentsJoinedByString:@""];
                    
                    NSString *itemKey = [NSString stringWithFormat:@"%@%@",trimmedString,[[ref child:kFAItemPathKey] childByAutoId].key];
                    NSString *restKey = [restaurant objectForKey:kFARestaurantIdKey];
                    
                    [item setObject:restaurant forKey:kFAItemRestaurantKey];
                    [item setObject:imageArray forKey:kFAItemImagesKey];
                    [item setObject:itemKey forKey:kFAItemIdKey];
                    [item setObject:[restaurant objectForKey:kFARestaurantLatitudeKey] forKey:kFARestaurantLatitudeKey];
                    [item setObject:[restaurant objectForKey:kFARestaurantLongitudeKey] forKey:kFARestaurantLongitudeKey];
                    
                    
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
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
            NSArray *imageArray = [NSArray arrayWithObjects:
                                   @{kFAItemImagesURLKey:[NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                     kFAItemImagesTimeStampKey:timeStamp,
                                     kFAItemImagesVoteKey:[NSNumber numberWithUnsignedLong:0],
                                     kFAItemImagesPathKey:snapshot.metadata.path},nil];
            
            NSString *itemName = [item objectForKey:kFAItemCappedNameKey];
            
            NSArray* words = [itemName componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* trimmedString = [words componentsJoinedByString:@""];
            
            NSString *itemKey = [NSString stringWithFormat:@"%@%@",trimmedString,[[ref child:kFAItemPathKey] childByAutoId].key];
            NSString *restKey = [restaurant objectForKey:kFARestaurantIdKey];
            
            [item setObject:restaurant forKey:kFAItemRestaurantKey];
            [item setObject:imageArray forKey:kFAItemImagesKey];
            [item setObject:itemKey forKey:kFAItemIdKey];
            [item setObject:[restaurant objectForKey:kFARestaurantLatitudeKey] forKey:kFARestaurantLatitudeKey];
            [item setObject:[restaurant objectForKey:kFARestaurantLongitudeKey] forKey:kFARestaurantLongitudeKey];
            
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
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
