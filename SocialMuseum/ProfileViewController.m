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
@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize userNameLabel;
@synthesize userProfileImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 2000)];
}

- (void)viewDidUnload
{
    [self setUserNameLabel:nil];
    [self setUserProfileImage:nil];
    scroller = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
        [self populateUserDetails];
        [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"userStream", @"command",[[[API sharedInstance] user] objectForKey:@"IdUser"],@"IdUser", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"] count] > 0) {

                                   NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
                                   
                                   //Mostra la griglia con le ultime foto scattate
                                   
                                   int IdPhoto = [[res objectForKey:@"IdPhoto"] intValue];
                                   NSURL* imageURL = [[API sharedInstance] urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
                                   AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
                                       //Crea ImageView e l'aggiunge alla vista
                                       UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
                                       [scroller addSubview:thumbView];
                                   }];
                                   NSOperationQueue* queue = [[NSOperationQueue alloc] init];
                                   [queue addOperation:imageOperation];
                                }
                                   
                            }];
                               
    
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
            
            [(UITabBarController *)[[self parentViewController] parentViewController] setSelectedIndex:0];
        }];
    
    }
        
}

-(void)unloadImages{
    
    for (UIImageView* image in scroller.subviews) {
        
        if ([image isMemberOfClass:[UIView class]] || [image isMemberOfClass:[UILabel class]])continue;
        [image removeFromSuperview];
    }
    
}
@end
