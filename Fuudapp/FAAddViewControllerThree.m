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

@interface FAAddViewControllerThree ()<UITextFieldDelegate,FARestaurantPickerControllerDelegate>

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
}

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 0) {
        [self performSegueWithIdentifier:@"FARestaurantPickerControllerSegue" sender:self];
    }
    return NO;
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithNewRestaurant:(NSString *)restaurantName{
    
}

-(void)FARestaurantPickerController:(FARestaurantPickerController *)controller didFinishWithRestaurant:(NSMutableDictionary *)restaurant{
    NSLog(@"%@",restaurant);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nav = segue.destinationViewController;
    FARestaurantPickerController *vc = nav.viewControllers[0];
    vc.delegate = self;
}


@end
