//
//  NSMutableDictionary+FAItem.m
//  Fuudapp
//
//  Created by Abbin Varghese on 05/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FAItem.h"
#import "FAConstants.h"

@import FirebaseAuth;

@implementation NSMutableDictionary (FAItem)

@dynamic itemName,itemCappedName,itemPrice,itemCurrency,itemDescription,itemRating,itemId,itemImageArray,itemRestaurant,itemLatitude,itemLongitude,itemGeoHash,itemReviewArray,itemCurrencySymbol, itemUserID,itemUserName,itemUserPhotoURL,itemDistance,itemOpenHours;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setItemPrice:(NSNumber *)itemPrice{
    [self setObject:itemPrice forKey:kFAItemPriceKey];
}

-(void)setItemCappedName:(NSString *)itemCappedName{
    [self setObject:itemCappedName forKey:kFAItemCappedNameKey];
}

-(void)setItemId:(NSString *)itemId{
    [self setObject:itemId forKey:kFAItemIdKey];
}

-(void)setItemName:(NSString *)itemName{
    [self setObject:itemName forKey:kFAItemNameKey];
}

-(void)setItemCurrency:(NSString *)itemCurrency{
    [self setObject:itemCurrency forKey:kFAItemCurrencyKey];
}

-(void)setItemCurrencySymbol:(NSString *)itemCurrencySymbol{
    [self setObject:itemCurrencySymbol forKey:kFAItemCurrencySymbolKey];
}

-(void)setItemDescription:(NSString *)itemDescription{
    [self setObject:itemDescription forKey:kFAItemDescriptionKey];
}

-(void)setItemRating:(NSNumber *)itemRating{
    [self setObject:itemRating forKey:kFAItemRatingKey];
}

-(void)setItemImageArray:(NSMutableArray *)itemImageArray{
    [self setObject:itemImageArray forKey:kFAItemImagesKey];
}

-(void)setItemRestaurant:(NSMutableDictionary *)itemRestaurant{
    [self setObject:itemRestaurant forKey:kFAItemRestaurantKey];
}

-(void)setItemLatitude:(NSNumber *)itemLatitude{
    [self setObject:itemLatitude forKey:kFARestaurantLatitudeKey];
}

-(void)setItemLongitude:(NSNumber *)itemLongitude{
    [self setObject:itemLongitude forKey:kFARestaurantLongitudeKey];
}

-(void)setItemGeoHash:(NSString *)itemGeoHash{
    [self setObject:itemGeoHash forKey:kFARestaurantLGeoHashKey];
}

-(void)setItemReviewArray:(NSMutableArray *)itemReviewArray{
    [self setObject:itemReviewArray forKey:kFAItemReviewsKey];
}

-(void)setItemUserID:(NSString *)itemUserID{
    [self setObject:itemUserID forKey:kFAItemUserIDKey];
}

-(void)setItemUserName:(NSString *)itemUserName{
    [self setObject:itemUserName forKey:kFAItemUserNameKey];
}

-(void)setItemUserPhotoURL:(NSString *)itemUserPhotoURL{
    [self setObject:itemUserPhotoURL forKey:kFAItemUserPhotoURLKey];
}

-(void)setItemDistance:(NSString *)itemDistance{
    [self setObject:itemDistance forKey:kFAItemDistanceKey];
}

-(void)setItemOpenHours:(NSAttributedString *)itemOpenHours{
    [self setObject:itemOpenHours forKey:kFAItemOpenHoursKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSString *)itemName{
    return [self objectForKey:kFAItemNameKey];
}

-(NSString *)itemCappedName{
    return [self objectForKey:kFAItemCappedNameKey];
}

-(NSNumber *)itemPrice{
    return [self objectForKey:kFAItemPriceKey];
}

-(NSString *)itemCurrency{
    return [self objectForKey:kFAItemCurrencyKey];
}

-(NSString *)itemCurrencySymbol{
    return [self objectForKey:kFAItemCurrencySymbolKey];
}

-(NSString *)itemDescription{
    return [self objectForKey:kFAItemDescriptionKey];
}

-(NSNumber *)itemRating{
    return [self objectForKey:kFAItemRatingKey];
}

-(NSString *)itemId{
    return [self objectForKey:kFAItemIdKey];
}

-(NSMutableArray *)itemImageArray{
    return [self objectForKey:kFAItemImagesKey];
}

-(NSMutableDictionary *)itemRestaurant{
    return [self objectForKey:kFAItemRestaurantKey];
}

-(NSNumber *)itemLatitude{
    return [self objectForKey:kFARestaurantLatitudeKey];
}

-(NSNumber *)itemLongitude{
    return [self objectForKey:kFARestaurantLongitudeKey];
}

-(NSString *)itemGeoHash{
    return [self objectForKey:kFARestaurantLGeoHashKey];
}

-(NSMutableArray *)itemReviewArray{
    return [self objectForKey:kFAItemReviewsKey];
}

-(NSString *)itemUserName{
    return [self objectForKey:kFAItemUserNameKey];
}

-(NSString *)itemUserID{
    return [self objectForKey:kFAItemUserIDKey];
}

-(NSString *)itemUserPhotoURL{
    return [self objectForKey:kFAItemUserPhotoURLKey];
}

-(NSString *)itemDistance{
    return [self objectForKey:kFAItemDistanceKey];
}

-(NSAttributedString *)itemOpenHours{
    return [self objectForKey:kFAItemOpenHoursKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init Methods -

-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description{
    self = [self init];
    if (self) {
        self.itemName = name;
        self.itemPrice = price;
        self.itemCurrency = currency;
        self.itemDescription = description;
        self.itemCurrencySymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
        id<FIRUserInfo> profile = [FIRAuth auth].currentUser.providerData[0];
        self.itemUserName = profile.displayName;
        self.itemUserPhotoURL = [NSString stringWithFormat:@"%@",profile.photoURL];
        self.itemUserID = [FIRAuth auth].currentUser.uid;
        
        NSArray* words = [name componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* trimmedString = [words componentsJoinedByString:@""];
        NSString *idK = [NSString stringWithFormat:@"%@%@",trimmedString,[self uuid]];
        
        self.itemId = [idK lowercaseString];
        self.itemCappedName = [trimmedString lowercaseString];
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
