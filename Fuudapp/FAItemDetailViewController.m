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
@property (weak, nonatomic) IBOutlet UIView *statusGradiantView;
@property (weak, nonatomic) IBOutlet UILabel *openLebal;

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
    
    [self.ratingButton setTitle:[NSString stringWithFormat:@"%@",self.itemObject.itemRating] forState:UIControlStateNormal];
    self.itemNameLabel.text = self.itemObject.itemName;
    self.itemRestaurant.text = self.itemObject.itemRestaurant.restaurantName;
    self.itemLocationLabel.text = self.itemObject.itemRestaurant.restaurantAddress;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *predicateString = [NSString stringWithFormat:@"close.dayName like '%@'",dayName];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:predicateString];
    NSArray *result = [self.itemObject.itemRestaurant.restaurantWorkingHours filteredArrayUsingPredicate:pred];
    
    if (result.count>0) {
        NSMutableDictionary *todayDict = [result firstObject];
        
        NSString *closeString = [[todayDict objectForKey:@"close"] objectForKey:@"time"];
        NSString *openString = [[todayDict objectForKey:@"open"] objectForKey:@"time"];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"HHmm"];
        
        NSDate *openDate = [outputFormatter dateFromString:openString];
        NSDate *closeDate = [outputFormatter dateFromString:closeString];
        
        [outputFormatter setDateFormat:@"h:mm a"];
        
        NSString *openingHour = [outputFormatter stringFromDate:openDate];
        NSString *closingHour = [outputFormatter stringFromDate:closeDate];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
                                              fromDate:[NSDate date]];
        NSInteger nowSeconds = ([comps hour] * 60 * 60) + ([comps minute] * 60) + [comps second];
        
        NSInteger closeSecond = [self dictTimeToSeconds:[closeString integerValue]];
        NSInteger openSecond = [self dictTimeToSeconds:[openString integerValue]];
        
        if (openSecond < nowSeconds && closeSecond > nowSeconds) {
            self.openLebal.text = [NSString stringWithFormat:@"Open Now from:%@ till:%@",openingHour,closingHour];
        } else {
            self.openLebal.text = [NSString stringWithFormat:@"Closed Now. Open from:%@ till:%@",openingHour,closingHour];
        }
    }
    else{
        self.openLebal.text = [NSString stringWithFormat:@"Closed Today"];
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.statusGradiantView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.statusGradiantView.layer insertSublayer:gradient atIndex:0];
}

- (NSInteger)dictTimeToSeconds:(NSInteger)dictTime{
    NSInteger hours = dictTime / 100;
    NSInteger minutes = dictTime % 100;
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
