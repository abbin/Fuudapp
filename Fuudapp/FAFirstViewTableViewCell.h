//
//  FAFirstViewTableViewCell.h
//  Fuudapp
//
//  Created by Abbin Varghese on 13/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HCSStarRatingView/HCSStarRatingView.h>

@interface FAFirstViewTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *cellImageUrl;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLavel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
