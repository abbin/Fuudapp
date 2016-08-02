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
#import "FAMapViewController.h"
#import "FALocalityPickerController.h"
#import "TLTagsControl.h"
#import "FAWorkingDaysViewController.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface FAAddViewControllerThree ()<UITextFieldDelegate,FARestaurantPickerControllerDelegate,FAMapViewControllerDelegate,FALocalityPickerControllerDelegate,TLTagsControlDelegate,FAWorkingDaysViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *tillTExtField;
@property (weak, nonatomic) IBOutlet UITextField *restaurantNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *localityTextField;
@property (weak, nonatomic) IBOutlet UITextField *coordinatesTextField;
@property (weak, nonatomic) IBOutlet TLTagsControl *tagControl;

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
    
    self.tagControl.tapDelegate = self;
}

- (void)tillDatePickerDidSelectDate:(UIDatePicker*)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.tillTExtField.text = [outputFormatter stringFromDate:sender.date];
}

- (void)fromDatePickerDidSelectDate:(UIDatePicker*)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.fromTextField.text = [outputFormatter stringFromDate:sender.date];
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
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FARestaurantPickerControllerSegue" sender:self];
        return NO;
    }
    else if (textField.tag == 1){
        return YES;
    }
    else if (textField.tag == 2){
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FALocalityPickerControllerSegue" sender:self];
        return NO;
    }
    else if (textField.tag == 3){
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAMapViewControllerSegue" sender:self];
        return NO;
    }
    else if (textField.tag == 4){
        return YES;
    }
    else if (textField.tag == 5){
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAWorkingDaysViewControllerSegue" sender:self];
        return NO;
    }
    else{
        return YES;
    }
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithNewRestaurant:(NSString *)restaurantName{
    self.restaurantNameTextField.text = restaurantName;
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithRestaurant:(NSMutableDictionary *)restaurant{

}

-(void)FAMapViewController:(FAMapViewController *)controller didFinishWithLocation:(CLLocationCoordinate2D)location{
    self.coordinatesTextField.text = [NSString stringWithFormat:@"%f, %f",location.latitude,location.longitude];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FARestaurantPickerControllerSegue"]) {
        UINavigationController *nav = segue.destinationViewController;
        FARestaurantPickerController *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"FAMapViewControllerSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        FAMapViewController *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"FALocalityPickerControllerSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        FALocalityPickerController *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"FAWorkingDaysViewControllerSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        FAWorkingDaysViewController *vc = nav.viewControllers[0];
        vc.delegate = self;
    }
}

- (IBAction)didTabOnView:(id)sender {
    [self.view endEditing:YES];
}

-(void)FALocalityPickerController:(FALocalityPickerController *)controller didFinisheWithLocation:(NSString *)location{
    self.localityTextField.text = location;
}

-(void)tagsControlDidEndEditing:(TLTagsControl *)tagsControl{
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 212) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 124) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else if (IS_IPHONE_6){
        [self.scrollView setContentOffset:CGPointMake(0, 25) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setScrollEnabled:YES];
    }
}

-(void)FAWorkingDaysViewController:(FAWorkingDaysViewController *)controller didFinishWithDays:(NSMutableArray *)days{
    
}

-(void)tagsControlDidBeginEditing:(TLTagsControl *)tagsControl{
    if (IS_IPHONE_4_OR_LESS) {
        [self.scrollView setContentOffset:CGPointMake(0, 334) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_5){
        [self.scrollView setContentOffset:CGPointMake(0, 334) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else if (IS_IPHONE_6){
        [self.scrollView setContentOffset:CGPointMake(0, 242) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(0, 183) animated:YES];
        [self.scrollView setScrollEnabled:NO];
    }
}

@end
