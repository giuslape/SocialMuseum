//
//  ProfileViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ProfileViewController.h"
#import "API.h"
#import "SMPhotoView.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "AppDelegate.h"
#import "PhotoBox.h"

#define kDeafultItem            0

#define ROW_SIZE               (CGSize){304, 44}

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_TABLES_GRID     (CGSize){320, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:14]


@implementation ProfileViewController{
    MGBox *tablesGrid, *table1;
    NSMutableArray* items;
    NSNumber* thumbPhotoId;
}

@synthesize userNameLabel;
@synthesize userProfileImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    items = [[NSMutableArray alloc] initWithCapacity:0];
    
    thumbPhotoId = [NSNumber numberWithInt:0];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.text = @"";
    self.userProfileImage = [[FBProfilePictureView alloc] init];
    
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    table1 = MGBox.box;
    [tablesGrid.boxes addObject:table1];
    table1.sizingMode = MGResizingShrinkWrap;
    
    [tablesGrid layout];
    
    
    
    [[API sharedInstance] commandWithParams:
     [NSMutableDictionary dictionaryWithObjectsAndKeys:@"userStream", @"command",[[[API sharedInstance] user] objectForKey:@"IdUser"],@"IdUser", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"] count] > 0) {
                                       items = [json objectForKey:@"result"];
                                       NSDictionary* dict = [items objectAtIndex:0];
                                       thumbPhotoId = [dict objectForKey:@"IdPhoto"];
                                   }
                                   
                                   [self populateUserDetails];
                                   
                               }];
}


- (void)loadIntroSection {
        
    MGTableBoxStyled *menu = MGTableBoxStyled.box;
    [table1.boxes addObject:menu];
    
    // header line
    MGLine *header = [MGLine lineWithLeft:nil right:nil size:(CGSize){304,120}];
    header.font = HEADER_FONT;
    [header.leftItems addObject:[PhotoBox photoProfileBoxWithView:self.userProfileImage andSize:(CGSize){100,100}]];
    
    [header.middleItems addObject:self.userNameLabel.text];

    header.leftPadding =   10;
    header.rightPadding =  16;
    header.bottomPadding = 80;
    
    [menu.topLines addObject:header];
    
    
    MGLine* option = [MGLine lineWithSize:(CGSize){304,132}];
    option.font = HEADER_FONT;
    [option.leftItems addObject:[PhotoBox photoProfileOptionAdvice]];
    [option.leftItems addObject:[PhotoBox photoProfileOptionPhoto:thumbPhotoId]];
    option.leftPadding  = 10;
    header.rightPadding = 10;
    [menu.topLines addObject:option];
    
    [self.scroller layoutWithSpeed:0.3f completion:nil];
}


- (void)loadDataSource {
    
    [self populateUserDetails];
    
}

- (void)dataSourceDidLoad {
    
}

#pragma mark - Rotation and resizing

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
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
                 [self loadIntroSection];
                 
                }
         }];      
    }
    else {
        
            NSString* nameUser = [[[API sharedInstance] user] objectForKey:@"username"];
            self.userNameLabel.text = nameUser;
            self.userProfileImage.profileID = nil;
            [self loadIntroSection];

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
