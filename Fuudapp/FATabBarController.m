//
//  FATabBarController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 10/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FATabBarController.h"
#import "FAManager.h"

@import FirebaseAuth;

@interface FATabBarController ()

@end

@implementation FATabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([FIRAuth auth].currentUser == nil) {
        [self performSegueWithIdentifier:@"FASignInViewControllerSegue" sender:self];
    }
    else if (![FAManager isLocationSet]){
        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
    }
}

@end
