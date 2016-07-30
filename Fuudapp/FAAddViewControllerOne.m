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

@interface FAAddViewControllerOne ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UITextFieldDelegate,FAAddViewControllerTwoDelegate>

@property (weak, nonatomic) IBOutlet UILabel *priceSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *discriptionSectionHeader;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *priceContainerView;
@property (weak, nonatomic) IBOutlet UIView *nameContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAAddViewControllerTwoSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        FAAddViewControllerTwo *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
//    if (self.nameTextField.text.length>0 && self.priceTextField.text.length>1) {
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAAddViewControllerThreeSegue" sender:self];
//    }
//    else{
//        if (self.nameTextField.text.length == 0) {
//            // Create a basic animation changing the transform.scale value
//            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//            
//            // Set the initial and the final values
//            [animation setFromValue:[NSValue valueWithCGPoint:
//                                     CGPointMake([self.nameContainerView center].x - 2.0f, [self.nameContainerView center].y)]];
//            [animation setToValue:[NSValue valueWithCGPoint:
//                                   CGPointMake([self.nameContainerView center].x + 2.0f, [self.nameContainerView center].y)]];
//            [animation setAutoreverses:YES];
//            [animation setRepeatCount:3];
//            // Set duration
//            [animation setDuration:0.05];
//            
//            // Set animation to be consistent on completion
//            [animation setRemovedOnCompletion:YES];
//            [animation setFillMode:kCAFillModeForwards];
//            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//            // Add animation to the view's layer
//            [[self.nameContainerView layer] addAnimation:animation forKey:@"position"];
//        }
//        if (self.priceTextField.text.length <= 1) {
//            // Create a basic animation changing the transform.scale value
//            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//            
//            // Set the initial and the final values
//            [animation setFromValue:[NSValue valueWithCGPoint:
//                                     CGPointMake([self.priceContainerView center].x - 2.0f, [self.priceContainerView center].y)]];
//            [animation setToValue:[NSValue valueWithCGPoint:
//                                   CGPointMake([self.priceContainerView center].x + 2.0f, [self.priceContainerView center].y)]];
//            [animation setAutoreverses:YES];
//            [animation setRepeatCount:3];
//            // Set duration
//            [animation setDuration:0.05];
//            
//            // Set animation to be consistent on completion
//            [animation setRemovedOnCompletion:YES];
//            [animation setFillMode:kCAFillModeForwards];
//            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//            // Add animation to the view's layer
//            [[self.priceContainerView layer] addAnimation:animation forKey:@"position"];
//        }
//    }
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
    if ([textField.text isEqualToString:@""]) {
        textField.text = [self currencySymbol];
    }
    [self.scrollView setContentOffset:CGPointMake(0, self.priceSectionHeader.frame.origin.y-15) animated:YES];
    [self.scrollView setScrollEnabled:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text isEqualToString:[self currencySymbol]]) {
        textField.text = @"";
    }
    [self.scrollView setScrollEnabled:YES];
    if (self.scrollView.contentSize.height>self.view.frame.size.height-64) {
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
    else{
        CGPoint bottomOffset = CGPointMake(0, 0);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location == 0 && range.length == 1) {
        return NO;
    }
    else{
        return YES;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 0) {
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
    [self.scrollView setContentOffset:CGPointMake(0, self.discriptionSectionHeader.frame.origin.y-15) animated:YES];
    [self.scrollView setScrollEnabled:NO];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"type here";
        textView.textColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    [self.scrollView setScrollEnabled:YES];
    if (self.scrollView.contentSize.height>self.view.frame.size.height-64) {
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
    else{
        CGPoint bottomOffset = CGPointMake(0, 0);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
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
