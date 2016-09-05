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
#import "NSMutableDictionary+FALocality.h"
#import "FAAnalyticsManager.h"
#import "FAAddViewControllerThree.h"
#import "FAManager.h"
#import "FARestaurantObject.h"
#import "FARemoteConfig.h"

@interface FARestaurantPickerController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *restTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *restArray;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) FARestaurantObject *selectedRestP;

@end

@implementation FARestaurantPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        vc.itemobjectP = self.itemObjectP;
        vc.selectedImages = self.selectedImages;
        vc.restName = self.searchBar.text;
        vc.itemobjectP = self.itemObjectP;
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
        NSArray* words = [searchText componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSMutableDictionary *loc = [[NSUserDefaults standardUserDefaults]objectForKey:kFASelectedLocalityKey];
        
        double lat = [loc.localityLatitude doubleValue];
        double lng = [loc.localityLongitude doubleValue];
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&rankby=distance&type=restaurant&name=%@&key=%@",lat,lng,nospacestring,kFAGoogleServerKey];
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                self.restArray = responseObject[@"results"];
                
                NSDate *end = [NSDate date];
                NSMutableDictionary *parameter = [NSMutableDictionary new];
                [parameter setObject:@"YES" forKey:kFAAnalyticsSucessKey];
                [parameter setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.restArray.count] forKey:kFAAnalyticsResultCountKey];
                [parameter setObject:[NSString stringWithFormat:@"%f",[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
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
                    NSDate *end = [NSDate date];
                    NSMutableDictionary *parameter = [NSMutableDictionary new];
                    [parameter setObject:@"NO" forKey:kFAAnalyticsSucessKey];
                    [parameter setObject:[NSString stringWithFormat:@"%f",[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
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
    
    cell.textLabel.font = [UIFont fontWithName:[FARemoteConfig primaryFontName] size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:[FARemoteConfig secondaryFontName] size:10];
    
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
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                self.selectedRestP = [FARestaurantObject initWithDictionary:[responseObject objectForKey:@"result"]];
                
                 [FAAnalyticsManager sharedManager].userRestaurant = @"NO";
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [FAManager savePItem:self.itemObjectP andRestaurant:self.selectedRestP withImages:self.selectedImages];
                }];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
        [self.dataTask resume];
        
    }
}

@end
