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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.daysArray==nil) {
            self.daysArray = [NSMutableArray new];
            for (int i = 1; i <=7; i++) {
                NSMutableDictionary *day = [NSMutableDictionary new];
                [day setObject:[NSNumber numberWithInt:i] forKey:@"day"];
                [day setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
                [self.daysArray addObject:day];
            }
        }
    });
}

- (void)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonClicked:(id)sender {
    for (NSMutableDictionary *dict in self.daysArray) {
        if ([[dict objectForKey:@"open"] boolValue]){
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(FAWorkingDaysViewController:didFinishWithDays:)]) {
                    [self.delegate FAWorkingDaysViewController:self didFinishWithDays:self.daysArray];
                }
            }];
        }
    }
}

- (IBAction)mondaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.mondayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:0] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.mondayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:0] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)tuesdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.tuesdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:1] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.tuesdayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:1] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)wednesdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.wednesdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:2] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.wednesdayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:2] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)thursdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.thursdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:3] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.thursdayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:3] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)fridaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.fridayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:4] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.fridayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:4] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)saturdaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.saturdayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:5] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.saturdayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:5] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

- (IBAction)sundaySelected:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        [self.sundayImageView setImage:[UIImage imageNamed:@"uncheck"]];
        [[self.daysArray objectAtIndex:6] setObject:[NSNumber numberWithBool:NO] forKey:@"open"];
    }
    else{
        [sender setSelected:YES];
        [self.sundayImageView setImage:[UIImage imageNamed:@"check"]];
        [[self.daysArray objectAtIndex:6] setObject:[NSNumber numberWithBool:YES] forKey:@"open"];
    }
}

@end
