//
//  FirstViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 25/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self
                                   action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"FAImagePickerControllerSegue" sender:self];
}

@end
