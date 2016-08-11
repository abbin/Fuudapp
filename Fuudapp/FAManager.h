//
//  FAManager.h
//  Fuudapp
//
//  Created by Abbin Varghese on 04/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAManager : NSObject

+(void)saveItem:(NSMutableDictionary*)item andRestaurant:(NSMutableDictionary*)restaurant withImages:(NSArray*)images;

+(void)saveReview:(NSString*)review rating:(NSInteger)rating forItem:(NSMutableDictionary*)item withImages:(NSArray*)images;

+(void)observeEventWithCompletion:(void (^)(NSMutableArray* items))completion;

@end
