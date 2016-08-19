//
//  NSMutableDictionary+FALocality.h
//  Fuudapp
//
//  Created by Abbin Varghese on 18/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FALocality)

@property (strong, nonatomic) NSString *localityName;
@property (strong, nonatomic) NSNumber *localityLatitude;
@property (strong, nonatomic) NSNumber *localityLongitude;

-(instancetype)initWithLocality:(NSDictionary*)locality;

@end
