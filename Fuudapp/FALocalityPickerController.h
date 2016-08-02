//
//  FALocalityPickerController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 01/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FALocalityPickerController;
@protocol FALocalityPickerControllerDelegate <NSObject>

-(void)FALocalityPickerController:(FALocalityPickerController*)controller didFinisheWithLocation:(NSString*)location;

@end

@interface FALocalityPickerController : UIViewController

@property id <FALocalityPickerControllerDelegate> delegate;

@end
