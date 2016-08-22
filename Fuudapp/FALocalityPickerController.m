//
//  FALocalityPickerController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 01/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FALocalityPickerController.h"
#import "FAColor.h"
#import "AFNetworking.h"
#import "FAConstants.h"
#import "FAAnalyticsManager.h"
#import "NSMutableDictionary+FALocality.h"

@interface FALocalityPickerController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *locTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *locArray;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation FALocalityPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                             initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(cancelButtonClicked:)];

    self.navigationItem.leftBarButtonItem = cancel;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action -

- (void)cancelButtonClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.dataTask cancel];
    NSDate *start = [NSDate date];
    
    if (searchText.length>0) {
        
        NSArray* words = [searchText componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&components=country:%@&key=%@",nospacestring,countryCode,kFAGoogleServerKey];
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                self.locArray = responseObject[@"predictions"];
                
                NSDate *end = [NSDate date];
                NSMutableDictionary *parameter = [NSMutableDictionary new];
                [parameter setObject:@"YES" forKey:kFAAnalyticsSucessKey];
                [parameter setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.locArray.count] forKey:kFAAnalyticsResultCountKey];
                [parameter setObject:[NSString stringWithFormat:@"%f",[end timeIntervalSinceDate:start]] forKey:kFAAnalyticsResultTimeKey];
                [parameter setObject:kFAAnalyticsRestaurantSearchKey forKey:kFAAnalyticsSectionKey];
                
                [FAAnalyticsManager logSearchWithQuery:searchText
                                      customAttributes:parameter];
                
                [self.locTableView reloadData];
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
        self.locArray = nil;
        [self.locTableView reloadData];
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
    return self.locArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if ([[self.locArray objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = [self.locArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [[[dict objectForKey:@"terms"] firstObject]objectForKey:@"value"];
        @try {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[[[dict objectForKey:@"terms"] objectAtIndex:1] objectForKey:@"value"],[[[dict objectForKey:@"terms"] objectAtIndex:2] objectForKey:@"value"]];
        } @catch (NSException *exception) {
            @try {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[[dict objectForKey:@"terms"] objectAtIndex:1] objectForKey:@"value"]];
            } @catch (NSException *exception) {
                cell.detailTextLabel.text = @"";
            }
        }
    }
    else{
        NSString *string = [self.locArray objectAtIndex:indexPath.row];
        cell.textLabel.text = string;
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    
    NSString *placeID = [[self.locArray objectAtIndex:indexPath.row] objectForKey:@"place_id"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",placeID,kFAGoogleServerKey];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            NSMutableDictionary *locality = [[NSMutableDictionary alloc]initWithLocality:[responseObject objectForKey:@"result"]];
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(FALocalityPickerController:didFinisheWithLocation:)]) {
                    [self.delegate FALocalityPickerController:self didFinisheWithLocation:locality];
                }
            }];
        }
    }];
    [self.dataTask resume];
}

@end
