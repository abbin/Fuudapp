//
//  FAFirstViewTableViewCell.m
//  Fuudapp
//
//  Created by Abbin Varghese on 13/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAFirstViewTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "FAColor.h"
#import "FAConstants.h"

@import FirebaseRemoteConfig;

@interface FAFirstViewTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

@end

@implementation FAFirstViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.layer.masksToBounds = YES;
    self.ratingView.tintColor = [FAColor mainColor];
    
    self.itemNameLavel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15];
    self.restaurantNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:13];
    self.userNameLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    self.distanceLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellImageUrl:(NSString *)cellImageUrl{
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:cellImageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.cellImageView setImageWithURLRequest:imageRequest
                     placeholderImage:[UIImage imageNamed:@"placeholder"]
                              success:nil
                              failure:nil];
}

@end
