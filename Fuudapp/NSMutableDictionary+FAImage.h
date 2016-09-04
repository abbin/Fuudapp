//
//  NSMutableDictionary+FAImage.h
//  Fuudapp
//
//  Created by Abbin Varghese on 22/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface NSMutableDictionary (FAImage)

@property (nonatomic, strong) NSNumber *imageHeight;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSNumber *imageTimeStamp;
@property (nonatomic, strong) PFFile *imagefile;
@property (nonatomic, strong) NSNumber *imageVote;
@property (nonatomic, strong) NSNumber *imageWidth;

@end