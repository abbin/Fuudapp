//
//  FATableViewCell.m
//  Fuudapp
//
//  Created by Abbin Varghese on 30/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FATableViewCell.h"
#import "FAConstants.h"
#import "FARemoteConfig.h"

@implementation FATableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cellTextLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
