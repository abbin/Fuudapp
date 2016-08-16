//
//  FirstViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 25/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FirstViewController.h"
#import "FAManager.h"
#import "FAFirstViewTableViewCell.h"
#import "FAConstants.h"
#import "NSMutableDictionary+FAItem.h"
#import "NSMutableDictionary+FARestaurant.h"
#import <MapKit/MapKit.h>

@import FirebaseRemoteConfig;
@import FirebaseDatabase;

@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *itemsArray;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (strong, nonatomic)FIRDatabaseReference *ref;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [FAManager observeEventWithCompletion:^(NSArray *items){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSSortDescriptor *voteDescriptor = [NSSortDescriptor sortDescriptorWithKey:kFAItemRatingKey ascending:NO];
            self.itemsArray = [items sortedArrayUsingDescriptors:@[voteDescriptor]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.itemTableView reloadData];
            });
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"FAImagePickerControllerSegue" sender:self];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.itemsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *itemDict = [self.itemsArray objectAtIndex:indexPath.section];
    NSArray *imageArray = [itemDict objectForKey:kFAItemImagesKey];
    NSDictionary *imageDict = [imageArray objectAtIndex:0];
    NSString *imageUrl = [imageDict objectForKey:kFAItemImagesURLKey];
    
    FAFirstViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAFirstViewTableViewCell"];

    cell.cellImageUrl = imageUrl;
    cell.itemNameLavel.text = itemDict.nameString;
    cell.restaurantNameLabel.text = itemDict.restaurant.name;
    cell.addressLabel.text = itemDict.restaurant.address;
    [cell.ratingView setTitle:[NSString stringWithFormat:@"%@",itemDict.rating] forState:UIControlStateNormal];
    cell.distanceLabel.text = [self distanceBetweenstatLat:[itemDict.latitude doubleValue] lon:[itemDict.longitude doubleValue]];
    cell.priceLabel.text = [NSString stringWithFormat:@"%@:%@",itemDict.currency,itemDict.price];
    
    return cell;
}

-(NSString*)distanceBetweenstatLat:(double)lat lon:(double)lng{
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:9.976250 longitude:76.293778];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    if (distance>1000) {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:0];
        return [NSString stringWithFormat:@"%@ km",[formatter stringFromNumber:[NSNumber numberWithDouble:distance/1000]]];
    }
    else{
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:0];
        return [NSString stringWithFormat:@"%@ meters",[formatter stringFromNumber:[NSNumber numberWithDouble:distance]]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 165;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.5;
}

@end
