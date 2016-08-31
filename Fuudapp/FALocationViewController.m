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
#import "FAPopAlert.h"
#import "NSMutableDictionary+FALocality.h"
#import "FAManager.h"
#import "AppDelegate.h"
#import "FATabBarController.h"

@import CoreLocation;
@import FirebaseRemoteConfig;

@interface FALocationViewController ()<FALocalityPickerControllerDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *detectLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *manuallButton;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) FAPopAlert *alert;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (assign, nonatomic) BOOL firstUpdate;

@end

@implementation FALocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alert = [[FAPopAlert alloc]initWithCustomFrame];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
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
    if ([segue.identifier isEqualToString:@"FALocalityPickerControllerSegue"]) {
        UINavigationController *nv = segue.destinationViewController;
        FALocalityPickerController *vc = nv.viewControllers[0];
        vc.delegate = self;
    }
}

- (IBAction)detectMyLocation:(id)sender {
    self.view.userInteractionEnabled = NO;
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    /*
     Gets user permission to get their location while the app is in the foreground.
     
     To monitor the user's location even when the app is in the background:
     1. Replace [self.locationManager requestWhenInUseAuthorization] with [self.locationManager requestAlwaysAuthorization]
     2. Change NSLocationWhenInUseUsageDescription to NSLocationAlwaysUsageDescription in InfoPlist.strings
     */
    [self.locationManager requestWhenInUseAuthorization];
    
    /*
     Requests a single location after the user is presented with a consent dialog.
     */
    [self.locationManager startUpdatingLocation];
}

-(void)FALocalityPickerController:(FALocalityPickerController *)controller didFinisheWithLocation:(NSMutableDictionary *)location{
    if (location) {
        [[NSUserDefaults standardUserDefaults] setObject:location forKey:kFASelectedLocalityKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kFAObserveEventNotificationKey
         object:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    self.view.userInteractionEnabled = YES;
    [self.alert showWithText:@"Failed to get location"];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.view.userInteractionEnabled = YES;
    if (!self.firstUpdate) {
        [self.locationManager stopUpdatingLocation];
        CLLocation *currentLocation = locations[0];
        self.firstUpdate = YES;
        
        [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                self.placemark = [placemarks lastObject];
                NSDictionary *placemarkDict = self.placemark.addressDictionary;
                NSMutableDictionary *loc = [NSMutableDictionary new];
                loc.localityName = [placemarkDict objectForKey:@"City"];
                loc.localityLatitude = [NSNumber numberWithDouble:currentLocation.coordinate.latitude];
                loc.localityLongitude = [NSNumber numberWithDouble:currentLocation.coordinate.longitude];
                [[NSUserDefaults standardUserDefaults] setObject:loc forKey:kFASelectedLocalityKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kFAObserveEventNotificationKey
                 object:self];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                [self.alert showWithText:@"Failed to get location"];
            }
        } ];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [self performSegueWithIdentifier:@"FALocalityPickerControllerSegue" sender:self];
    }
}


@end
