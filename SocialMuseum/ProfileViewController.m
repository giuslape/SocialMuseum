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


#define ROW_SIZE               (CGSize){304, 44}

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_TABLES_GRID     (CGSize){320, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:14]


@implementation ProfileViewController{
    MGBox *tablesGrid, *table1;
    NSMutableArray* streamUser;
    NSNumber* thumbPhotoId;
    
    NSNumber* idUser;
    NSString* fbId;
    NSString* userName;
    
    bool isMe;
}

@synthesize userNameLabel;
@synthesize userProfileImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    API* api = [API sharedInstance];
    isMe = [api isMe];
    
    NSDictionary* user = (isMe) ? [api user] : [api temporaryUser];
    
        idUser = [user objectForKey:@"IdUser"];
        fbId   = ([user objectForKey:@"FBId"] != [NSNull null]) ? [user objectForKey:@"FBId"] : nil;
        userName = [user objectForKey:@"username"];
    
    streamUser = [[NSMutableArray alloc] initWithCapacity:0];
    
    thumbPhotoId = [NSNumber numberWithInt:0];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.text = @"";
    self.userProfileImage = [[FBProfilePictureView alloc]initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
    
    self.scroller.contentLayoutMode = MGLayoutTableStyle;
    self.scroller.bottomPadding = 8;
    
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    table1 = MGBox.box;
    [tablesGrid.boxes addObject:table1];
    table1.sizingMode = MGResizingShrinkWrap;
    
    [tablesGrid layout];
}


- (void)createUserInformationSection {
        
    MGTableBoxStyled *menu = MGTableBoxStyled.box;
    [table1.boxes addObject:menu];
    
    // header line
    MGLine *header = [MGLine lineWithLeft:nil right:nil size:(CGSize){304,136}];
    header.font = HEADER_FONT;
    [header.leftItems addObject:[PhotoBox photoProfileBoxWithView:self.userProfileImage andSize:(CGSize){100,100}]];
    
    [header.middleItems addObject:self.userNameLabel.text];
    header.topPadding = 16;
    header.leftPadding  =   16;
    header.rightPadding =   16;
    header.bottomPadding = 80;
    
    [menu.topLines addObject:header];
    
    
    MGLine* option = [MGLine lineWithSize:(CGSize){304,132}];
    option.font = HEADER_FONT;
    [option.leftItems addObject:[PhotoBox photoProfileOptionAdvice]];
    [option.leftItems addObject:[PhotoBox photoProfileOptionPhoto:thumbPhotoId]];
    option.topPadding  = 10;
    option.leftPadding = 16;
    [menu.topLines addObject:option];
    
    //[table1 layout];
    [self.scroller layoutWithSpeed:0.3f completion:nil];
    
}


- (void)loadActivitySection{
    
    
    MGTableBoxStyled* activity = MGTableBoxStyled.box;
    [table1.boxes addObject:activity];
        
    MGLine* header = [MGLine lineWithLeft:@"Attività recenti" right:nil size:ROW_SIZE];
    header.font = HEADER_FONT;
    header.leftPadding = header.rightPadding = header.topPadding = 16;
    [activity.topLines addObject:header];
        
    // Crea lo stream
    
    for (int i = 0; i< [streamUser count]; i++) {
        
        NSDictionary* dict = [streamUser objectAtIndex:i];
        
        MGLine *line = [MGLine line];
        
        if ([dict objectForKey:@"IdPhoto"]) {
            
            MGLine* header = [MGLine lineWithMultilineLeft:[NSString stringWithFormat:@"%@ ha pubblicato una foto nei pressi di...",userName] right:nil width:304 minHeight:60];
            header.leftPadding = header.topPadding = 16;
            header.underlineType = MGUnderlineNone;
            
            [activity.topLines addObject:header];
            
            MGBox* box = [self photoBoxFor:[NSNumber numberWithInt:[[dict objectForKey:@"IdPhoto"] intValue]]];
            box.leftMargin = 0;
            box.topMargin = 16;
            [line.middleItems addObject:box];
            line.size = (CGSize){304,144};
        }
        else if ([dict objectForKey:@"IdCommento"]){
            
            id testo = [NSString stringWithFormat:@"%@ ha scritto un commento \n \n %@",userName,[dict objectForKey:@"testo"]];
        
            line.multilineLeft = testo;
            line.padding = UIEdgeInsetsMake(16, 16, 16, 16);
            line.size = (CGSize){304,132};
        }
     
        [activity.topLines addObject:line];
    }
    
    [self.scroller layoutWithSpeed:0.3 completion:nil];
    
}


