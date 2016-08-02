//
//  FARestaurantPickerController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 28/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FARestaurantPickerController.h"
#import "FAColor.h"
#import <AFNetworking.h>
#import "FAConstants.h"
#import "NSMutableDictionary+FARestaurant.h"

@interface FARestaurantPickerController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *restTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *restArray;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@end

@implementation FARestaurantPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(cancelButtonClicked:)];
    [next setTintColor:[FAColor blackColor]];
    self.navigationItem.rightBarButtonItem = next;
    [self.navigationItem setHidesBackButton:YES];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-100, 44)];
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [self.searchBar setTintColor:[FAColor mainColor]];
    self.searchBar.placeholder = @"type restaurant name here";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;

}

- (void)cancelButtonClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.dataTask cancel];
    if (searchText.length>0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (!error) {
                self.restArray = responseObject[@"results"];
                if (self.restArray.count==0) {
                    self.restArray = @[[NSString stringWithFormat:@"Add '%@' as new a restaurant",searchText]];
                }
                [self.restTableView reloadData];
            }
        }];
        [self.dataTask resume];
    }
    else{
        self.restArray = nil;
        [self.restTableView reloadData];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.dataTask cancel];
    if ([[self.restArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        [self.searchBar resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(FARestaurantPickerController:didFinishWithNewRestaurant:)]) {
                [self.delegate FARestaurantPickerController:self didFinishWithNewRestaurant:self.searchBar.text];
            }
        }];
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
                NSMutableDictionary *restObj = [[NSMutableDictionary alloc]initWithRestaurant:[responseObject objectForKey:@"result"]];
                [self.searchBar resignFirstResponder];
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(FARestaurantPickerController:didFinishWithRestaurant:)]) {
                        [self.delegate FARestaurantPickerController:self didFinishWithRestaurant:restObj];
                    }
                }];
            }
        }];
        [self.dataTask resume];

    }
}

@end
