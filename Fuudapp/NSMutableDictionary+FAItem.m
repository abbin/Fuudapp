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

@dynamic name,cappedName,price,currency,descriptionText,rating,itemId,imageArray,restaurant,latitude,longitude,geoHash,reviewArray;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setName:(NSString *)name{
    [self setObject:name forKey:kFAItemNameKey];
    
    NSArray* words = [name componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* trimmedString = [words componentsJoinedByString:@""];
    [self setObject:[trimmedString lowercaseString] forKey:kFAItemCappedNameKey];
    
    NSString *idK = [NSString stringWithFormat:@"%@%@",trimmedString,[self uuid]];
    [self setObject:[idK lowercaseString] forKey:kFAItemIdKey];
}

-(void)setPrice:(NSNumber *)price{
    [self setObject:price forKey:kFAItemPriceKey];
}

-(void)setCurrency:(NSString *)currency{
    [self setObject:currency forKey:kFAItemCurrencyKey];
}

-(void)setDescriptionText:(NSString *)descriptionText{
    [self setObject:descriptionText forKey:kFAItemDescriptionKey];
}

-(void)setRating:(NSNumber *)rating{
    [self setObject:rating forKey:kFAItemRatingKey];
}

-(void)setImageArray:(NSMutableArray *)imageArray{
    [self setObject:imageArray forKey:kFAItemImagesKey];
}

-(void)setRestaurant:(NSMutableDictionary *)restaurant{
    [self setObject:restaurant forKey:kFAItemRestaurantKey];
}

-(void)setLatitude:(NSNumber *)latitude{
    [self setObject:latitude forKey:kFARestaurantLatitudeKey];
}

-(void)setLongitude:(NSNumber *)longitude{
    [self setObject:longitude forKey:kFARestaurantLongitudeKey];
}

-(void)setGeoHash:(NSString *)geoHash{
    [self setObject:geoHash forKey:kFARestaurantLGeoHashKey];
}

-(void)setReviewArray:(NSMutableArray *)reviewArray{
    [self setObject:reviewArray forKey:kFAItemReviewsKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)name{
    return [self objectForKey:kFAItemNameKey];
}

-(NSString *)cappedName{
    return [self objectForKey:kFAItemCappedNameKey];
}

-(NSNumber *)price{
    return [self objectForKey:kFAItemPriceKey];
}

-(NSString *)currency{
    return [self objectForKey:kFAItemCurrencyKey];
}

-(NSString *)descriptionText{
    return [self objectForKey:kFAItemDescriptionKey];
}

-(NSNumber *)rating{
    return [self objectForKey:kFAItemRatingKey];
}

-(NSString *)itemId{
    return [self objectForKey:kFAItemIdKey];
}

-(NSMutableArray *)imageArray{
    return [self objectForKey:kFAItemImagesKey];
}

-(NSMutableDictionary *)restaurant{
    return [self objectForKey:kFAItemRestaurantKey];
}

-(NSNumber *)latitude{
    return [self objectForKey:kFARestaurantLatitudeKey];
}

-(NSNumber *)longitude{
    return [self objectForKey:kFARestaurantLongitudeKey];
}

-(NSString *)geoHash{
    return [self objectForKey:kFARestaurantLGeoHashKey];
}

-(NSMutableArray *)reviewArray{
    return [self objectForKey:kFAItemReviewsKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init Methods -

-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description rating:(NSNumber*)rating{
    self = [self init];
    if (self) {
        self.name = name;
        self.price = price;
        self.currency = currency;
        self.descriptionText = description;
        self.rating = rating;
    }
    return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility Methods -

- (NSString *)uuid{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

@end
