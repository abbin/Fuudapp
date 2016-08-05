//
//  FAImagePickerController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 26/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "NSIndexSet+Convenience.h"
#import "FAImagePickerController.h"
#import "UICollectionView+Convenience.h"
#import "FAImagePickerCollectionViewCell.h"
#import "FAAddViewControllerOne.h"
#import "FAColor.h"
#import <Crashlytics/Crashlytics.h>
#import "FAConstants.h"
@import FirebaseAnalytics;
@import Photos;

@interface FAImagePickerController ()<PHPhotoLibraryChangeObserver,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSMutableArray *selectedIndex;
@property (nonatomic, strong) NSMutableArray *selectedImages;
@property (strong, nonatomic) NSDate *start;
@property CGRect previousPreheatRect;

@end

@implementation FAImagePickerController

static NSString * const reuseIdentifier = @"FAImagePickerCollectionViewCell";
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.start = [NSDate date];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Next" style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(nextButtonClicked:)];
    UIBarButtonItem *camera = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                               target:self
                               action:@selector(cameraButtonClicked:)];
    [next setTintColor:[FAColor mainColor]];
    self.navigationItem.rightBarButtonItems = @[next,camera];;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)awakeFromNib{
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    self.assetsFetchResults = allPhotos;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        self.imageManager = [[PHCachingImageManager alloc] init];
        self.selectedIndex = [NSMutableArray new];
        [self resetCachedAssets];
    }
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = CGSizeMake(self.view.frame.size.width/3, self.view.frame.size.width/3);
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FAAddViewControllerOneSegue"]) {
        FAAddViewControllerOne *vc = segue.destinationViewController;
        vc.imageArray = self.selectedImages;
        vc.start = self.start;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)cameraButtonClicked:(id)sender {
    if (self.selectedIndex.count < 3) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusDenied) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't acess camera" message:@"Please allow app to access your camera by going to Settings > Privacy > Camera" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction *setting = [UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alert addAction:cancel];
            [alert addAction:setting];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextButtonClicked:(id)sender {
    if (_selectedImages == nil) {
        self.selectedImages = [NSMutableArray new];
    }
    if (self.selectedIndex.count>0) {
        [self.selectedImages removeAllObjects];
        for (NSIndexPath *indexPath in self.selectedIndex) {
            [self.imageManager requestImageDataForAsset:[self.assetsFetchResults objectAtIndex:indexPath.row]
                                                options:nil
                                          resultHandler:^(NSData * _Nullable imageData,
                                                          NSString * _Nullable dataUTI,
                                                          UIImageOrientation orientation,
                                                          NSDictionary * _Nullable info) {
                                              
                                              UIImage *image = [UIImage imageWithData:imageData];
                                              [self.selectedImages addObject:image];
                                              
                                              if (self.selectedImages.count == self.selectedIndex.count) {
                                                  
                                                  [Answers logCustomEventWithName:kFAAnalyticsImageSourceKey
                                                                 customAttributes:@{kFAAnalyticsSourceKey:kFAAnalyticsGalleryKey}];
                                                  
                                                  [FIRAnalytics logEventWithName:kFAAnalyticsImageSourceKey
                                                                      parameters:@{kFAAnalyticsSourceKey:kFAAnalyticsGalleryKey}];
                                                  
                                                  [self performSegueWithIdentifier:@"FAAddViewControllerOneSegue" sender:self];
                                              }
                                          }];
        }
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PHPhotoLibraryChangeObserver -

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        self.imageManager = [[PHCachingImageManager alloc] init];
        self.selectedIndex = [NSMutableArray new];
        [self.collectionView reloadData];
        [self resetCachedAssets];
    });
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    FAImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    if ([self.selectedIndex containsObject:indexPath]) {
        [cell selectCell:NO];
    }
    else{
        [cell deSelectCell:NO];
    }
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.cellImageView.image = result;
                                  }
                              }];
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate -

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width/3, self.view.frame.size.width/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FAImagePickerCollectionViewCell *cell = (FAImagePickerCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectedIndex containsObject:indexPath]) {
        [cell deSelectCell:YES];
        [self.selectedIndex removeObject:indexPath];
    }else{
        if (self.selectedIndex.count>2) {
            [cell shakeCell];
        }else{
            [cell selectCell:YES];
            [self.selectedIndex addObject:indexPath];
        }
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIImagePickerControllerDelegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [Answers logCustomEventWithName:kFAAnalyticsImageSourceKey
                   customAttributes:@{kFAAnalyticsSourceKey:kFAAnalyticsCameraKey}];
    
    [FIRAnalytics logEventWithName:kFAAnalyticsImageSourceKey
                        parameters:@{kFAAnalyticsSourceKey:kFAAnalyticsCameraKey}];
    
    if (self.selectedImages == nil) {
        self.selectedImages = [NSMutableArray new];
    }
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.selectedImages removeAllObjects];
        if (self.selectedIndex.count>0) {
            for (NSIndexPath *indexPath in self.selectedIndex) {
                [self.imageManager requestImageDataForAsset:[self.assetsFetchResults objectAtIndex:indexPath.row]
                                                    options:nil
                                              resultHandler:^(NSData * _Nullable imageData,
                                                              NSString * _Nullable dataUTI,
                                                              UIImageOrientation orientation,
                                                              NSDictionary * _Nullable info) {
                                                  
                                                  UIImage *image = [UIImage imageWithData:imageData];
                                                  
                                                  [self.selectedImages addObject:image];
                                                  
                                                  if (self.selectedImages.count == self.selectedIndex.count) {
                                                      [self.selectedImages addObject:chosenImage];
                                                      [self performSegueWithIdentifier:@"FAAddViewControllerOneSegue" sender:self];
                                                  }
                                              }];
            }
        }else{
            [self.selectedImages addObject:chosenImage];
            [self performSegueWithIdentifier:@"FAAddViewControllerOneSegue" sender:self];
        }
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Asset Caching -

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
        if (!isViewVisible) { return; }
        
        CGRect preheatRect = self.collectionView.bounds;
        preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
        
        /*
         Check if the collection view is showing an area that is significantly
         different to the last preheated area.
         */
        CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
        if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
            
            // Compute the assets to start caching and to stop caching.
            NSMutableArray *addedIndexPaths = [NSMutableArray array];
            NSMutableArray *removedIndexPaths = [NSMutableArray array];
            
            [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
                NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
                [removedIndexPaths addObjectsFromArray:indexPaths];
            } addedHandler:^(CGRect addedRect) {
                NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
                [addedIndexPaths addObjectsFromArray:indexPaths];
            }];
            
            NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
            NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
            
            // Update the assets the PHCachingImageManager is caching.
            [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                                targetSize:AssetGridThumbnailSize
                                               contentMode:PHImageContentModeAspectFill
                                                   options:nil];
            [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                               targetSize:AssetGridThumbnailSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil];
            
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect;
        }

    });
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

@end
