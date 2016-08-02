//
//  FAMapViewController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 29/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@class FAMapViewController;
@protocol FAMapViewControllerDelegate <NSObject>

-(void)FAMapViewController:(FAMapViewController*)controller didFinishWithLocation:(CLLocationCoordinate2D)location;

@end

@interface FAMapViewController : UIViewController

@property id <FAMapViewControllerDelegate>delegate;

@end
