//
//  ProfileViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class MGScrollView;

@interface ProfileViewController : UIViewController

@property (nonatomic, weak) IBOutlet MGScrollView *scroller;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) FBProfilePictureView *userProfileImage;


- (IBAction)logoutButtonWasPressed:(id)sender;
@end
