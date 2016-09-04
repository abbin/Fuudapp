//
//  FARestaurantPickerController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FAItemObject.h"

@interface FARestaurantPickerController : UIViewController

@property (strong, nonatomic) FAItemObject *itemObjectP;
@property (strong, nonatomic) NSArray *selectedImages;

@end
