//
//  ProfileViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CollectionView.h"

@interface ProfileViewController : UIViewController <CollectionViewDelegate, CollectionViewDataSource>{
    
    __weak IBOutlet UIScrollView *scroller;
}

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
- (IBAction)logoutButtonWasPressed:(id)sender;
@end
