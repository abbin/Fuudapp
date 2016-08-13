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
#import "FAConstants.h"

@import FirebaseRemoteConfig;

@interface FAActivityIndicator ()

@property (assign, nonatomic) BOOL shouldLoopAnimation;
@property (assign, nonatomic) BOOL stopTrigered;
@property (assign, nonatomic) double height;
@property (assign, nonatomic) double width;
@property (assign, nonatomic) double yAxis;
@property (assign, nonatomic) double animationTime;

@end

@implementation FAActivityIndicator

-(instancetype)initWithView:(UIView*)view{
    self.height = [[FIRRemoteConfig remoteConfig][kFARemoteConfigActivityIndicatorHeightKey].numberValue integerValue];
    self.yAxis = [[FIRRemoteConfig remoteConfig][kFARemoteConfigActivityIndicatorYAxixKey].numberValue integerValue];
    self.animationTime = 0.5;
    self.width = [UIScreen mainScreen].bounds.size.width;
    self = [self initWithFrame:CGRectMake(0, self.yAxis, 0, _height)];
    if (self) {
        self.layer.cornerRadius = self.height/2;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [FAColor activityIndicatorColor];
        [view addSubview:self];
    }
    return self;
}

-(void)startAnimating{
    if (!self.shouldLoopAnimation) {
        self.stopTrigered = NO;
        self.shouldLoopAnimation = YES;
        [self loopAnimation];
    }
}

-(void)stopAnimating{
    self.stopTrigered = YES;
}

-(void)loopAnimation{
    [UIView animateWithDuration:self.animationTime delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, self.yAxis, self.width, self.height);
    } completion:nil];
    
    [UIView animateWithDuration:self.animationTime delay:self.animationTime + self.animationTime*0.9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.width, self.yAxis, 0, self.height);
    } completion:^(BOOL finished) {
        if (self.stopTrigered) {
            self.shouldLoopAnimation = NO;
        }
        if (self.shouldLoopAnimation) {
            self.frame = CGRectMake(0, self.yAxis, 0, self.height);
            [self loopAnimation];
        }
        else{
            self.frame = CGRectMake(0, self.yAxis, 0, self.height);
        }
    }];
}

@end
