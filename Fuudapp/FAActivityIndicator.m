//
//  FAActivityIndicator.m
//  Fuudapp
//
//  Created by Abbin Varghese on 12/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAActivityIndicator.h"
#import "AppDelegate.h"
#import "FAColor.h"

@interface FAActivityIndicator ()

@property (assign, nonatomic) BOOL shouldLoopAnimation;
@property (assign, nonatomic) BOOL stopTrigered;

@end

@implementation FAActivityIndicator

double height;
double width;
double yAxis;
double animationTime;

+ (instancetype)sharedIndicator {
    static FAActivityIndicator *sharedIndicator = nil;
    static dispatch_once_t onceToken;
    height = 2;
    yAxis = 64;
    animationTime = 0.5;
    width = [UIScreen mainScreen].bounds.size.width;
    dispatch_once(&onceToken, ^{
        sharedIndicator = [[self alloc] initWithFrame:CGRectMake(0, yAxis, 0, height)];
        sharedIndicator.layer.cornerRadius = height/2;
        sharedIndicator.layer.masksToBounds = YES;
        sharedIndicator.backgroundColor = [FAColor activityIndicatorColor];
    });
    return sharedIndicator;
}

-(void)startAnimatingWithView:(UIView*)view{
    if (!self.shouldLoopAnimation) {
        self.stopTrigered = NO;
        self.shouldLoopAnimation = YES;
        [view addSubview:self];
        [self loopAnimation];
    }
}

-(void)stopAnimating{
    self.stopTrigered = YES;
}

-(void)loopAnimation{
    [UIView animateWithDuration:animationTime delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, yAxis, width, height);
    } completion:nil];
    
    [UIView animateWithDuration:animationTime delay:animationTime + animationTime*0.9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(width, yAxis, 0, height);
    } completion:^(BOOL finished) {
        if (self.stopTrigered) {
            self.shouldLoopAnimation = NO;
        }
        if (self.shouldLoopAnimation) {
            self.frame = CGRectMake(0, yAxis, 0, height);
            [self loopAnimation];
        }
        else{
            self.frame = CGRectMake(0, yAxis, 0, height);
            [self removeFromSuperview];
        }
    }];
}

@end
