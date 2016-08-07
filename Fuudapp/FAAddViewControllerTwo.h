//
//  FAAddViewControllerTwo.h
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAAddViewControllerTwo;

@protocol FAAddViewControllerTwoDelegate <NSObject>

-(void)FAAddViewControllerTwo:(FAAddViewControllerTwo*)controller didFinishWithNewItem:(NSString*)itemName;
-(void)FAAddViewControllerTwo:(FAAddViewControllerTwo*)controller didFinishWithItem:(NSString*)itemName;

@end

@interface FAAddViewControllerTwo : UIViewController

@property id <FAAddViewControllerTwoDelegate> delegate;

@end
