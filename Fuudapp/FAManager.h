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

@end
