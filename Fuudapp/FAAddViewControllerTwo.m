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

@import FirebaseDatabase;

@interface FAAddViewControllerTwo ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end

@implementation FAAddViewControllerTwo

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
    self.searchBar.placeholder = @"type name here";
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.navigationItem.titleView = self.searchBar;
    
    self.ref = [[[FIRDatabase database] reference]child:@"items"];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions -

- (void)cancelButtonClicked:(id)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.searchBar resignFirstResponder];
    id item = [self.itemArray objectAtIndex:indexPath.row];

    [self dismissViewControllerAnimated:YES completion:^{
        if ([item isKindOfClass:[NSDictionary class]]) {
            if ([self.delegate respondsToSelector:@selector(FAAddViewControllerTwo:didFinishWithItem:)]) {
                [self.delegate FAAddViewControllerTwo:self didFinishWithItem:item];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(FAAddViewControllerTwo:didFinishWithNewItem:)]) {
                [self.delegate FAAddViewControllerTwo:self didFinishWithNewItem:[self.itemArray objectAtIndex:indexPath.row]];
            }
        }
    }];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.ref removeAllObservers];
    if (searchText.length>0) {
        NSArray* words = [searchText componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        
        [[[[[self.ref queryOrderedByKey] queryLimitedToLast:10] queryStartingAtValue:[nospacestring lowercaseString]] queryEndingAtValue:[NSString stringWithFormat:@"%@\uf8ff",[nospacestring lowercaseString]]]
         observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
             if (snapshot.value != [NSNull null]) {
                 self.itemArray = [snapshot.value allValues];
                 [self.itemTableView reloadData];
             }
             else{
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
