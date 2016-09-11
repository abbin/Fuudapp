//
//  FASignInViewController.m
//  Fuudapp
//
//  Created by Abbin Varghese on 16/08/16.
//  Copyright © 2016 Fuudapp. All rights reserved.
//

#import "FASignInViewController.h"
#import "FAConstants.h"
#import "FAManager.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FAUser.h"
#import "FARemoteConfig.h"

@interface FASignInViewController ()<FBSDKLoginButtonDelegate>

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UIButton *noThanksButton;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@end

@implementation FASignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.facebookButton.delegate = self;
    self.facebookButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_0102" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
    [self.movieView.layer addSublayer:avPlayerLayer];
    
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSDictionary * linkAttributes = @{NSFontAttributeName:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:10],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.noThanksButton.titleLabel.text attributes:linkAttributes];
    [self.noThanksButton.titleLabel setAttributedText:attributedString];
    
    [self.headingLabel setFont:[UIFont fontWithName:[FARemoteConfig primaryFontName] size:20]];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([FBSDKAccessToken currentAccessToken].tokenString) {
        self.view.userInteractionEnabled = NO;
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,email,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([result objectForKey:@"email"]) {
                    PFQuery *query = [FAUser query];
                    [query whereKey:@"email" equalTo:[result objectForKey:@"email"]]; // find all the women
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        
                        if (objects.count==0) {
                            FAUser *user = [FAUser user];
                            user.password = @"password";
                            user.email = [result objectForKey:@"email"];
                            user.username = [NSString stringWithFormat:@"%@ %@",[result objectForKey:@"first_name"],[result objectForKey:@"last_name"]];
                            NSString *url = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                            user.profilePhotoUrl = url;
                            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    if (![FAManager isLocationSet]) {
                                        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
                                    }
                                    else{
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }
                            }];
                            
                        }
                        else{
                            [PFUser logInWithUsernameInBackground:[result objectForKey:@"email"] password:@"password"
                                                            block:^(PFUser *user, NSError *error) {
                                                                if (user && error == nil) {
                                                                    if (![FAManager isLocationSet]) {
                                                                        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
                                                                    }
                                                                    else{
                                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                                    }
                                                                }
                                                            }];
                            
                        }
                        
                    }];
                }
            }
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.avplayer pause];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.avplayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerStartPlaying
{
    [self.avplayer play];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error == nil && [FBSDKAccessToken currentAccessToken].tokenString) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,email,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([result objectForKey:@"email"]) {
                    PFQuery *query = [FAUser query];
                    [query whereKey:@"email" equalTo:[result objectForKey:@"email"]]; // find all the women
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        
                        if (objects.count==0) {
                            FAUser *user = [FAUser user];
                            user.password = @"password";
                            user.email = [result objectForKey:@"email"];
                            user.username = [NSString stringWithFormat:@"%@ %@",[result objectForKey:@"first_name"],[result objectForKey:@"last_name"]];
                            NSString *url = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                            user.profilePhotoUrl = url;
                            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    if (![FAManager isLocationSet]) {
                                        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
                                    }
                                    else{
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                }
                            }];
                            
                        }
                        else{
                            [PFUser logInWithUsernameInBackground:[result objectForKey:@"email"] password:@"password"
                                                            block:^(PFUser *user, NSError *error) {
                                                                if (user && error == nil) {
                                                                    if (![FAManager isLocationSet]) {
                                                                        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
                                                                    }
                                                                    else{
                                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                                    }
                                                                }
                                                            }];
                            
                        }
                        
                    }];
                }
            }
        }];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

- (IBAction)noThanks:(id)sender {
    if (![FAManager isLocationSet]) {
        [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
