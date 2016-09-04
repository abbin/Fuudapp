//
//  FAUser.h
//  Fuudapp
//
//  Created by Abbin Varghese on 04/09/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <Parse/Parse.h>

@interface FAUser : PFUser

@property (nonatomic, strong) NSString *profilePhotoUrl;

@end
