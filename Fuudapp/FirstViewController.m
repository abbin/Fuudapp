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
#import "FAColor.h"

@import FirebaseRemoteConfig;
@import FirebaseDatabase;
@import FirebaseAuth;

@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *itemsArray;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (strong, nonatomic)FIRDatabaseReference *ref;
@property (strong, nonatomic)NSIndexPath *selectedIndex;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) UIView *theHeaderView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.theHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(8, 10, self.view.frame.size.width-16, 2)];
    self.progressView.progressTintColor = [FAColor mainColor];
    [self.theHeaderView addSubview:self.self.progressView];
    self.theHeaderView.alpha = 0;
    
    UILabel *uploadLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 10)];
    uploadLabel.text = @"Uploading..";
    uploadLabel.textColor = [UIColor colorWithWhite:0 alpha:0.54];
    uploadLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    uploadLabel.textAlignment = NSTextAlignmentCenter;
    [self.theHeaderView addSubview:uploadLabel];

    if ([FAManager isLocationSet]) {
        [self addbarItems];
        [self startListining];
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startListining)
                                                     name:kFAObserveEventNotificationKey
                                                   object:nil];
    }
    
    self.view.backgroundColor = [FAColor mainColor];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FAItemDetailViewControllerSegue"]) {
        FAItemDetailViewController *vc = segue.destinationViewController;
        vc.itemObject = [self.itemsArray objectAtIndex:self.selectedIndex.section];
    }
}

-(void)startListining{
    [self addbarItems];
    [FAManager observeEventWithCompletion:^(NSMutableArray *items){
        self.itemsArray = items;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.itemTableView reloadData];
        });
    }];
}

-(void)addbarItems{
    NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults] objectForKey:kFASelectedLocalityKey];
    self.navBar.title = loc.localityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFASaveNotification:)
                                                 name:kFASaveNotificationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveProgressNotification:)
                                                 name:kFASaveProgressNotificationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveSaveCompleteNotification:)
                                                 name:kFASaveCompleteNotificationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFASaveFailNotification:)
                                                 name:kFASaveFailNotificationKey
                                               object:nil];
    
    if (![FIRAuth auth].currentUser.isAnonymous) {
        [self performSegueWithIdentifier:@"FAImagePickerControllerSegue" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"FASignInViewControllerSegue" sender:self];
    }
}

-(void)didReceiveFASaveFailNotification:(NSNotification *) notification{
    [self hideTableHeader];
}

-(void)didReceiveFASaveNotification:(NSNotification *) notification{
    [self showTableHeader];
}

-(void)hideTableHeader{
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.itemTableView.tableHeaderView = nil;
                         self.theHeaderView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.progressView.progress = 0;
                     }
     ];
}

-(void)showTableHeader{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.itemTableView.tableHeaderView = self.theHeaderView;
                         self.theHeaderView.alpha = 1;
                     }
                     completion:nil
     ];
}

-(void)didReceiveSaveCompleteNotification:(NSNotification *) notification{
    [self hideTableHeader];
}

-(void)didReceiveProgressNotification:(NSNotification *) notification{
    double progress = [[notification.userInfo objectForKey:@"progress"] doubleValue];
    double decimal = progress/100;
    [self.progressView setProgress:decimal animated:YES];
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
    if (itemDict.itemRating) {
        [cell.ratingView setTitle:[NSString stringWithFormat:@"%@",itemDict.itemRating] forState:UIControlStateNormal];
        cell.ratingView.backgroundColor = [FAColor colorWithRating:itemDict.itemRating];
    }
    else{
         [cell.ratingView setTitle:@"-" forState:UIControlStateNormal];
        cell.ratingView.backgroundColor = [FAColor blackColor];
    }
    cell.distanceLabel.text = itemDict.itemDistance;
    cell.priceLabel.text = [NSString stringWithFormat:@"%@%@",itemDict.itemCurrencySymbol,itemDict.itemPrice];
    cell.userNameLabel.text = itemDict.itemUserName;
    cell.cellUserImageUrl = itemDict.itemUserPhotoURL;
    
    return cell;
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
