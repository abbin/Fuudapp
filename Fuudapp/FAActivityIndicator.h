//
//  FAActivityIndicator.h
//  Fuudapp
//
//  Created by Abbin Varghese on 12/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAActivityIndicator : UIView

+ (instancetype)sharedIndicator;

-(void)startAnimatingWithView:(UIView*)view;
-(void)stopAnimating;

@end
