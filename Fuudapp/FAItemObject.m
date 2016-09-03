//
//  FAItemObject.m
//  Fuudapp
//
//  Created by Abbin Varghese on 03/09/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAItemObject.h"
#import <Parse/PFObject+Subclass.h>
#import "FAConstants.h"

@implementation FAItemObject

@dynamic itemName;
@dynamic itemPrice;
@dynamic itemRating;
@dynamic itemUser;
@dynamic itemLocation;
@dynamic itemDescription;
@dynamic itemCurrency;
@dynamic itemCurrencySymbol;
@dynamic itemImageArray;
@dynamic itemReviewArray;
@dynamic itemRestaurant;
@dynamic itemCappedName;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kFAItemPathKey;
}

@end
