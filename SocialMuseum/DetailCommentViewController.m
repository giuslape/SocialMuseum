//
//  DetailCommentViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "DetailCommentViewController.h"
#import "MGScrollView.h"
#import "MGBox.h"
#import "PhotoBox.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "MGLineStyled.h"
#import "API.h"
#import "ArtWork.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileViewController.h"


#define IPHONE_TABLES_GRID          (CGSize){320, 0}
#define IPHONE_PORTRAIT_ARTWORK     (CGSize){288, 136}
#define IPHONE_PORTRAIT_PHOTO       (CGSize){53, 53}

#define ROW_IMAGE_ARTWORK           (CGSize){304, 152}



#define LINE_FONT               [UIFont fontWithName:@"HelveticaNeue" size:12]
#define RIGHT_FONT              [UIFont fontWithName:@"HelveticaNeue" size:10]



@interface DetailCommentViewController ()

@end

@implementation DetailCommentViewController{
    
    MGBox *containerBox, *tableContent, *userDetail, *commentBox;
    NSDictionary* commentDetails;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    commentDetails = [[API sharedInstance] temporaryComment];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)]];
    
    self.scroller.contentLayoutMode = MGLayoutTableStyle;
    self.scroller.bottomPadding = 8;
    
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    containerBox = [MGBox boxWithSize:tablesGridSize];
    containerBox.contentLayoutMode = MGLayoutTableStyle;
    [self.scroller.boxes addObject:containerBox];
    
    
    tableContent = MGBox.box;
    [containerBox.boxes addObject:tableContent];
    tableContent.sizingMode = MGResizingShrinkWrap;
    
    /*userDetail = MGBox.box;
    [containerBox.boxes addObject:userDetail];
    userDetail.sizingMode = MGResizingShrinkWrap;*/
    
    commentBox = MGBox.box;
    [containerBox.boxes addObject:commentBox];
    commentBox.sizingMode = MGResizingShrinkWrap;

    
    [containerBox layout];
    
    
    [self loadImageArtwork];
   // [self loadUserDetail];
    [self loadCommentDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScroller:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark ===  Load Image Art Work  ===
#pragma mark -

- (void)loadImageArtwork{
    
    MGTableBoxStyled* art = MGTableBoxStyled.box;
    [tableContent.boxes addObject:art];
    
    ArtWork* artwork = [[API sharedInstance] temporaryArtWork];
    
    MGLine* line = [MGLine lineWithLeft:[self photoBoxForArtwork:artwork.imageUrl andSize:IPHONE_PORTRAIT_ARTWORK] right:nil size:ROW_IMAGE_ARTWORK];
    [art.topLines addObject:line];
    line.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    
    [self.scroller layoutWithSpeed:0.3f completion:nil];
    
}


- (PhotoBox *)photoBoxForArtwork:(NSString *)urlImage andSize:(CGSize)size{
    
    PhotoBox* box = [PhotoBox photoArtworkWithUrl:urlImage andSize:size];
    
    return box;
}

/*#pragma mark -
#pragma mark ===  Load User Detail  ===
#pragma mark -

- (void)loadUserDetail{
    
    MGTableBoxStyled* userTable = MGTableBoxStyled.box;
    [userDetail.boxes addObject:userTable];
    
    FBProfilePictureView* profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
    
    NSString* username = [commentDetails objectForKey:@"username"];
    
    NSString* fbId = ([[commentDetails objectForKey:@"FBId"]intValue]> 0) ?
    [commentDetails objectForKey:@"FBId"] : [NSNull null];
    
    NSString* datetime = [commentDetails objectForKey:@"datetime"];
    
    MGLine* userLine = [MGLine lineWithLeft:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){45,45}] right:nil size:(CGSize){304, 61}];
    
    [userLine.leftItems addObject:[NSString stringWithFormat:@"%@\n%@",username,datetime]];
    
    userLine.font = LINE_FONT;
    userLine.padding = UIEdgeInsetsMake(8, 0, 8, 8);
    userLine.itemPadding = 8;

    [userTable.topLines addObject:userLine];
    
    profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
    
    [self.scroller layoutWithSpeed:0.3f completion:nil];
    
    userLine.onTap = ^{
        [self performSegueWithIdentifier:@"ShowProfile" sender:nil];
    };
}*/


#pragma mark -
#pragma mark ===  Load Comment Text  ===
#pragma mark -

- (void)loadCommentDetail{
    
    MGTableBoxStyled* commentTable = MGTableBoxStyled.box;
    [commentBox.boxes addObject:commentTable];
    
    NSString* textComment = [commentDetails objectForKey:@"testo"];
    MGLineStyled* commentLine = [MGLineStyled multilineWithText:textComment font:LINE_FONT width:304 padding:UIEdgeInsetsMake(8, 0, 8, 8)];
    
    commentLine.itemPadding = 8;
    
    [commentTable.topLines addObject:commentLine];
    
    FBProfilePictureView* profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
    
    NSString* username = [commentDetails objectForKey:@"username"];
    
    NSString* fbId = ([[commentDetails objectForKey:@"FBId"]intValue]> 0) ?
    [commentDetails objectForKey:@"FBId"] : [NSNull null];
    
    NSString* datetime = [commentDetails objectForKey:@"datetime"];
    
    MGLineStyled* userLine = [MGLineStyled lineWithLeft:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){45,45}] right:nil size:(CGSize){304, 61}];
    
    [userLine.leftItems addObject:[NSString stringWithFormat:@"%@\n%@",username,datetime]];
    
    userLine.font = LINE_FONT;
    userLine.padding = UIEdgeInsetsMake(8, 0, 8, 8);
    userLine.itemPadding = 8;
    
    [commentTable.topLines addObject:userLine];
    
    profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
        
    userLine.onTap = ^{
        [self performSegueWithIdentifier:@"ShowProfile" sender:nil];
    };
    
    [self.scroller layoutWithSpeed:0.3f completion:nil];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"ShowProfile" compare:segue.identifier] == NSOrderedSame) {
        ProfileViewController* profile = segue.destinationViewController;
        profile.hiddenRightButton = YES;
    }
    
}


@end
