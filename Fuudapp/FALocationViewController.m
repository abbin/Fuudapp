//
//  FALocationViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 18/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FALocationViewController.h"
#import "FAConstants.h"
#import "FALocalityPickerController.h"

@import FirebaseRemoteConfig;

@interface FALocationViewController ()<FALocalityPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *detectLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *manuallButton;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@end

@implementation FALocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary * linkAttributes = @{NSFontAttributeName:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.manuallButton.titleLabel.text attributes:linkAttributes];
    [self.manuallButton.titleLabel setAttributedText:attributedString];
    [self.detectLocationButton.titleLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15]];
    [self.headingLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:20]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FALocationViewControllerSegue"]) {
        UINavigationController *nv = segue.destinationViewController;
        FALocalityPickerController *vc = nv.viewControllers[0];
        vc.delegate = self;
    }
}

-(void)FALocalityPickerController:(FALocalityPickerController *)controller didFinisheWithLocation:(NSMutableDictionary *)location{
    if (location) {
        [[NSUserDefaults standardUserDefaults] setObject:location forKey:kFAUserLocalityKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}


@end
