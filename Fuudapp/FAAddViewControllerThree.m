//
//  FAAddViewControllerThree.m
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAConstants.h"
#import "TLTagsControl.h"
#import "FAMapViewController.h"
#import "FAAddViewControllerThree.h"
#import "FALocalityPickerController.h"
#import "FAWorkingDaysViewController.h"
#import "FARestaurantPickerController.h"
#import "FAManager.h"
#import "NSMutableDictionary+FAItem.h"
#import "NSMutableDictionary+FARestaurant.h"
#import "FAAnalyticsManager.h"

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
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *localityTextField;
@property (weak, nonatomic) IBOutlet UITextField *coordinatesTextField;
@property (weak, nonatomic) IBOutlet UITextField *restaurantNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *fromSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *tillSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *addressSectionHeading;
@property (weak, nonatomic) IBOutlet UILabel *localitySectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *coordinatesSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberSectionHeading;
@property (weak, nonatomic) IBOutlet UILabel *workingDaysSectionHeader;
@property (weak, nonatomic) IBOutlet UILabel *workingTimeSectionHeader;

@property (weak, nonatomic) IBOutlet UIView *addressContainerView;
@property (weak, nonatomic) IBOutlet UIView *localityContainerView;
@property (weak, nonatomic) IBOutlet UIView *coordinatesContainerView;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberContainerView;
@property (weak, nonatomic) IBOutlet UIView *workingDaysContainerView;
@property (weak, nonatomic) IBOutlet UIView *workingTillContainerView;
@property (weak, nonatomic) IBOutlet UIView *workingFromContainerView;
@property (weak, nonatomic) IBOutlet UIView *restaurantContainerView;

@property (weak, nonatomic) IBOutlet TLTagsControl *tagControl;
@property (weak, nonatomic) IBOutlet TLTagsControl *workingDayTagControl;

@property (strong, nonatomic) NSMutableArray *workingDaysArray;
@property (strong, nonatomic) NSString *fromTime;
@property (strong, nonatomic) NSString *tillTime;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;

@end

@implementation FAAddViewControllerThree

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressSectionHeading.alpha = 0;
    self.addressContainerView.alpha = 0;
    self.localitySectionHeader.alpha = 0;
    self.localityContainerView.alpha = 0;
    self.coordinatesSectionHeader.alpha = 0;
    self.coordinatesContainerView.alpha = 0;
    self.phoneNumberSectionHeading.alpha = 0;
    self.phoneNumberContainerView.alpha = 0;
    self.workingDaysSectionHeader.alpha = 0;
    self.workingDaysContainerView.alpha = 0;
    self.workingTimeSectionHeader.alpha = 0;
    self.fromSectionHeader.alpha = 0;
    self.tillSectionHeader.alpha = 0;
    self.workingFromContainerView.alpha = 0;
    self.workingTillContainerView.alpha = 0;
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Submit" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(submitButtonClicked:)];
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
    self.tagControl.tagPlaceholder = @"type here";
    self.workingDayTagControl.tapDelegate = self;
    self.workingDayTagControl.tagPlaceholder = @"tap here";
    [self.tagControl reloadTagSubviews];
    [self.workingDayTagControl reloadTagSubviews];
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



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)tillDatePickerDidSelectDate:(UIDatePicker*)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    self.tillTExtField.text = [outputFormatter stringFromDate:sender.date];
    
    [outputFormatter setDateFormat:@"HHmm"];
    
    self.tillTime = [outputFormatter stringFromDate:sender.date];
}

