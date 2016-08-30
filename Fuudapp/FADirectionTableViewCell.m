//
//  FADirectionTableViewCell.m
//  Fuudapp
//
//  Created by Abbin Varghese on 30/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FADirectionTableViewCell.h"
#import "FAConstants.h"
#import "FAColor.h"

@import FirebaseRemoteConfig;

@implementation FADirectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cellRestaurantNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    self.cellAddressLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    self.cellDistanceLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10.0];
    [self.getdirectionButton.titleLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15.0]];
    [self.getdirectionButton setTitleColor:[FAColor mainColor] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
