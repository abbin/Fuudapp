//
//  FARestaurantPickerController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//


#import <UIKit/UIKit.h>

@class FARestaurantPickerController;
@protocol FARestaurantPickerControllerDelegate <NSObject>

-(void)FARestaurantPickerController:(FARestaurantPickerController*)controller didFinishWithRestaurant:(NSMutableDictionary*)restaurant;
-(void)FARestaurantPickerController:(FARestaurantPickerController*)controller didFinishWithNewRestaurant:(NSString*)restaurantName;

@end

@interface FARestaurantPickerController : UIViewController

@property id <FARestaurantPickerControllerDelegate> delegate;

@end
