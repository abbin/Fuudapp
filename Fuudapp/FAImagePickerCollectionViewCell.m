//
//  FAImagePickerCollectionViewCell.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAImagePickerCollectionViewCell.h"

@implementation FAImagePickerCollectionViewCell

-(void)selectCell:(BOOL)animated{
    if (animated) {
        // Create a basic animation changing the transform.scale value
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        // Set the initial and the final values
        [animation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [animation setToValue:[NSNumber numberWithFloat:0.95f]];
        [animation setAutoreverses:YES];
        // Set duration
        [animation setDuration:0.1f];
        
        // Set animation to be consistent on completion
        [animation setRemovedOnCompletion:YES];
        [animation setFillMode:kCAFillModeForwards];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        // Add animation to the view's layer
        [[self.cellImageView layer] addAnimation:animation forKey:@"scale"];
        [[self.selectView layer] addAnimation:animation forKey:@"scale2"];
        self.selectView.alpha = 0.7;
    }
    else{
        self.cellImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
        self.selectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
        self.selectView.alpha = 0.7;
    }
}

-(void)deSelectCell:(BOOL)animated{
    if (animated) {
        // Create a basic animation changing the transform.scale value
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        // Set the initial and the final values
        [animation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [animation setToValue:[NSNumber numberWithFloat:0.95f]];
        [animation setAutoreverses:YES];
        // Set duration
        [animation setDuration:0.1f];
        
        // Set animation to be consistent on completion
        [animation setRemovedOnCompletion:YES];
        [animation setFillMode:kCAFillModeForwards];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        // Add animation to the view's layer
        [[self.cellImageView layer] addAnimation:animation forKey:@"scale"];
        [[self.selectView layer] addAnimation:animation forKey:@"scale2"];
        self.selectView.alpha = 0.0;
    }
    else{
        self.cellImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        self.selectView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        self.selectView.alpha = 0.0;
    }
}

-(void)shakeCell{
    // Create a basic animation changing the transform.scale value
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // Set the initial and the final values
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.cellImageView center].x - 2.0f, [self.cellImageView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.cellImageView center].x + 2.0f, [self.cellImageView center].y)]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:3];
    // Set duration
    [animation setDuration:0.05];
    
    // Set animation to be consistent on completion
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    // Add animation to the view's layer
    [[self.cellImageView layer] addAnimation:animation forKey:@"position"];
}

@end
