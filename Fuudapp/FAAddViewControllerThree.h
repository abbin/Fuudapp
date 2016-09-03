//
//  FAAddViewControllerThree.h
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAItemObject.h"

@interface FAAddViewControllerThree : UIViewController

@property (strong, nonatomic) NSMutableDictionary *itemobject;
@property (strong, nonatomic) FAItemObject *itemobjectP;
@property (strong, nonatomic) NSArray *selectedImages;
@property (strong, nonatomic) NSString *restName;

@end
