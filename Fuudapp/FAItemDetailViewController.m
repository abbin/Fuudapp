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

@import FirebaseRemoteConfig;

@interface FAItemDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemRestaurant;
@property (weak, nonatomic) IBOutlet UILabel *itemLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UIView *statusGradiantView;
@property (weak, nonatomic) IBOutlet UILabel *openLebal;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation FAItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:20.0];
    self.itemRestaurant.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    self.itemLocationLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    [self.ratingButton.titleLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15.0]];
    [self.ratingButton setBackgroundColor:[FAColor mainColor]];
    self.ratingButton.layer.cornerRadius = 5;
    self.ratingButton.layer.masksToBounds = YES;
    self.openLebal.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    self.ratingButton.backgroundColor = [FAColor colorWithRating:self.itemObject.itemRating];
    self.priceLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:15.0];
    
    [self.ratingButton setTitle:[NSString stringWithFormat:@"%@",self.itemObject.itemRating] forState:UIControlStateNormal];
    self.itemNameLabel.text = self.itemObject.itemName;
    self.itemRestaurant.text = self.itemObject.itemRestaurant.restaurantName;
    self.itemLocationLabel.text = self.itemObject.itemRestaurant.restaurantAddress;
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@",self.itemObject.itemCurrencySymbol, self.itemObject.itemPrice];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *predicateString = [NSString stringWithFormat:@"close.dayName like '%@'",dayName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
    NSArray *result = [self.itemObject.itemRestaurant.restaurantWorkingHours filteredArrayUsingPredicate:pred];
    NSMutableDictionary *todayDict = [result firstObject];
    
    NSString *closeString = [[todayDict objectForKey:@"close"] objectForKey:@"time"];
    NSString *openString = [[todayDict objectForKey:@"open"] objectForKey:@"time"];
    
    [dateFormatter setDateFormat:@"HHmm"];
    NSString *nowString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDate *openDate = [dateFormatter dateFromString:openString];
    NSDate *closeDate = [dateFormatter dateFromString:closeString];
    
    [dateFormatter setDateFormat:@"h:mm a"];
    
    NSString *openingHour = [dateFormatter stringFromDate:openDate];
    NSString *closingHour = [dateFormatter stringFromDate:closeDate];
    
    NSInteger nowSecond = [self dictTimeToSeconds:nowString];
    NSInteger closeSecond = [self dictTimeToSeconds:closeString];
    NSInteger openSecond = [self dictTimeToSeconds:openString];
    
    if (openSecond-closeSecond<0){
        if (nowSecond>openSecond && nowSecond<closeSecond) {
            NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
            [atString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                             range:NSMakeRange(0, 8)];
            [atString addAttribute:NSForegroundColorAttributeName
                             value:[FAColor openGreen]
                             range:NSMakeRange(0, 8)];
            
            self.openLebal.attributedText = atString;
        }
        else{
            NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
            [atString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                             range:NSMakeRange(0, 10)];
            [atString addAttribute:NSForegroundColorAttributeName
                             value:[FAColor closedRed]
                             range:NSMakeRange(0, 10)];
            
            self.openLebal.attributedText = atString;
        }
    }
    else{
        NSInteger midnightSecond = 23*60*60 + 59*60 + 59;
        if (nowSecond>openSecond && nowSecond < midnightSecond) {
            NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
            [atString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                             range:NSMakeRange(0, 8)];
            [atString addAttribute:NSForegroundColorAttributeName
                             value:[FAColor openGreen]
                             range:NSMakeRange(0, 8)];
            
            self.openLebal.attributedText = atString;
        }
        else if (nowSecond >= 0 && nowSecond <closeSecond){
            NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Open Now  from:%@ till:%@",openingHour,closingHour]];
            [atString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                             range:NSMakeRange(0, 8)];
            [atString addAttribute:NSForegroundColorAttributeName
                             value:[FAColor openGreen]
                             range:NSMakeRange(0, 8)];
            
            self.openLebal.attributedText = atString;
        }
        else{
            NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Closed Now  Open from:%@ till:%@",openingHour,closingHour]];
            [atString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10.0]
                             range:NSMakeRange(0, 10)];
            [atString addAttribute:NSForegroundColorAttributeName
                             value:[FAColor closedRed]
                             range:NSMakeRange(0, 10)];
            
            self.openLebal.attributedText = atString;
        }
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.statusGradiantView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.statusGradiantView.layer insertSublayer:gradient atIndex:0];
}

- (NSInteger)dictTimeToSeconds:(id)dictTime{
    NSInteger time = [dictTime integerValue];
    NSInteger hours = time / 100;
    NSInteger minutes = time % 100;
    return (hours * 60 * 60) + (minutes * 60);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
