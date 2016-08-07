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

+(void)saveItem:(NSMutableDictionary*)item andRestaurant:(NSMutableDictionary*)restaurant withImages:(NSArray*)images{
    
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
 
                        NSArray *imageArray = [NSArray arrayWithObjects:
                                               [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                               [NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],
                                               [NSString stringWithFormat:@"%@",snapshot3.metadata.downloadURL],nil];
                        
                        NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                        NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                        
                        [restaurant setObject:restKey forKey:kFARestaurantIdKey];
                        
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

                    NSArray *imageArray = [NSArray arrayWithObjects:
                                           [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],
                                           [NSString stringWithFormat:@"%@",snapshot2.metadata.downloadURL],nil];
                    
                    NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                    NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
                    
                    [restaurant setObject:restKey forKey:kFARestaurantIdKey];
                    
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
            
            NSArray *imageArray = [NSArray arrayWithObjects:
                                   [NSString stringWithFormat:@"%@",snapshot.metadata.downloadURL],nil];
            
            NSString *itemKey = [[ref child:kFAItemPathKey] childByAutoId].key;
            NSString *restKey = [[ref child:kFAItemPathKey] childByAutoId].key;
            
            [restaurant setObject:restKey forKey:kFARestaurantIdKey];
            
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
