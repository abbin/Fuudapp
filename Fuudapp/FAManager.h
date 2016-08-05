//
//  FAManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 04/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAManager : NSObject

+(void)saveItemWithName:(NSString*)itemName price:(NSNumber*)itemPrice currency:(NSString*)itemCurrency description:(NSString*)itemDescription rating:(NSNumber*)itemRating images:(NSArray*)images restaurant:(NSMutableDictionary*)restaurant;

@end
