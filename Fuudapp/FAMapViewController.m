//
//  FAMapViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 29/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAMapViewController.h"
#import "FAColor.h"
#import "FAConstants.h"
#import "NSMutableDictionary+FALocality.h"

@interface FAMapViewController ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *currLoc;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation FAMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(doneButtonClicked:)];

    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
        }
        
        [self.locationManager startUpdatingLocation];
    }else{
        NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults]objectForKey:kFASelectedLocalityKey];
        
        double lat = [loc.localityLatitude doubleValue];
        double lng = [loc.localityLongitude doubleValue];
        
        self.currLoc = [[CLLocation alloc]initWithLatitude:lat longitude:lng];
        
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:15]];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action -

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

- (IBAction)goTocurrentLocation:(UIButton *)sender {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.currLoc.coordinate.latitude
                                                                      longitude:self.currLoc.coordinate.longitude
                                                                           zoom:15]];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate -

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

@end
