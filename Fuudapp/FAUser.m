//
//  FAUser.m
//  Fuudapp
//
//  Created by Abbin Varghese on 04/09/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation FAUser

@dynamic profilePhotoUrl;

+ (void)load {
    [self registerSubclass];
}

@end
