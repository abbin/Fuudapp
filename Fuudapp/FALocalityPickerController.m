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

@interface FALocalityPickerController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *locTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *locArray;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation FALocalityPickerController

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
    self.searchBar.placeholder = @"type locality name here";
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
        
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&components=country:%@&key=%@",nospacestring,countryCode,kFAGoogleServerKey];
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        self.dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (!error) {
                self.locArray = responseObject[@"predictions"];
                [self.locTableView reloadData];
            }
            else{
                NSLog(@"%@",error.localizedDescription);
            }
        }];
        [self.dataTask resume];
    }
    else{
        self.locArray = nil;
        [self.locTableView reloadData];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(FALocalityPickerController:didFinisheWithLocation:)]) {
            [self.delegate FALocalityPickerController:self didFinisheWithLocation:[[self.locArray objectAtIndex:indexPath.row] objectForKey:@"description"]];
        }
    }];
}


@end
