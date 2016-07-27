//
//  FAAddViewControllerOne.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAddViewControllerOne.h"
#import "FAAddOneCollectionViewCell.h"
#import "FAColor.h"
#import "FAAddViewControllerTwo.h"

@interface FAAddViewControllerOne ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate,UITextFieldDelegate,FAAddViewControllerTwoDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrain;
@property (weak, nonatomic) IBOutlet UILabel *priceSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *discriptionSectionHeader;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *priceContainerView;
@property (weak, nonatomic) IBOutlet UIView *nameContainerView;

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

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    if (self.nameTextField.text.length>0 && self.priceTextField.text.length>1) {
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAAddViewControllerThreeSegue" sender:self];
    }
    else{
        if (self.nameTextField.text.length == 0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.nameContainerView center].x - 2.0f, [self.nameContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.nameContainerView center].x + 2.0f, [self.nameContainerView center].y)]];
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
                                     CGPointMake([self.priceContainerView center].x - 2.0f, [self.priceContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.priceContainerView center].x + 2.0f, [self.priceContainerView center].y)]];
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = [self.imageArray objectAtIndex:indexPath.row];
    return CGSizeMake(collectionView.frame.size.height*image.size.width/image.size.height, collectionView.frame.size.height);
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField.text isEqualToString:@""]) {
        textField.text = [self currencySymbol];
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topConstrain.constant = -self.priceSectionHeader.frame.origin.y+104;
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text isEqualToString:[self currencySymbol]]) {
        textField.text = @"";
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topConstrain.constant = 20;
        [self.view layoutIfNeeded];
    } completion:nil];
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

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"type here"]) {
        textView.text = @"";
        textView.textColor = [UIColor darkTextColor];
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topConstrain.constant = -self.discriptionSectionHeader.frame.origin.y+104;
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"type here";
        textView.textColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topConstrain.constant = 20;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}

-(NSString*)currencySymbol{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAAddViewControllerTwoSegue"]) {
        FAAddViewControllerTwo *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

-(void)FAAddViewControllerTwo:(FAAddViewControllerTwo *)controller didFinishWithNewItem:(NSString *)itemName{
    self.nameTextField.text = itemName;
}


@end
