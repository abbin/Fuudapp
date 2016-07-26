//
//  FAAddViewControllerOne.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAddViewControllerOne.h"
#import "FAAddOneCollectionViewCell.h"
#import "FAColor.h"

@interface FAAddViewControllerOne ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation FAAddViewControllerOne

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Next" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(nextButtonClicked:)];
    [next setTintColor:[FAColor mainColor]];
    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(backButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonClicked:(id)sender {
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FAAddOneCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FAAddOneCollectionViewCell" forIndexPath:indexPath];
    cell.cellImageView.image = self.imageArray[indexPath.row];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = [self.imageArray objectAtIndex:indexPath.row];
    return CGSizeMake(collectionView.frame.size.height*image.size.width/image.size.height, collectionView.frame.size.height);
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
