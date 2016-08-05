//
//  FAAddViewControllerOne.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAAddViewControllerOne.h"
#import "FAAddViewControllerTwo.h"
#import "FAAddOneCollectionViewCell.h"
#import "FAAddViewControllerThree.h"
#import <HCSStarRatingView/HCSStarRatingView.h>

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface FAAddViewControllerOne ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UITextFieldDelegate,FAAddViewControllerTwoDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *priceContainerView;
@property (weak, nonatomic) IBOutlet UIView *nameContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation FAAddViewControllerOne

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Next" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(nextButtonClicked:)];
    [next setTintColor:[FAColor mainColor]];
    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(backButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.ratingView.tintColor = [FAColor mainColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAAddViewControllerTwoSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        FAAddViewControllerTwo *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"FAAddViewControllerThreeSegue"]){
        FAAddViewControllerThree *vc = segue.destinationViewController;
        vc.itemName = self.nameTextField.text;
        
        NSString *newStr = [self.priceTextField.text substringFromIndex:1];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSNumber *myNumber = [f numberFromString:newStr];
        
        vc.itemPrice = myNumber;
        if ([self.descriptionTextView.text isEqualToString:@"type here"]) {
            vc.itemdescription = @"";
        }
        else{
            vc.itemdescription = self.descriptionTextView.text;
        }
        vc.itemRating = [NSNumber numberWithFloat:self.ratingView.value];
        vc.itemimages = self.imageArray;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        NSString *localizedMoneyString = [formatter currencyCode];
        vc.itemcurrency = localizedMoneyString;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    if (self.nameTextField.text.length>0 && self.priceTextField.text.length>1 && self.ratingView.value>0) {
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAAddViewControllerThreeSegue" sender:self];
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

- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource -

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FAAddOneCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FAAddOneCollectionViewCell" forIndexPath:indexPath];
    cell.cellImageView.image = self.imageArray[indexPath.row];
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate -

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = [self.imageArray objectAtIndex:indexPath.row];
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
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAAddViewControllerTwoSegue" sender:self];
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
#pragma mark - FAAddViewControllerTwoDelegate -

-(void)FAAddViewControllerTwo:(FAAddViewControllerTwo *)controller didFinishWithNewItem:(NSString *)itemName{
    self.nameTextField.text = itemName;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility methods -

-(NSString*)currencySymbol{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

@end
