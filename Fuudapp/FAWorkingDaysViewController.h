//
//  FAWorkingDaysViewController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 02/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAWorkingDaysViewController;

@protocol FAWorkingDaysViewControllerDelegate <NSObject>

-(void)FAWorkingDaysViewController:(FAWorkingDaysViewController*)controller didFinishWithDays:(NSMutableArray*)days;

@end
@interface FAWorkingDaysViewController : UIViewController

@property id <FAWorkingDaysViewControllerDelegate> delegate;

@end
