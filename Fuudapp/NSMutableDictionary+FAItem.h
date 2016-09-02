//
//  NSMutableDictionary+FAItem.h
//  Fuudapp
//
//  Created by Abbin Varghese on 05/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FAItem)

@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemCappedName;
@property (nonatomic, strong) NSString *itemCurrency;
@property (nonatomic, strong) NSString *itemCurrencySymbol;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *itemGeoHash;
@property (nonatomic, strong) NSString *itemUserID;
@property (nonatomic, strong) NSString *itemUserPhotoURL;
@property (nonatomic, strong) NSString *itemUserName;
@property (nonatomic, strong) NSString *itemDistance;
@property (nonatomic, strong) NSNumber *itemLatitude;
@property (nonatomic, strong) NSNumber *itemLongitude;
@property (nonatomic, strong) NSNumber *itemPrice;
@property (nonatomic, strong) NSNumber *itemRating;
@property (nonatomic, strong) NSAttributedString *itemOpenHours;

@property (nonatomic, strong) NSMutableArray *itemImageArray;
@property (nonatomic, strong) NSMutableArray *itemReviewArray;
@property (nonatomic, strong) NSMutableDictionary *itemRestaurant;

-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description;

@end
