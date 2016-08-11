//
//  NSMutableDictionary+FAItem.h
//  Fuudapp
//
//  Created by Abbin Varghese on 05/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FAItem)

@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *cappedName;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *geoHash;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *rating;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *reviewArray;
@property (nonatomic, strong) NSMutableDictionary *restaurant;



-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description rating:(NSNumber*)rating;

@end
