//
//  FAMapViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 29/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAMapViewController.h"
#import "FAColor.h"

@interface FAMapViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) CLLocation *currLoc;
@end

@implementation FAMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(doneButtonClicked:)];
    [next setTintColor:[FAColor mainColor]];
    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    [self requestLocationServicesAuthorization];
}

- (void)requestLocationServicesAuthorization {
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

- (void)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(FAMapViewController:didFinishWithLocation:)]) {
            [self.delegate FAMapViewController:self didFinishWithLocation:self.mapView.camera.target];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currLoc = [locations firstObject];
    [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:self.currLoc.coordinate.latitude
                                                        longitude:self.currLoc.coordinate.longitude
                                                             zoom:15]];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

}

- (IBAction)goTocurrentLocation:(UIButton *)sender {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.currLoc.coordinate.latitude
                                                                      longitude:self.currLoc.coordinate.longitude
                                                                           zoom:15]];
}

@end
