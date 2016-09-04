//
//  FAReviewViewController.h
//  Fuudapp
//
//  Created by Abbin Varghese on 08/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAItemObject.h"

@interface FAReviewViewController : UIViewController

@property (strong, nonatomic) NSArray *selectedImages;
@property (strong, nonatomic) FAItemObject *itemObject;

@end