- (void)fromDatePickerDidSelectDate:(UIDatePicker*)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    self.fromTextField.text = [outputFormatter stringFromDate:sender.date];
    
    [outputFormatter setDateFormat:@"HHmm"];
    
    self.fromTime = [outputFormatter stringFromDate:sender.date];
}

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitButtonClicked:(id)sender {
    if (self.restaurantNameTextField.text.length>0 && self.addressTextField.text.length>0 && self.localityTextField.text.length>0 && self.lat>0 && self.lng>0) {
        if (self.workingDaysArray.count>0) {
            if (self.fromTime.length>0 && self.tillTime.length>0) {
                [self.view endEditing:YES];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    NSMutableDictionary *item = [[NSMutableDictionary alloc]initItemWithName:self.itemName price:self.itemPrice currency:self.itemcurrency description:self.itemdescription rating:self.itemRating];
                    NSMutableDictionary *rest = [[NSMutableDictionary alloc]initRestaurantWithName:self.restaurantNameTextField.text address:[NSString stringWithFormat:@"%@, %@",self.addressTextField.text,self.localityTextField.text] latitude:self.lat longitude:self.lng phonumber:self.tagControl.tags workingDays:self.workingDaysArray from:self.fromTime till:self.tillTime];
                    [FAManager saveItem:item andRestaurant:rest withImages:self.itemimages];
                }];
            }
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing time" message:@"Working hours are needed" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else{
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                NSMutableDictionary *item = [[NSMutableDictionary alloc]initItemWithName:self.itemName price:self.itemPrice currency:self.itemcurrency description:self.itemdescription rating:self.itemRating];
                NSMutableDictionary *rest = [[NSMutableDictionary alloc]initRestaurantWithName:self.restaurantNameTextField.text address:[NSString stringWithFormat:@"%@, %@",self.addressTextField.text,self.localityTextField.text] latitude:self.lat longitude:self.lng phonumber:self.tagControl.tags workingDays:self.workingDaysArray from:self.fromTime till:self.tillTime];
                [FAManager saveItem:item andRestaurant:rest withImages:self.itemimages];
            }];
        }
    }
    else{
        if (self.restaurantNameTextField.text.length==0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.restaurantContainerView center].x - 3.0f, [self.restaurantContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.restaurantContainerView center].x + 3.0f, [self.restaurantContainerView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.restaurantContainerView layer] addAnimation:animation forKey:@"position"];
        }
        if (self.addressTextField.text.length==0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.addressContainerView center].x - 3.0f, [self.addressContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.addressContainerView center].x + 3.0f, [self.addressContainerView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.addressContainerView layer] addAnimation:animation forKey:@"position"];
        }
        if (self.localityTextField.text.length==0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.localityContainerView center].x - 3.0f, [self.localityContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.localityContainerView center].x + 3.0f, [self.localityContainerView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.localityContainerView layer] addAnimation:animation forKey:@"position"];
        }
        if (self.coordinatesTextField.text.length==0) {
            // Create a basic animation changing the transform.scale value
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            
            // Set the initial and the final values
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.coordinatesContainerView center].x - 3.0f, [self.coordinatesContainerView center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.coordinatesContainerView center].x + 3.0f, [self.coordinatesContainerView center].y)]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:3];
            // Set duration
            [animation setDuration:0.05];
            
            // Set animation to be consistent on completion
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            // Add animation to the view's layer
            [[self.coordinatesContainerView layer] addAnimation:animation forKey:@"position"];
        }
    }
}

- (IBAction)didTabOnView:(id)sender {
    [self.view endEditing:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate -

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
    else{
        return YES;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FARestaurantPickerControllerDelegate -

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithNewRestaurant:(NSString *)restaurantName{
    
    self.restaurantNameTextField.text = restaurantName;
    [UIView animateWithDuration:0.5 animations:^{
        self.addressSectionHeading.alpha = 1;
        self.addressContainerView.alpha = 1;
        self.localitySectionHeader.alpha = 1;
        self.localityContainerView.alpha = 1;
        self.coordinatesSectionHeader.alpha = 1;
        self.coordinatesContainerView.alpha = 1;
        self.phoneNumberSectionHeading.alpha = 1;
        self.phoneNumberContainerView.alpha = 1;
        self.workingDaysSectionHeader.alpha = 1;
        self.workingDaysContainerView.alpha = 1;
        self.workingTimeSectionHeader.alpha = 1;
        self.fromSectionHeader.alpha = 1;
        self.tillSectionHeader.alpha = 1;
        self.workingFromContainerView.alpha = 1;
        self.workingTillContainerView.alpha = 1;
    }];
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithRestaurant:(NSMutableDictionary *)restaurant{
    self.restaurantNameTextField.text = [restaurant objectForKey:kFARestaurantNameKey];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSMutableDictionary *item = [[NSMutableDictionary alloc]initItemWithName:self.itemName price:self.itemPrice currency:self.itemcurrency description:self.itemdescription rating:self.itemRating];
        [FAManager saveItem:item andRestaurant:restaurant withImages:self.itemimages];
    }];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FALocalityPickerControllerDelegate -

-(void)FALocalityPickerController:(FALocalityPickerController *)controller didFinisheWithLocation:(NSString *)location{
    self.localityTextField.text = location;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FAMapViewControllerDelegate -

-(void)FAMapViewController:(FAMapViewController *)controller didFinishWithLocation:(CLLocationCoordinate2D)location{
    self.coordinatesTextField.text = [NSString stringWithFormat:@"%f, %f",location.latitude,location.longitude];
    self.lat = [NSNumber numberWithDouble:location.latitude];
    self.lng = [NSNumber numberWithDouble:location.longitude];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TLTagsControlDelegate -

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

-(BOOL)tagsControlShouldBeginEditing:(TLTagsControl *)tagsControl{
    if (tagsControl.tag == 0) {
        return YES;
    }
    else{
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"FAWorkingDaysViewControllerSegue" sender:self];
        return NO;
    }
}

-(void)tagsControl:(TLTagsControl *)tagsControl didDeleteTagAtIndex:(NSInteger)index{
    [self.workingDaysArray removeObjectAtIndex:index];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - FAWorkingDaysViewControllerDelegate -

-(void)FAWorkingDaysViewController:(FAWorkingDaysViewController *)controller didFinishWithDays:(NSMutableArray *)days{
    NSMutableArray *tags = [NSMutableArray new];
    for (NSDictionary *dict in days) {
        [tags addObject:[NSString stringWithFormat:@"%@",[[dict objectForKey:@"close"] objectForKey:@"dayName"]]];
    }
    self.workingDayTagControl.tags = tags;
    self.workingDayTagControl.tagPlaceholder = @"";
    [self.workingDayTagControl reloadTagSubviews];
    
    self.workingDaysArray = days;
}

@end
