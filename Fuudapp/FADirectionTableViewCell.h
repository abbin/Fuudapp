//
//  FADirectionTableViewCell.h
//  Fuudapp
//
//  Created by Abbin Varghese on 30/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FADirectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellRestaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *getdirectionButton;

@end
