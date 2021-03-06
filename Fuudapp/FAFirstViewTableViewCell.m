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
#import "FARemoteConfig.h"

@interface FAFirstViewTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

@end

@implementation FAFirstViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ratingView.layer.cornerRadius = 5;
    self.ratingView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.layer.masksToBounds = YES;
    
    self.itemNameLavel.font = [UIFont fontWithName:[FARemoteConfig primaryFontName] size:15];
    self.restaurantNameLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10];
    self.distanceLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10];
    self.priceLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10];
    self.userNameLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10];
    [self.ratingView.titleLabel setFont:[UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10]];
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
                     placeholderImage:[UIImage imageNamed:@"background"]
                              success:nil
                              failure:nil];
}

-(void)setCellUserImageUrl:(NSString *)cellUserImageUrl{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:cellUserImageUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.userImageView setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"background"]
                                       success:nil
                                       failure:nil];
}

@end
