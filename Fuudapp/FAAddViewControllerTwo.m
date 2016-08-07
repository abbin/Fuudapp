//
//  FAAddViewControllerTwo.m
//  Fuudapp
//
//  Created by Abbin Varghese on 27/07/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAAddViewControllerTwo.h"
#import "FAColor.h"

@interface FAAddViewControllerTwo ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *itemArray;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (indexPath.row == self.itemArray.count-1) {
        cell.textLabel.text = [NSString stringWithFormat:@"Add '%@' as a new item?",self.itemArray[indexPath.row]];
        cell.detailTextLabel.text = @"";
    }
    return cell;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(FAAddViewControllerTwo:didFinishWithNewItem:)]) {
            [self.delegate FAAddViewControllerTwo:self didFinishWithNewItem:[self.itemArray objectAtIndex:indexPath.row]];
        }
    }];
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
//    if (self.itemArray == nil) {
//        self.itemArray = [NSMutableArray new];
//        [self.itemArray addObject: searchText];
//    }else{
//        [self.itemArray replaceObjectAtIndex:0 withObject:searchText];
//    }
//    [self.itemTableView reloadData];
    
    
}

@end
