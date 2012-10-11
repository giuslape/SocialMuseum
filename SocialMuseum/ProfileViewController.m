//
//  ProfileViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ProfileViewController.h"
#import "API.h"
#import "UIAlertView+error.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"
#import "SMPhotoView.h"


@implementation ProfileViewController

@synthesize userNameLabel;
@synthesize userProfileImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadDataSource {
    
    [self populateUserDetails];
    
}

- (void)dataSourceDidLoad {
    
}

- (void)dataSourceDidError {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Errore" message:@"Non ci sono foto da caricare" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
   
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)populateUserDetails 
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, 
           NSDictionary<FBGraphUser> *user, 
           NSError *error) {
             if (!error) {
                 
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = user.id;
             }
         }];      
    }
    else {
        
            NSString* nameUser = [[[API sharedInstance] user] objectForKey:@"username"];
        
            self.userNameLabel.text = nameUser;
            self.userProfileImage.profileID = nil;
           
    }
}

- (IBAction)logoutButtonWasPressed:(id)sender {
    
    [self unloadImages];

    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else {
        NSString* command = @"logout";
        NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command",nil];
        //chiama l'API web
        [[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
            //Mostra Messaggio
            
            [[API sharedInstance] setUser:nil];
            self.userNameLabel.text = nil;
            
            AppDelegate* delegate = [UIApplication sharedApplication].delegate;
            
            [delegate logoutHandler];
            
        }];
    
    }
        
}

-(void)unloadImages{
    
    /*for (UIImageView* image in scroller.subviews) {
        
        if ([image isMemberOfClass:[UIView class]] || [image isMemberOfClass:[UILabel class]])continue;
        [image removeFromSuperview];
    }*/
    
}
@end
