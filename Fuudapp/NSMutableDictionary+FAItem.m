//
//  NSMutableDictionary+FAItem.m
//  Fuudapp
//
//  Created by Abbin Varghese on 05/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FAItem.h"
#import "FAConstants.h"

@implementation NSMutableDictionary (FAItem)

-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description rating:(NSNumber*)rating{
    self = [self init];
    if (self) {
        [self setObject:name forKey:kFAItemNameKey];
        [self setObject:price forKey:kFAItemPriceKey];
        [self setObject:currency forKey:kFAItemCurrencyKey];
        [self setObject:description forKey:kFAItemDescriptionKey];
        [self setObject:rating forKey:kFAItemRatingKey];
    }
    return self;
}

@end
