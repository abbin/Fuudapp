//
//  FADetailedImageCollectionViewCell.m
//  Fuudapp
//
//  Created by Abbin Varghese on 21/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FADetailedImageCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation FADetailedImageCollectionViewCell

-(void)setImageURL:(NSString *)imageURL{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.cellImageView setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"background"]
                                       success:nil
                                       failure:nil];
}

@end
