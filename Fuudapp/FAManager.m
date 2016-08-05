//
//  FAManager.m
//  Fuudapp
//
//  Created by Abbin Varghese on 04/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAManager.h"
#import "FAConstants.h"
#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>

@import FirebaseDatabase;
@import FirebaseStorage;
@import FirebaseAnalytics;

@implementation FAManager

+ (NSString *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

+(void)saveItem:(NSMutableDictionary*)item andRestaurant:(NSMutableDictionary*)restaurant withImages:(NSArray*)images{
    
    NSDate *start = [NSDate date];
    
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
            
            [Answers logCustomEventWithName:kFAAnalyticsFireBaseFailureKey
                           customAttributes:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsFireBaseFailureKey
                                parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
            
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
                    
                    [Answers logCustomEventWithName:kFAAnalyticsFireBaseFailureKey
                                   customAttributes:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
                    
                    [FIRAnalytics logEventWithName:kFAAnalyticsFireBaseFailureKey
                                        parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
                    
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
                        
                        [Answers logCustomEventWithName:kFAAnalyticsFireBaseFailureKey
                                       customAttributes:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
                        
                        [FIRAnalytics logEventWithName:kFAAnalyticsFireBaseFailureKey
                                            parameters:@{kFAAnalyticsReasonKey:snapshot.error.localizedDescription}];
                        
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
                        
                        NSDate *end = [NSDate date];
                        
                        [Answers logCustomEventWithName:kFAAnalyticsImageUploadCountKey
                                       customAttributes:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:3]}];
                        
                        [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadCountKey
                                            parameters:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:3]}];
                        
                        
                        
                        [Answers logCustomEventWithName:kFAAnalyticsImageUploadTimeKey
                                       customAttributes:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]/3]}];
                        
                        [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadTimeKey
                                            parameters:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]/3]}];
                        
                        
                        NSArray *imageArray = [NSArray arrayWithObjects:
                                               [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                               [NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                               [NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],nil];
                        
                        NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                        NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                        
                        [restaurant setObject:restKey forKey:kFARestaurantIdKey];
                        
                        if ([[restaurant objectForKey:kFAUserAddedRestaurantKey] boolValue]) {
                            [Answers logCustomEventWithName:kFAUserAddedRestaurantKey
                                           customAttributes:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                              kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
                            
                            [FIRAnalytics logEventWithName:kFAUserAddedRestaurantKey
                                                parameters:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                             kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
                        }
                        
                        [item setObject:restaurant forKey:kFAItemRestaurantKey];
                        [item setObject:imageArray forKey:kFAItemImagesKey];
                        [item setObject:itemKey forKey:kFAItemIdKey];
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
                                                       [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                        
                        [ref updateChildValues:childUpdates];
                        
                        NSLog(@"All Uploads Finished");
                    }];
                }
                else{
                    
                    NSDate *end = [NSDate date];
                    
                    [Answers logCustomEventWithName:kFAAnalyticsImageUploadCountKey
                                   customAttributes:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:2]}];
                    
                    [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadCountKey
                                        parameters:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:2]}];
                    
                    
                    [Answers logCustomEventWithName:kFAAnalyticsImageUploadTimeKey
                                   customAttributes:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]/2]}];
                    
                    [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadTimeKey
                                        parameters:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]/2]}];
                    
                    NSArray *imageArray = [NSArray arrayWithObjects:
                                           [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                           [NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],nil];
                    
                    NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                    NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                    
                    [restaurant setObject:restKey forKey:kFARestaurantIdKey];
                    
                    if ([[restaurant objectForKey:kFAUserAddedRestaurantKey] boolValue]) {
                        [Answers logCustomEventWithName:kFAUserAddedRestaurantKey
                                       customAttributes:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                          kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
                        
                        [FIRAnalytics logEventWithName:kFAUserAddedRestaurantKey
                                            parameters:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                         kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
                    }
                    
                    [item setObject:restaurant forKey:kFAItemRestaurantKey];
                    [item setObject:imageArray forKey:kFAItemImagesKey];
                    [item setObject:itemKey forKey:kFAItemIdKey];
                    
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
                                                   [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
                    
                    [ref updateChildValues:childUpdates];
                    
                    NSLog(@"All Uploads Finished");
                }
            }];
            
        }
        else{
            
            NSDate *end = [NSDate date];
            
            [Answers logCustomEventWithName:kFAAnalyticsImageUploadCountKey
                           customAttributes:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:1]}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadCountKey
                                parameters:@{kFAAnalyticsCountKey:[NSNumber numberWithInteger:1]}];
            
            
            [Answers logCustomEventWithName:kFAAnalyticsImageUploadTimeKey
                           customAttributes:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]]}];
            
            [FIRAnalytics logEventWithName:kFAAnalyticsImageUploadTimeKey
                                parameters:@{kFAAnalyticsTimeKey:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]]}];
            
            NSArray *imageArray = [NSArray arrayWithObjects:
                                   [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],nil];
            
            NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
            NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
            
            [restaurant setObject:restKey forKey:kFARestaurantIdKey];
            
            if ([[restaurant objectForKey:kFAUserAddedRestaurantKey] boolValue]) {
                [Answers logCustomEventWithName:kFAUserAddedRestaurantKey
                               customAttributes:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                  kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
                
                [FIRAnalytics logEventWithName:kFAUserAddedRestaurantKey
                                    parameters:@{kFARestaurantNameKey: [restaurant objectForKey:kFARestaurantNameKey],
                                                 kFARestaurantIdKey: [restaurant objectForKey:kFARestaurantIdKey]}];
            }
            
            [item setObject:restaurant forKey:kFAItemRestaurantKey];
            [item setObject:imageArray forKey:kFAItemImagesKey];
            [item setObject:itemKey forKey:kFAItemIdKey];
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@",kFAItemPathKey,itemKey]: item,
                                           [NSString stringWithFormat:@"/%@/%@/", kFARestaurantPathKey, restKey]: restaurant};
            
            [ref updateChildValues:childUpdates];
            
            NSLog(@"All Uploads Finished");
        }
    }];
}

@end
