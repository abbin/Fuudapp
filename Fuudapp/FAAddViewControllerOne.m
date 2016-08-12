//
//  FAAddViewControllerOne.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAAddViewControllerOne.h"
#import "FAAddOneCollectionViewCell.h"
#import <HCSStarRatingView/HCSStarRatingView.h>
#import "FAConstants.h"
#import "FAAnalyticsManager.h"
#import "FARestaurantPickerController.h"
#import "NSMutableDictionary+FAItem.h"

@import FirebaseRemoteConfig;

@interface FAAddViewControllerOne ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *priceContainerView;
@property (weak, nonatomic) IBOutlet UIView *nameContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *imagePreviewSectionHeading;
@property (weak, nonatomic) IBOutlet UILabel *nameSectionHeading;
@property (weak, nonatomic) IBOutlet UILabel *priceSectionHeading;
@property (weak, nonatomic) IBOutlet UILabel *descriptionSectionHeading;

@end

@implementation FAAddViewControllerOne

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Next" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(nextButtonClicked:)];
    
    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(backButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.ratingView.tintColor = [FAColor mainColor];
    
    self.nameTextField.text = self.itemName;
    
    self.imagePreviewSectionHeading.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    self.nameSectionHeading.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    self.priceSectionHeading.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    self.descriptionSectionHeading.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    
        self.nameTextField.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:14];
            self.priceTextField.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:14];
            self.descriptionTextView.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:14];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FARestaurantPickerControllerSegue"]){
        FARestaurantPickerController *vc = segue.destinationViewController;
        
        NSString *newStr = [self.priceTextField.text substringFromIndex:1];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSNumber *price = [f numberFromString:newStr];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *localizedMoneyString = [formatter currencyCode];
        
        if ([self.descriptionTextView.text isEqualToString:@"type here"]) {
            self.descriptionTextView.text = @"";
        }
        
        vc.selectedImages = self.selectedImages;
        vc.itemObject = [[NSMutableDictionary alloc]initItemWithName:self.nameTextField.text price:price currency:localizedMoneyString description:self.descriptionTextView.text rating:[NSNumber numberWithFloat:self.ratingView.value]];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    if ([self.priceTextField isFirstResponder] || [self.descriptionTextView isFirstResponder]) {
        [self.view endEditing:YES];
        [self performSelector:@selector(nextButtonClicked:) withObject:nil afterDelay:0.3];
    }
    else{
        if (self.nameTextField.text.length>0 && self.priceTextField.text.length>1 && self.ratingView.value>0) {
            [self.view endEditing:YES];
            [self performSegueWithIdentifier:@"FARestaurantPickerControllerSegue" sender:self];
        }
        else{
            if (self.ratingView.value == 0) {
                [self.view endEditing:YES];
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
            if (self.nameTextField.text.length == 0) {
                // Create a basic animation changing the transform.scale value
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                
                // Set the initial and the final values
                [animation setFromValue:[NSValue valueWithCGPoint:
                                         CGPointMake([self.nameContainerView center].x - 3.0f, [self.nameContainerView center].y)]];
                [animation setToValue:[NSValue valueWithCGPoint:
                                       CGPointMake([self.nameContainerView center].x + 3.0f, [self.nameContainerView center].y)]];
                [animation setAutoreverses:YES];
                [animation setRepeatCount:3];
                // Set duration
                [animation setDuration:0.05];
                
                // Set animation to be consistent on completion
                [animation setRemovedOnCompletion:YES];
                [animation setFillMode:kCAFillModeForwards];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                // Add animation to the view's layer
                [[self.nameContainerView layer] addAnimation:animation forKey:@"position"];
            }
            if (self.priceTextField.text.length <= 1) {
                // Create a basic animation changing the transform.scale value
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                
                // Set the initial and the final values
                [animation setFromValue:[NSValue valueWithCGPoint:
                                         CGPointMake([self.priceContainerView center].x - 3.0f, [self.priceContainerView center].y)]];
                [animation setToValue:[NSValue valueWithCGPoint:
                                       CGPointMake([self.priceContainerView center].x + 3.0f, [self.priceContainerView center].y)]];
                [animation setAutoreverses:YES];
                [animation setRepeatCount:3];
                // Set duration
                [animation setDuration:0.05];
                
                // Set animation to be consistent on completion
                [animation setRemovedOnCompletion:YES];
                [animation setFillMode:kCAFillModeForwards];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                // Add animation to the view's layer
                [[self.priceContainerView layer] addAnimation:animation forKey:@"position"];
            }
        }

    }
}

- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource -

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectedImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FAAddOneCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FAAddOneCollectionViewCell" forIndexPath:indexPath];
    cell.cellImageView.image = self.selectedImages[indexPath.row];
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate -

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = [self.selectedImages objectAtIndex:indexPath.row];
    return CGSizeMake(collectionView.frame.size.height*image.size.width/image.size.height, collectionView.frame.size.height);
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate -

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = [self currencySymbol];
        }
    }
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 285) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 275) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_6){
        [self.scrollView setContentOffset:CGPointMake(0, 215) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 183) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        if ([textField.text isEqualToString:[self currencySymbol]]) {
            textField.text = @"";
        }
    }
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 110) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 57) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        if (range.location == 0 && range.length == 1) {
            return NO;
        }
        else{
            return YES;
        }
    }
    else{
        return YES;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 0) {
        return NO;
    }else{
        return YES;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate -

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"type here"]) {
        textView.text = @"";
        textView.textColor = [UIColor darkTextColor];
    }
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 369) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 311) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_6){
        [self.scrollView setContentOffset:CGPointMake(0, 257) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 230) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"type here";
        textView.textColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 110) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 57) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility methods -

-(NSString*)currencySymbol{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

@end
