//
//  FAImagePickerCollectionViewCell.h
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAImagePickerCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (weak, nonatomic) IBOutlet UIView *selectView;

-(void)selectCell;
-(void)shakeCell;

@end
