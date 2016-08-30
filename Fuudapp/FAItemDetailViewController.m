//
//  FAItemDetailViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 19/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAItemDetailViewController.h"
#import "FAConstants.h"
#import "NSMutableDictionary+FAItem.m"
#import "NSMutableDictionary+FARestaurant.h"
#import "FAColor.h"
#import "FADetailedImageCollectionViewCell.h"
#import "NSMutableDictionary+FAImage.m"
#import "FAColor.h"
#import "FATableViewCell.h"
#import "FADirectionTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@import FirebaseRemoteConfig;

@interface FAItemDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusGradiantView;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UIView *tblHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UIImageView *userimageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation FAItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailTableView.estimatedRowHeight = 44.0;
    self.detailTableView.rowHeight = UITableViewAutomaticDimension;
    
    NSInteger headerHeight = self.view.frame.size.width *3/4 + 135;
    
    self.tblHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
    self.itemNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:20.0];
    self.restaurantNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    self.restaurantLocationLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    self.priceLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    self.ratingButton.titleLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    self.ratingButton.backgroundColor = [FAColor colorWithRating:self.itemObject.itemRating];
    self.ratingButton.layer.cornerRadius = 5;
    self.ratingButton.layer.masksToBounds = YES;
    self.userimageView.layer.cornerRadius = self.userimageView.frame.size.height/2;
    self.userimageView.layer.masksToBounds = YES;
    self.userNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:12.0];
    
    [self.ratingButton setTitle:[NSString stringWithFormat:@"%@",self.itemObject.itemRating] forState:UIControlStateNormal];
    self.itemNameLabel.text = self.itemObject.itemName;
    self.restaurantNameLabel.text = self.itemObject.itemRestaurant.restaurantName;
    self.restaurantLocationLabel.text = self.itemObject.itemRestaurant.restaurantAddress;
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@",self.itemObject.itemCurrencySymbol,self.itemObject.itemPrice];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.itemObject.itemUserPhotoURL]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.userimageView setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"background"]
                                       success:nil
                                       failure:nil];
    self.userNameLabel.text = self.itemObject.itemUserName;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.statusGradiantView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.statusGradiantView.layer insertSublayer:gradient atIndex:0];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FATableViewCell"];
        cell.cellTextLabel.attributedText = self.itemObject.itemOpenHours;
        return cell;
    }
    else if (indexPath.section == 1) {
        FATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FATableViewCell"];
        cell.cellTextLabel.text = self.itemObject.itemDescription;
        return cell;
    }
    else if (indexPath.section == 2){
        FADirectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FADirectionTableViewCell"];
        cell.cellRestaurantNameLabel.text = self.itemObject.itemRestaurant.restaurantName;;
        cell.cellAddressLabel.text = self.itemObject.itemRestaurant.restaurantAddress;
        cell.cellDistanceLabel.text = self.itemObject.itemDistance;
        return cell;
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.5;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemObject.itemImageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FADetailedImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FADetailedImageCollectionViewCell" forIndexPath:indexPath];
    NSMutableDictionary *imageDict = [self.itemObject.itemImageArray objectAtIndex:indexPath.row];
    cell.imageURL = imageDict.imageUrl;
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.frame.size;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
