//
//  FAReviewViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 08/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAReviewViewController.h"
#import "FAColor.h"
#import "FAConstants.h"
#import "FAAnalyticsManager.h"
#import "FAManager.h"

#import <HCSStarRatingView/HCSStarRatingView.h>

@interface FAReviewViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrain;
@property (weak, nonatomic) IBOutlet UILabel *reviewSectionHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reviewTextViewHeightConstrain;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;

@end

@implementation FAReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Submit" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(nextButtonClicked:)];

    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                             initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.ratingView.tintColor = [FAColor mainColor];
}

- (void)cancelButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender{
    if (self.ratingView.value>0 && ![self.reviewTextView.text isEqualToString:@"type here"] && self.reviewTextView.text.length>0){
        [self.reviewTextView resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            [FAManager saveReviewP:self.reviewTextView.text rating:self.ratingView.value forItem:self.itemObject withImages:self.selectedImages];
        }];
    }
    else{
        if (self.ratingView.value==0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.ratingView center].x - 3.0f, [self.ratingView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.ratingView center].x + 3.0f, [self.ratingView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.ratingView layer] addAnimation:animation forKey:@"position"];

        }
        if (self.reviewTextView.text.length==0 || [self.reviewTextView.text isEqualToString:@"type here"]){
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.reviewTextView center].x - 3.0f, [self.reviewTextView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.reviewTextView center].x + 3.0f, [self.reviewTextView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.reviewTextView layer] addAnimation:animation forKey:@"position"];

        }
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"type here"]) {
        textView.text = @"";
        textView.textColor = [UIColor darkTextColor];
    }
    if (IS_IPHONE_4_OR_LESS) {
        [UIView animateWithDuration:0.3 animations:^{
            self.topConstrain.constant = -72;
            self.reviewTextViewHeightConstrain.constant = -42;
            [self.view layoutIfNeeded];
        }];
    }
    else if (IS_IPHONE_5){
        [UIView animateWithDuration:0.3 animations:^{
            [UIView animateWithDuration:0.3 animations:^{
                self.topConstrain.constant = -72;
                [self.view layoutIfNeeded];
            }];
        }];
    }
    else if (IS_IPHONE_6){
        [UIView animateWithDuration:0.3 animations:^{
            [UIView animateWithDuration:0.3 animations:^{
                self.topConstrain.constant = 12;
                [self.view layoutIfNeeded];
            }];
        }];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"type here";
        textView.textColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    if (IS_IPHONE_4_OR_LESS) {
        [UIView animateWithDuration:0.3 animations:^{
            self.topConstrain.constant = 20;
            self.reviewTextViewHeightConstrain.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else if (IS_IPHONE_5){
        [UIView animateWithDuration:0.3 animations:^{
            [UIView animateWithDuration:0.3 animations:^{
                self.topConstrain.constant = 20;
                [self.view layoutIfNeeded];
            }];
        }];
    }
    else if (IS_IPHONE_6){
        [UIView animateWithDuration:0.3 animations:^{
            [UIView animateWithDuration:0.3 animations:^{
                self.topConstrain.constant = 20;
                [self.view layoutIfNeeded];
            }];
        }];
    }
}

- (IBAction)didTapOnView:(id)sender {
    [self.reviewTextView resignFirstResponder];
}

@end
