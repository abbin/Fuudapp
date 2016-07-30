//
//  FAAddViewControllerThree.m
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAddViewControllerThree.h"
#import "FAColor.h"
#import "FARestaurantPickerController.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface FAAddViewControllerThree ()<UITextFieldDelegate,FARestaurantPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *tillTExtField;

@end

@implementation FAAddViewControllerThree

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
    
    UIDatePicker *tillDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [tillDatePicker setDatePickerMode:UIDatePickerModeTime];
    [tillDatePicker setBackgroundColor:[UIColor whiteColor]];
    [tillDatePicker addTarget:self action:@selector(tillDatePickerDidSelectDate:) forControlEvents:UIControlEventValueChanged];
    self.tillTExtField.inputView = tillDatePicker;
    
    UIDatePicker *fromDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [fromDatePicker setDatePickerMode:UIDatePickerModeTime];
    [fromDatePicker setBackgroundColor:[UIColor whiteColor]];
    [fromDatePicker addTarget:self action:@selector(fromDatePickerDidSelectDate:) forControlEvents:UIControlEventValueChanged];
    self.fromTextField.inputView = fromDatePicker;
}

- (void)tillDatePickerDidSelectDate:(id)sender {
    
}

- (void)fromDatePickerDidSelectDate:(id)sender {
    
}

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (IS_IPHONE_4_OR_LESS) {
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 83) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else if (textField.tag == 4){
            [self.scrollView setContentOffset:CGPointMake(0, 334) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else if (textField.tag == 6 || textField.tag == 7){
            [self.scrollView setContentOffset:CGPointMake(0, 429) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
    }
    else if (IS_IPHONE_5){
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 83) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else if (textField.tag == 4){
            [self.scrollView setContentOffset:CGPointMake(0, 334) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else if (textField.tag == 6 || textField.tag == 7){
            [self.scrollView setContentOffset:CGPointMake(0, 341) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
    }
    else if (IS_IPHONE_6){
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 83) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else {
            [self.scrollView setContentOffset:CGPointMake(0, 242) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
    }
    else{
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 83) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
        else {
            [self.scrollView setContentOffset:CGPointMake(0, 183) animated:YES];
            [self.scrollView setScrollEnabled:NO];
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (IS_IPHONE_4_OR_LESS) {
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
        else {
            [self.scrollView setContentOffset:CGPointMake(0, 212) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
    }
    else if (IS_IPHONE_5){
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake(0, 124) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
    }
    else if (IS_IPHONE_6){
        if (textField.tag == 1) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake(0, 25) animated:YES];
            [self.scrollView setScrollEnabled:YES];
        }
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 0) {
        [self performSegueWithIdentifier:@"FARestaurantPickerControllerSegue" sender:self];
        return NO;
    }
    else if (textField.tag == 1){
        return YES;
    }
    else if (textField.tag == 2){
        return NO;
    }
    else if (textField.tag == 3){
        [self performSegueWithIdentifier:@"FAMapViewControllerSegue" sender:self];
        return NO;
    }
    else if (textField.tag == 4){
        return YES;
    }
    else if (textField.tag == 5){
        return NO;
    }
    else{
        return YES;
    }
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithNewRestaurant:(NSString *)restaurantName{
    
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithRestaurant:(NSMutableDictionary *)restaurant{
    NSLog(@"%@",restaurant);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FARestaurantPickerControllerSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        FARestaurantPickerController *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
}

- (IBAction)didTabOnView:(id)sender {
    [self.view endEditing:YES];
}


@end