- (void)loadPhotoStreamUser{
    
    [[API sharedInstance] commandWithParams:
     [NSMutableDictionary dictionaryWithObjectsAndKeys:@"userStreamPhotos", @"command",idUser,@"IdUser", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"] count] > 0) {
                                       
                                       NSArray* itemsPhotos = [json objectForKey:@"result"];
                                       NSDictionary* dict = [itemsPhotos objectAtIndex:0];
                                       thumbPhotoId = [dict objectForKey:@"IdPhoto"];
                                       
                                       [streamUser addObjectsFromArray:itemsPhotos];
                                       
                                   }
                                   
                                   if ([json objectForKey:@"error"]) {
                                       
                                       UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                       [alert show];
                                       
                                   }
                                   
                                   [self populateUserDetails];
                               }];

    
}

- (void)loadUserComments {
    
    [[API sharedInstance] commandWithParams:
     [NSMutableDictionary dictionaryWithObjectsAndKeys:@"userStreamComments", @"command",idUser,@"IdUser", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"] count] > 0) {
                                       
                                       NSArray *itemsComments = [json objectForKey:@"result"];
                                       
                                       
                                       [streamUser addObjectsFromArray:itemsComments];
                                       
                                   }
                                   
                                   if ([json objectForKey:@"error"]) {
                                       
                                       UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                       [alert show];
                                       
                                   }
                                   
                                   // Ordina gli array in base alla data di inserimento degli item
                                   NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
                                   
                                   [streamUser sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
                                   
                                   [self loadActivitySection];
                                   
                               }];
    
}

#pragma mark - Rotation and resizing

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return YES;
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];
    self.scroller = nil;
}


- (void)viewDidAppear:(BOOL)animated {
        
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];

    [self loadPhotoStreamUser];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}




-(void)viewWillDisappear:(BOOL)animated{
    
    [table1.boxes removeAllObjects];
    [streamUser removeAllObjects];
}

- (void)populateUserDetails
{
        
    self.userNameLabel.text = userName;
    self.userProfileImage.profileID = fbId;
        
    [self createUserInformationSection];
    [self loadUserComments];
}

- (IBAction)logoutButtonWasPressed:(id)sender {
    
    [self unloadTables];
    [[API sharedInstance] logoutDidPressed];
    self.userNameLabel.text = nil;
}

-(void)unloadTables{
    
    [table1.boxes removeAllObjects];
}


-(MGBox *)photoBoxFor:(NSNumber *)idPhoto{
    
    // make the box
    PhotoBox *box = [PhotoBox photoProfileOptionPhoto:idPhoto];
    
  /*  // deal with taps
    __block MGBox *bbox = box;
    box.onTap = ^{
        
        // a new photo number
        int photo = [self randomMissingPhoto];
        
        // replace the add box with a photo loading box
        int idx = [photosGrid.boxes indexOfObject:bbox];
        [photosGrid.boxes removeObject:bbox];
        [photosGrid.boxes insertObject:[self photoBoxFor:photo] atIndex:idx];
        [photosGrid layout];
        
        // all photos are in now?
        if (![self randomMissingPhoto]) {
            return;
        }
        
        // add another add box
        [photosGrid.boxes addObject:self.photoAddBox];
        
        // animate the section and the scroller
        [photosGrid layoutWithSpeed:0.3 completion:nil];
        [self.scroller layoutWithSpeed:0.3 completion:nil];
    };*/
    
    return box;
}

@end
