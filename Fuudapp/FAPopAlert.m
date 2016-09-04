//
//  FAPopAlert.m
//  Fuudapp
//
//  Created by Abbin Varghese on 13/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAPopAlert.h"
#import "AppDelegate.h"
#import "FAConstants.h"
#import "FARemoteConfig.h"

@interface FAPopAlert()

@property (assign, nonatomic) int firstY;
@property (assign, nonatomic) int height;
@property (assign, nonatomic) int width;
@property (strong, nonatomic) UILabel *vibrantLabel;
@end

@implementation FAPopAlert

-(instancetype)initWithCustomFrame{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.height = 75;
    self.width = delegate.window.frame.size.width;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self = [self initWithEffect:blurEffect];
    if (self) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
        
        [self setFrame:CGRectMake(0, -self.height, self.width, self.height)];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:CGRectMake(0, 0, self.width, self.height)];
        
        UIView *bottonStrip = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/7, 6)];
        [bottonStrip setCenter:CGPointMake(self.center.x, self.frame.size.height-7)];
        [bottonStrip setBackgroundColor:[UIColor whiteColor]];
        [bottonStrip.layer setCornerRadius:3];
        [bottonStrip.layer setMasksToBounds:YES];

        [[vibrancyEffectView contentView] addSubview:bottonStrip];
        
        self.vibrantLabel = [[UILabel alloc] init];
        [self.vibrantLabel setText:@"Do not schedule an upload task."];
        [self.vibrantLabel setTextAlignment:NSTextAlignmentCenter];
        [self.vibrantLabel setNumberOfLines:1];
        [self.vibrantLabel setFont:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:15.0]];
        [self.vibrantLabel setFrame:CGRectMake(52, 20, self.frame.size.width-60, self.height-34)];
        [self.vibrantLabel setTextColor:[UIColor whiteColor]];
        [[self contentView] addSubview:self.vibrantLabel];
        [[self contentView] addSubview:vibrancyEffectView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 20, self.vibrantLabel.frame.size.height, self.vibrantLabel.frame.size.height)];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        [[self contentView] addSubview:imageView];
        
        [delegate.window addSubview:self];
    }
    return self;
}

-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstY = [[sender view] center].y;
    }
    
    if (translatedPoint.y<0) {
        translatedPoint = CGPointMake(self.center.x, _firstY+translatedPoint.y);
        [[sender view] setCenter:translatedPoint];
    }
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self].x);
        
        
        CGFloat finalX = translatedPoint.x + velocityX;
        CGFloat finalY = _firstY;// translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            if (finalX < 0) {
                //finalX = 0;
            } else if (finalX > 768) {
                //finalX = 768;
            }
            
            if (finalY < 0) {
                finalY = 0;
            } else if (finalY > 1024) {
                finalY = 1024;
            }
        } else {
            if (finalX < 0) {
                //finalX = 0;
            } else if (finalX > 1024) {
                //finalX = 768;
            }
            
            if (finalY < 0) {
                finalY = 0;
            } else if (finalY > 768) {
                finalY = 1024;
            }
        }
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [self setFrame:CGRectMake(0, -self.height, self.width, self.height)];
        [UIView commitAnimations];
        self.isShowing = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

-(void)showWithText:(NSString*)text{
    if (!self.isShowing) {
        self.isShowing = YES;
        self.vibrantLabel.text = text;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.frame = CGRectMake(0, 0, self.frame.size.width, self.height);
        } completion:^(BOOL finished) {
            [self performSelector:@selector(dismis) withObject:nil afterDelay:5];
        }];
    }
}

-(void)dismis{
    if (self.isShowing) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.frame = CGRectMake(0, -self.height, self.width, self.height);
        } completion:^(BOOL finished) {
            self.isShowing = NO;
        }];
    }
}

@end
