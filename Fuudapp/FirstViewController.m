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
#import "NSMutableDictionary+FALocality.h"
#import <MapKit/MapKit.h>
#import "FAItemDetailViewController.h"

@import FirebaseRemoteConfig;
@import FirebaseDatabase;
@import FirebaseAuth;

@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *itemsArray;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (strong, nonatomic)FIRDatabaseReference *ref;
@property (strong, nonatomic)NSIndexPath *selectedIndex;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FAManager isLocationSet]) {
        [self addbarbuttons];
        [self startListining];
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startListining)
                                                     name:@"observeEventWithCompletion"
                                                   object:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FAItemDetailViewControllerSegue"]) {
        FAItemDetailViewController *vc = segue.destinationViewController;
        vc.itemObject = [self.itemsArray objectAtIndex:self.selectedIndex.section];
    }
}

-(void)startListining{
    [self addbarbuttons];
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

-(void)addbarbuttons{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addButtonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults] objectForKey:kFASelectedLocalityKey];
    self.navigationItem.title = loc.localityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButtonClicked:(id)sender {
    if (![FIRAuth auth].currentUser.isAnonymous) {
        [self performSegueWithIdentifier:@"FAImagePickerControllerSegue" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"FASignInViewControllerSegue" sender:self];
    }
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
    cell.itemNameLavel.text = itemDict.itemName;
    cell.restaurantNameLabel.text = itemDict.itemRestaurant.restaurantName;
    cell.addressLabel.text = itemDict.itemRestaurant.restaurantAddress;
    [cell.ratingView setTitle:[NSString stringWithFormat:@"%@",itemDict.itemRating] forState:UIControlStateNormal];
    cell.distanceLabel.text = [self distanceBetweenstatLat:[itemDict.itemLatitude doubleValue] lon:[itemDict.itemLongitude doubleValue]];
    cell.priceLabel.text = [NSString stringWithFormat:@"%@:%@",itemDict.itemCurrencySymbol,itemDict.itemPrice];
    cell.userNameLabel.text = itemDict.itemUserName;
    cell.cellUserImageUrl = itemDict.itemUserPhotoURL;
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath;
    [self performSegueWithIdentifier:@"FAItemDetailViewControllerSegue" sender:self];
}

@end
