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

@import FirebaseRemoteConfig;
@import FirebaseAuth;

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
    
    NSDictionary * linkAttributes = @{NSFontAttributeName:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:10],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.noThanksButton.titleLabel.text attributes:linkAttributes];
    [self.noThanksButton.titleLabel setAttributedText:attributedString];
    
    [self.headingLabel setFont:[UIFont fontWithName:[FIRRemoteConfig remoteConfig][kFARemoteConfigPrimaryFontKey].stringValue size:20]];

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
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error == nil) {
                                          if (![FAManager isLocationSet]) {
                                              [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
                                          }
                                          else{
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                          }
                                      }
                                  }];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

- (IBAction)noThanks:(id)sender {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if (error == nil) {
            [self performSegueWithIdentifier:@"FALocationViewControllerSegue" sender:self];
        }
     }];
}

@end
