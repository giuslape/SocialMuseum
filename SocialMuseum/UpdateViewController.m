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
#import "DetailCommentViewController.h"
#import "ArtWork.h"
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
    bool isNewComment;
    
    ArtWork* artWork;
}

@end

@implementation UpdateViewController

@synthesize IdOpera = _IdOpera;
@synthesize scroller = _scroller;


- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    artWork = [[API sharedInstance] temporaryArtWork];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        
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
        [self loadComments];
    }];
        
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
        
        NSString* username = [dict objectForKey:@"username"];
        NSString* commentText = [dict objectForKey:@"testo"];
        
        NSString* fbId = ([[dict objectForKey:@"FBId"]intValue]> 0) ?
        [dict objectForKey:@"FBId"] : [NSNull null];
                
        NSString* datetime = [dict objectForKey:@"datetime"];
        
        FBProfilePictureView* profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
        
        MGLine* line = [MGLine lineWithLeft:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){35,35}] right:nil];
        
        [line.leftItems addObject:[NSString stringWithFormat:@"%@\n%@",username, commentText]];
        [line.rightItems addObject:[NSString determingTemporalDifferencesFromNowtoStartDate:datetime]];
        
        line.font = HEADER_FONT;
        line.rightFont = RIGHT_FONT;
        line.padding = UIEdgeInsetsMake(4, 0, 4, 4);
        line.itemPadding = 8;
        line.minHeight = 60;
        
        CGSize minSize = [commentText sizeWithFont:HEADER_FONT];
        CGFloat height = minSize.height + line.padding.top + line.padding.bottom;
        
        line.size = (CGSize){304,height};
        
        [activity.topLines addObject:line];
        
        profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
        
        if ([dict isEqualToDictionary:[_comments objectAtIndex:0]] && isNewComment) {
            
            [UIView animateWithDuration:0.2f
                                  delay:0.5f
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 line.backgroundColor = [UIColor brownColor];
                                 line.backgroundColor = [UIColor clearColor];
                             }
                             completion:nil];
            isNewComment = false;
        }

        line.onTap = ^{
        
            [[API sharedInstance] setTemporaryComment:dict];
            [self performSegueWithIdentifier:@"DetailComment" sender:nil];
        
        };
    }
    
    [tableComments layout];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
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

#pragma mark -
#pragma mark ===  Segue  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"AddComment" compare:[segue identifier]] == NSOrderedSame) {
        
        //int tagButton = [(NSNumber *)sender intValue];
        
        UINavigationController* viewController = segue.destinationViewController;
        AddContentViewController* contentViewController = (AddContentViewController *)viewController.topViewController;
        contentViewController.artWork = [artWork copy];
        contentViewController.delegate = self;
        contentViewController.isAddComment = true;
        contentViewController.isAddPhoto = false;
        contentViewController.isChunck = false;
        
    }
    
    
}

#pragma mark -
#pragma mark ===  AddContent Delegate  ===
#pragma mark -


- (void)submitCommentDidPressed:(id)sender{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    [self performSelector:@selector(loadComments) withObject:nil afterDelay:1.6f];
    isNewComment = true;
    
    
}



@end
