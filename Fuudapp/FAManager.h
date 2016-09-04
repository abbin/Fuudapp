//
//  FAManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 04/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAItemObject.h"

@interface FAManager : NSObject

+(void)savePItem:(FAItemObject*)item andRestaurant:(FARestaurantObject*)restaurant withImages:(NSArray*)images;

+(void)saveReviewP:(NSString*)review rating:(float)rating forItem:(FAItemObject*)item withImages:(NSArray*)images;

+(BOOL)isLocationSet;

+(void)observeEventWithCompletion:(void (^)(NSMutableArray *items))completion;

@end
