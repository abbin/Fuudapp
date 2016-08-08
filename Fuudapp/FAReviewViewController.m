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

    [next setTintColor:[FAColor mainColor]];
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
    if (self.ratingView.value>0 && self.reviewTextView.text.length>0){
        [self.reviewTextView resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
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
