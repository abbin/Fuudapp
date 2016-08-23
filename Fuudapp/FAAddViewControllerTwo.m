//
//  FAAddViewControllerTwo.m
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAddViewControllerTwo.h"
#import "FAColor.h"
#import "FAConstants.h"
#import "FAReviewViewController.h"
#import "FAAddViewControllerOne.h"
#import "FAAnalyticsManager.h"

@import FirebaseDatabase;
@import FirebaseRemoteConfig;

@interface FAAddViewControllerTwo ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) id selectedItem;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end

@implementation FAAddViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]
                             initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem setHidesBackButton:YES];
    
    self.ref = [[[FIRDatabase database] reference]child:@"items"];
    
    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddItemKey parameters:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FAReviewViewControllerSegue"]) {
        FAReviewViewController *vc = segue.destinationViewController;
        vc.selectedImages = self.selectedImages;
        vc.itemObject = self.selectedItem;
    }
    else if ([segue.identifier isEqualToString:@"FAAddViewControllerOneSegue"]){
        FAAddViewControllerOne *vc = segue.destinationViewController;
        vc.selectedImages = self.selectedImages;
        vc.itemName = self.selectedItem;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)cancelButtonClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.itemArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    
    if ([item isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = [item objectForKey:kFAItemNameKey];
        cell.detailTextLabel.text = [[item objectForKey:kFAItemRestaurantKey] objectForKey:kFARestaurantNameKey];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"Add '%@' as a new item",item];
        cell.detailTextLabel.text = @"";
    }
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedItem = [self.itemArray objectAtIndex:indexPath.row];
    if ([self.selectedItem isKindOfClass:[NSDictionary class]]) {
        [FAAnalyticsManager sharedManager].userItem = @"NO";
        [FAAnalyticsManager sharedManager].userRestaurant = @"NO";
        [self performSegueWithIdentifier:@"FAReviewViewControllerSegue" sender:self];
    }
    else{
        [FAAnalyticsManager sharedManager].userItem = @"YES";
        [self performSegueWithIdentifier:@"FAAddViewControllerOneSegue" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.ref removeAllObservers];
    NSDate *start = [NSDate date];
    
    if (searchText.length>0) {
        NSArray* words = [searchText componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        
        [[[[[self.ref queryOrderedByChild:kFAItemCappedNameKey] queryLimitedToLast:10] queryStartingAtValue:[nospacestring lowercaseString]] queryEndingAtValue:[NSString stringWithFormat:@"%@\uf8ff",[nospacestring lowercaseString]]]
         observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
             
             if (snapshot.value != [NSNull null]) {
                 self.itemArray = [snapshot.value allValues];
                 [self.itemTableView reloadData];
                 
                 NSDate *end = [NSDate date];
                 NSMutableDictionary *parameter = [NSMutableDictionary new];
                 [parameter setObject:@"YES" forKey:kFAAnalyticsSucessKey];
                 [parameter setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.itemArray.count] forKey:kFAAnalyticsResultCountKey];
                 [parameter setObject:[NSString stringWithFormat:@"%f",[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
                 [parameter setObject:kFAAnalyticsRestaurantSearchKey forKey:kFAAnalyticsSectionKey];
                 
                 [FAAnalyticsManager logSearchWithQuery:searchText
                                       customAttributes:parameter];
                 
             }
             else{
                 
                 NSDate *end = [NSDate date];
                 NSMutableDictionary *parameter = [NSMutableDictionary new];
                 [parameter setObject:@"YES" forKey:kFAAnalyticsSucessKey];
                 [parameter setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.itemArray.count] forKey:kFAAnalyticsResultCountKey];
                 [parameter setObject:[NSString stringWithFormat:@"%f",[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
                 [parameter setObject:kFAAnalyticsRestaurantSearchKey forKey:kFAAnalyticsSectionKey];
                 
                 [FAAnalyticsManager logSearchWithQuery:searchText
                                       customAttributes:parameter];
                 
                 self.itemArray = @[searchText];
                 [self.itemTableView reloadData];
             }
         }];
    }
    else{
        self.itemArray = nil;
        [self.itemTableView reloadData];
    }
}

@end
