//
//  FAItemObject.h
//  Fuudapp
//
//  Created by Abbin Varghese on 03/09/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Parse/Parse.h>
#import "FARestaurantObject.h"

@interface FAItemObject : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemCappedName;
@property (nonatomic, strong) NSNumber *itemPrice;
@property (nonatomic, strong) NSNumber *itemRating;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, strong) PFUser *itemUser;
@property (nonatomic, strong) PFGeoPoint *itemLocation;
@property (nonatomic, strong) NSString *itemCurrency;
@property (nonatomic, strong) NSString *itemCurrencySymbol;

@property (nonatomic, strong) NSMutableArray *itemImageArray;
@property (nonatomic, strong) NSMutableArray *itemReviewArray;

@property (nonatomic, strong) FARestaurantObject *itemRestaurant;

@end
