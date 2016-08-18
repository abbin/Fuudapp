//
//  FARestaurantPickerController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAColor.h"
#import "FAConstants.h"
#import "AFNetworking.h"
#import "FARestaurantPickerController.h"
#import "NSMutableDictionary+FARestaurant.h"
#import "FAAnalyticsManager.h"
#import "FAAddViewControllerThree.h"
#import "FAManager.h"
#import "FAActivityIndicator.h"

@import FirebaseRemoteConfig;

@interface FARestaurantPickerController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *restTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *restArray;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) id selectedRest;
@property (strong, nonatomic) FAActivityIndicator *activityIndicator;

@end

@implementation FARestaurantPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator = [[FAActivityIndicator alloc]initWithView:self.view];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = next;
    [self.navigationItem setHidesBackButton:YES];
    
    self.searchBar.placeholder = @"type restaurant name";
    
    [FAAnalyticsManager logEventWithName:kFAAnalyticsAddRestaurantKey parameters:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FAAddViewControllerThreeSegue"]) {
        FAAddViewControllerThree *vc = segue.destinationViewController;
        vc.itemobject = self.itemObject;
        vc.selectedImages = self.selectedImages;
        vc.restName = self.searchBar.text;
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action -

- (void)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.dataTask cancel];
    NSDate *start = [NSDate date];
    
    if (searchText.length>0) {
        [self.activityIndicator startAnimating];
        NSArray* words = [searchText componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        double lat = 9.976271;
        double lng = 76.293925;
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&rankby=distance&type=restaurant&keyword=%@&key=%@",lat,lng,nospacestring,kFAGoogleServerKey];
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                [self.activityIndicator  stopAnimating];
                self.restArray = responseObject[@"results"];
                
                NSDate *end = [NSDate date];
                NSMutableDictionary *parameter = [NSMutableDictionary new];
                [parameter setObject:[NSNumber numberWithBool:YES] forKey:kFAAnalyticsSucessKey];
                [parameter setObject:[NSNumber numberWithInteger:self.restArray.count] forKey:kFAAnalyticsResultCountKey];
                [parameter setObject:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
                [parameter setObject:kFAAnalyticsRestaurantSearchKey forKey:kFAAnalyticsSectionKey];
                
                [FAAnalyticsManager logSearchWithQuery:searchText
                                      customAttributes:parameter];
                
                if (self.restArray.count==0) {
                    self.restArray = @[[NSString stringWithFormat:@"Add '%@' as new a restaurant",searchText]];
                }
                
                [self.restTableView reloadData];
            }
            else{
                if (error.code != -999) {
                    [self.activityIndicator  stopAnimating];
                    NSDate *end = [NSDate date];
                    NSMutableDictionary *parameter = [NSMutableDictionary new];
                    [parameter setObject:[NSNumber numberWithBool:NO] forKey:kFAAnalyticsSucessKey];
                    [parameter setObject:[NSNumber numberWithDouble:[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
                    [parameter setObject:kFAAnalyticsRestaurantSearchKey forKey:kFAAnalyticsSectionKey];
                    
                    [FAAnalyticsManager logSearchWithQuery:searchText
                                          customAttributes:parameter];
                }
            }
        }];
        
        [self.dataTask resume];
    }
    else{
        self.restArray = nil;
        [self.restTableView reloadData];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate -

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigSecondaryKey].stringValue size:10];
    
    if ([[self.restArray objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = [self.restArray objectAtIndex:indexPath.row];
        cell.textLabel.text = dict[@"name"];
        cell.detailTextLabel.text = dict[@"vicinity"];
    }
    else{
        NSString *string = [self.restArray objectAtIndex:indexPath.row];
        cell.textLabel.text = string;
        cell.detailTextLabel.text = @"";
    }
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.dataTask cancel];
    if ([[self.restArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        [self.searchBar resignFirstResponder];
        self.selectedRest = self.searchBar.text;
        [self performSegueWithIdentifier:@"FAAddViewControllerThreeSegue" sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else{
        NSString *placeID = [[self.restArray objectAtIndex:indexPath.row] objectForKey:@"place_id"];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",placeID,kFAGoogleServerKey];
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [self.activityIndicator startAnimating];
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                self.selectedRest = [[NSMutableDictionary alloc]initWithRestaurant:[responseObject objectForKey:@"result"]];
                 [FAAnalyticsManager sharedManager].userRestaurant = [NSNumber numberWithBool:NO];

                [self.activityIndicator stopAnimating];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [FAManager saveItem:self.itemObject andRestaurant:self.selectedRest withImages:self.selectedImages];
                }];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
        [self.dataTask resume];
        
    }
}

@end
