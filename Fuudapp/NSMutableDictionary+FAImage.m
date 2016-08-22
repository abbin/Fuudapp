//
//  NSMutableDictionary+FAImage.m
//  Fuudapp
//
//  Created by Abbin Varghese on 22/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSMutableDictionary+FAImage.h"
#import "FAConstants.h"

@implementation NSMutableDictionary (FAImage)

@dynamic imageHeight,imagePath,imageTimeStamp,imageUrl,imageVote,imageWidth;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter Methods -

-(void)setImageHeight:(NSNumber *)imageHeight{
    [self setObject:imageHeight forKey:kFAItemImagesHeightKey];
}

-(void)setImagePath:(NSString *)imagePath{
    [self setObject:imagePath forKey:kFAItemImagesPathKey];
}

-(void)setImageTimeStamp:(NSNumber *)imageTimeStamp{
    [self setObject:imageTimeStamp forKey:kFAItemImagesTimeStampKey];
}

-(void)setImageUrl:(NSString *)imageUrl{
    [self setObject:imageUrl forKey:kFAItemImagesURLKey];
}

-(void)setImageVote:(NSNumber *)imageVote{
    [self setObject:imageVote forKey:kFAItemImagesVoteKey];
}

-(void)setImageWidth:(NSNumber *)imageWidth{
    [self setObject:imageWidth forKey:kFAItemImagesWidthKey];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getter Methods -

-(NSNumber *)imageHeight{
    return [self objectForKey:kFAItemImagesHeightKey];
}

-(NSString *)imagePath{
    return [self objectForKey:kFAItemImagesPathKey];
}

-(NSNumber *)imageTimeStamp{
    return [self objectForKey:kFAItemImagesTimeStampKey];
}

-(NSString *)imageUrl{
    return [self objectForKey:kFAItemImagesURLKey];
}

-(NSNumber *)imageVote{
    return [self objectForKey:kFAItemImagesVoteKey];
}

-(NSNumber *)imageWidth{
    return [self objectForKey:kFAItemImagesWidthKey];
}

@end
