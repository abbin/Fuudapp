//
//  NSMutableDictionary+FAItem.h
//  Fuudapp
//
//  Created by Abbin Varghese on 05/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FAItem)

-(instancetype)initItemWithName:(NSString*)name price:(NSNumber*)price currency:(NSString*)currency description:(NSString*)description rating:(NSNumber*)rating;

@end
