//
//  FAUploadProgressController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 23/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAUploadProgressController.h"

@interface FAUploadProgressController ()

@end

@implementation FAUploadProgressController

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
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }];
}



@end
