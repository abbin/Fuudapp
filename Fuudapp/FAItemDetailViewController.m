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

@import FirebaseRemoteConfig;

@interface FAItemDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemRestaurant;
@property (weak, nonatomic) IBOutlet UILabel *itemLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;

@end

@implementation FAItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.itemNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:20.0];
    self.itemRestaurant.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    self.itemLocationLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    [self.ratingButton.titleLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15.0]];
    [self.ratingButton setBackgroundColor:[FAColor mainColor]];
    self.ratingButton.layer.cornerRadius = 5;
    self.ratingButton.layer.masksToBounds = YES;
    
    [self.ratingButton setTitle:[NSString stringWithFormat:@"%@",self.itemObject.itemRating] forState:UIControlStateNormal];
    self.itemNameLabel.text = self.itemObject.itemName;
    self.itemRestaurant.text = self.itemObject.itemRestaurant.restaurantName;
    self.itemLocationLabel.text = self.itemObject.itemRestaurant.restaurantAddress;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
