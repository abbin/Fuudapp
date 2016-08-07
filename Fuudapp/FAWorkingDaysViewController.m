//
//  FAWorkingDaysViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 02/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FAWorkingDaysViewController.h"
#import "FAColor.h"

@interface FAWorkingDaysViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mondayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tuesdayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wednesdayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thursdayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fridayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *saturdayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sundayImageView;

@property (strong, nonatomic) NSMutableArray *daysArray;

@end

@implementation FAWorkingDaysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(doneButtonClicked:)];
    [next setTintColor:[FAColor mainColor]];
    self.navigationItem.rightBarButtonItem = next;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    if (self.daysArray==nil) {
        self.daysArray = [NSMutableArray new];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action -

- (void)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonClicked:(id)sender {
    NSMutableArray *arrayOfDays = [NSMutableArray new];
    for (NSNumber *num in self.daysArray) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSArray *daySymbols = dateFormatter.standaloneWeekdaySymbols;
        
        NSInteger dayIndex = [num integerValue]; // 0 = Sunday, ... 6 = Saturday
        NSString *dayName = daySymbols[dayIndex];
        
        NSMutableDictionary *close = [NSMutableDictionary dictionaryWithObjectsAndKeys:num,@"day",dayName, @"dayName", nil];
        NSMutableDictionary *open = [NSMutableDictionary dictionaryWithObjectsAndKeys:num,@"day",dayName, @"dayName", nil];
        NSMutableDictionary *mainDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:close,@"close",open,@"open", nil];
        [arrayOfDays addObject:mainDict];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(FAWorkingDaysViewController:didFinishWithDays:)]) {
            [self.delegate FAWorkingDaysViewController:self didFinishWithDays:arrayOfDays];
        }
    }];
}

- (IBAction)mondaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.mondayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:1]];
    }
    else{
        [sender setSelected:YES];
        [self.mondayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:1]];
    }
}

- (IBAction)tuesdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.tuesdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:2]];
    }
    else{
        [sender setSelected:YES];
        [self.tuesdayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:2]];
    }
}

- (IBAction)wednesdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.wednesdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:3]];
    }
    else{
        [sender setSelected:YES];
        [self.wednesdayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:3]];
    }
}

- (IBAction)thursdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.thursdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:4]];
    }
    else{
        [sender setSelected:YES];
        [self.thursdayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:4]];
    }
}

- (IBAction)fridaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.fridayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:5]];
    }
    else{
        [sender setSelected:YES];
        [self.fridayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:5]];
    }
}

- (IBAction)saturdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.saturdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:6]];
    }
    else{
        [sender setSelected:YES];
        [self.saturdayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:6]];
    }
}

- (IBAction)sundaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.sundayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [self.daysArray removeObject:[NSNumber numberWithInteger:0]];
    }
    else{
        [sender setSelected:YES];
        [self.sundayImageView setImage:[UIImage imageNamed:@"check"]];
        [self.daysArray addObject:[NSNumber numberWithInteger:0]];
    }
}

@end
