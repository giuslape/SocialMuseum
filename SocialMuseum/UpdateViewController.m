//
//  UpdateViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "UpdateViewController.h"
#import "AddCommentViewController.h"
#import "API.h"
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"

#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "MGScrollView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PhotoBox.h"
#import "NSString+Date.h"

#define HEADER_SIZE               (CGSize){304, 44}
#define ROW_SIZE                  (CGSize){304,60}
#define FOOTER_SIZE               (CGSize){304, 44}


#define IPHONE_TABLES_GRID     (CGSize){320, 0}
#define IPAD_TABLES_GRID       (CGSize){624, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:14]
#define RIGHT_FONT             [UIFont fontWithName:@"HelveticaNeue" size:10]



@interface UpdateViewController (){
    
    MGBox* tablesGrid, *tableComments;
    bool phone;
}

@end

@implementation UpdateViewController

@synthesize IdOpera = _IdOpera;
@synthesize scroller = _scroller;


- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    
    CGSize tablesGridSize = phone ? IPHONE_TABLES_GRID : IPAD_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];

    tableComments = MGBox.box;
    [tablesGrid.boxes addObject:tableComments];
    tableComments.sizingMode = MGResizingShrinkWrap;
   
    [self loadComments];
    
    [self.scroller addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh dataSource");
        [self loadComments];
    }];
    
    [self.scroller.pullToRefreshView setArrowColor:[UIColor whiteColor]];
    [self.scroller.pullToRefreshView setTextColor:[UIColor whiteColor]];
    [self.scroller.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    [tablesGrid layout];
    // relayout the sections
    [self.scroller layoutWithSpeed:1 completion:nil];
}

-(void)loadComments{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading..."];
    [hud setDimBackground:YES];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",_IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                    if (![json objectForKey:@"error"] && [[json objectForKey:@"result"]count] > 0) {
                                       
                        _comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                        [self sourceDidLoad];
                    }
                    else if([json objectForKey:@"error"]){
                            [self sourceDidError];
                        }
                            [self.scroller.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5f];
                                   [hud hide:YES];
                        }];
}

- (void)viewDidUnload
{
    [self setScroller:nil];
    //[self.view removeKeyboardControl];
    [super viewDidUnload];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)sourceDidError{
    
    
    
}
- (void)sourceDidLoad{
    
    if ([tableComments.boxes count] > 0) {
        [tableComments.boxes removeAllObjects];
    }
    MGTableBoxStyled* activity = MGTableBoxStyled.box;
    [tableComments.boxes addObject:activity];

    MGLine* header = [MGLine lineWithLeft:@"Commenti Recenti" right:nil size:HEADER_SIZE];
    header.font = HEADER_FONT;
    header.leftPadding = header.rightPadding = header.topPadding = 8;
    [activity.topLines addObject:header];
    
    for (NSDictionary* dict in _comments) {
        
        NSNumber* idPhoto = [NSNumber numberWithInt:[[dict objectForKey:@"IdPhoto"]intValue]];
        NSString* username = [dict objectForKey:@"username"];
        NSString* commentText = [dict objectForKey:@"testo"];
        
        NSString* fbId = ([[dict objectForKey:@"FBId"]intValue]> 0) ?
        [dict objectForKey:@"FBId"] : [NSNull null];
        
        NSNumber* Idu = [NSNumber numberWithInt:[[dict objectForKey:@"IdUser"]intValue]];
        
        NSString* datetime = [dict objectForKey:@"datetime"];
        NSArray *array = [NSArray arrayWithObjects:idPhoto,username,commentText,fbId,datetime,Idu,nil];
        
        FBProfilePictureView* profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
        
        MGLine* line = [MGLine lineWithLeft:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){35,35}] right:nil];
        
        [line.leftItems addObject:[NSString stringWithFormat:@"%@ \n%@",username, commentText]];
        [line.rightItems addObject:[NSString determingTemporalDifferencesFromNowtoStartDate:datetime]];
        
        line.font = HEADER_FONT;
        line.middleFont = HEADER_FONT;
        line.rightFont = RIGHT_FONT;
        line.padding = UIEdgeInsetsMake(4, 0, 4, 4);
        line.itemPadding = 8;
        line.minHeight = 60;
        
        CGSize minSize = [commentText sizeWithFont:HEADER_FONT];
        CGFloat height = minSize.height + line.padding.top + line.padding.bottom;
        
        line.size = (CGSize){304,height};
        
        [activity.topLines addObject:line];
        
        profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
        
        line.onTap = ^{
        
            [self performSegueWithIdentifier:@"ShowProfile" sender:array];
        
        };
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           220.0f,
                                                                           30.0f)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.font = HEADER_FONT;
    textField.placeholder = @"Commenta";
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  58.0f,
                                  29.0f);
    
    MGLine* footer = [MGLine lineWithLeft:textField right:sendButton size:FOOTER_SIZE];
    [activity.bottomLines addObject:footer];
    footer.topPadding = footer.leftPadding = footer.rightPadding = 8;
    //[self layoutKeyboard];
    [tableComments layout];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
}


#pragma mark -
#pragma mark ===  Segue Handler  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddComment"])
    {
        AddCommentViewController*addCommentViewController =  segue.destinationViewController;
        [addCommentViewController setIdOpera:_IdOpera];
    }
}


#pragma mark -
#pragma mark ===  Keyboard  ===
#pragma mark -

- (MGBox *)layoutKeyboard{
    
    MGBox* box = [MGBox boxWithSize:FOOTER_SIZE];
    
    box.layer.cornerRadius = 20;
    box.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:box.bounds
                                                       cornerRadius:10].CGPath;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     box.size.width,
                                                                     box.size.height)];
    
    toolBar.layer.cornerRadius = 10;
    toolBar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:toolBar.bounds
                                                       cornerRadius:toolBar.layer.cornerRadius].CGPath;
    
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [box addSubview:toolBar];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           30.0f)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolBar addSubview:textField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [toolBar addSubview:sendButton];
    
    return box;
    
    /*self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
    
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        
        float gap = (keyboardFrameInView.origin.y > 415) ? 49.0f : 0;
        
        CGRect toolBarFrame = toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height - gap;
        toolBar.frame = toolBarFrame;
        
        CGRect scrollerFrame = self.scroller.frame;
        scrollerFrame.size.height = toolBarFrame.origin.y;
        self.scroller.frame = scrollerFrame;
    }];*/

    
}

@end
