//
//  FAPopAlert.h
//  Fuudapp
//
//  Created by Abbin Varghese on 13/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAPopAlert : UIVisualEffectView

-(instancetype)initWithCustomFrame;

-(void)showWithText:(NSString*)text;

@property (assign, nonatomic) BOOL isShowing;

@end
