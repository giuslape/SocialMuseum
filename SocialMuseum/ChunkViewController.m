//
//  ChunkViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ChunkViewController.h"
#import "MBProgressHUD.h"
#import "API.h"
#import "PullToRefreshView.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "ArtWork.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PhotoBox.h"


#define IPHONE_TABLES_GRID          (CGSize){320, 0}

#define LINE_FONT              [UIFont fontWithName:@"HelveticaNeue" size:12]


@implementation ChunkViewController{
    
    MGBox* containerBox, *commentContainer, *chunckContainer;
    ArtWork* artWork;
    UIImage* arrow;
    NSDictionary* chunckDetails;
    
    bool isNewComment;
    
}


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    arrow = [UIImage imageNamed:@"arrow.png"];

    chunckDetails = [[API sharedInstance] temporaryChunck];
    
    NSLog(@"%d",[[chunckDetails objectForKey:@"IdChunk"]intValue]);
    
    artWork = [[API sharedInstance] temporaryArtWork];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading"];
    hud.dimBackground = YES;
    
    self.scroller.contentLayoutMode = MGLayoutTableStyle;
    self.scroller.bottomPadding = 8;
   
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    containerBox = [MGBox boxWithSize:tablesGridSize];
    containerBox.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:containerBox];
    
    chunckContainer = MGBox.box;
    [containerBox.boxes addObject:chunckContainer];
    chunckContainer.sizingMode = MGResizingShrinkWrap;
    
    commentContainer = MGBox.box;
    [containerBox.boxes addObject:commentContainer];
    commentContainer.sizingMode = MGResizingShrinkWrap;
    
        
    [self.scroller addPullToRefreshWithActionHandler:^{
        [self streamCommenti];
    }];
    
    [containerBox layout];
    [self layoutChunckContainer];
    [self streamCommenti];
    [self.scroller layoutWithSpeed:0.3f completion:nil];
}

- (void)viewDidUnload
{
    [self setScroller:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark ===  Layout Chunk  ===
#pragma mark -

- (void)layoutChunckContainer{
    
    MGTableBoxStyled* chunckTable = MGTableBoxStyled.box;
    [chunckContainer.boxes addObject:chunckTable];
    
    MGLine* chunckTextLine = [MGLine multilineWithText:[chunckDetails objectForKey:@"testo"] font:LINE_FONT width:304 padding:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    [chunckTable.topLines addObject:chunckTextLine];
    
    //[chunckContainer layout];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
}

-(void)streamCommenti{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",artWork.IdOpera,@"IdOpera",[NSNumber numberWithInt:[[chunckDetails objectForKey:@"IdChunk"]intValue]],@"IdChunk", nil]
     
                               onCompletion:^(NSDictionary *json) {
                                   
                                   _comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                   [self commentsDidLoad];
                                   [self.scroller.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5f];
                               }];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.scroller layoutWithSpeed:0.3f completion:nil];

}

- (void)commentsDidLoad{
    
    if (commentContainer.boxes.count >= 1)
        [commentContainer.boxes removeAllObjects];
    
    MGTableBoxStyled* comment = MGTableBoxStyled.box;
    [commentContainer.boxes addObject:comment];
    
    for (NSDictionary* dict in _comments) {
        
        FBProfilePictureView* profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
        
        NSString* commentText = [dict objectForKey:@"testo"];
        NSString* username = [dict objectForKey:@"username"];
        
        NSNumber* idUser = [NSNumber numberWithInt:[[dict objectForKey:@"IdUser"] intValue]];
        
        NSString* fbId = ([[dict objectForKey:@"FBId"]intValue]> 0) ?
        [dict objectForKey:@"FBId"] : [NSNull null];
        
        //NSString* datetime = [dict objectForKey:@"datetime"];
        
        MGLine* commentLine = [MGLine lineWithLeft:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){45,45}] right:arrow];
        
        [commentLine.leftItems addObject:[NSString stringWithFormat:@"%@\n%@",username,commentText]];
        
        commentLine.font = LINE_FONT;
        commentLine.minHeight = 50;
        commentLine.padding = UIEdgeInsetsMake(8, 0, 8, 8);
        commentLine.itemPadding = 8;
        commentLine.sidePrecedence = MGSidePrecedenceRight;
        commentLine.maxHeight = 60;
        
        CGSize minSize = [commentText sizeWithFont:LINE_FONT];
        CGFloat height = minSize.height + commentLine.padding.top + commentLine.padding.bottom;
        
        commentLine.size = (CGSize){304,height};
        
        [comment.topLines addObject:commentLine];
        
        profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
        
        if ([dict isEqualToDictionary:[_comments objectAtIndex:0]] && isNewComment) {
            
            [UIView animateWithDuration:0.2f
                                  delay:0.5f
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 commentLine.backgroundColor = [UIColor brownColor];
                                 commentLine.backgroundColor = [UIColor clearColor];
                             }
                             completion:nil];
        }
        commentLine.onTap = ^{
            
            [[API sharedInstance] setTemporaryUser:@{@"IdUser" : idUser, @"username" : username, @"FBId" : fbId}];
            [[API sharedInstance] setTemporaryComment:dict];
            //[self performSegueWithIdentifier:@"AddContent" sender:nil];
        };
        
    }
    
    
    [commentContainer layout];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
    if (isNewComment)[self.scroller scrollToView:comment withMargin:8];
    isNewComment = false;
    
}


#pragma mark -
#pragma mark ===  Segue  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"AddContent" compare:[segue identifier]] == NSOrderedSame) {
        
        UINavigationController* viewController = segue.destinationViewController;
        AddContentViewController* contentViewController = (AddContentViewController *)viewController.topViewController;
        contentViewController.artWork = [artWork copy];
        contentViewController.delegate = self;
        contentViewController.isChunck = YES;        
    }
    
}


#pragma mark -
#pragma mark ===  Add Content Delegate Methods  ===
#pragma mark -

- (void)submitCommentDidPressed:(id)sender{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    [self performSelector:@selector(streamCommenti) withObject:nil afterDelay:1.6f];
    isNewComment = true;
}

/*

-(void)setChunk:(NSString *)chunk{

    _chunk = chunk;

}

-(void)setIdChunk:(NSNumber *)IdChunk{
    
    _IdChunk = IdChunk;
    
}

-(void)setIdOpera:(NSNumber *)IdOpera{
    
    _IdOpera = IdOpera;
}


#pragma mark -
#pragma mark ===  Add Comment Delegate  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}



-(void)addCommentDidCancel:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void)addCommentDidSave:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UserCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
        
    }
    
    NSDictionary * dictionary= [_comments objectAtIndex:indexPath.row];
    NSString* text = [dictionary objectForKey:@"testo"];
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* dictionary = [_comments objectAtIndex:indexPath.row];
    CGSize size = [[dictionary objectForKey:@"testo"] 
                   sizeWithFont:[UIFont systemFontOfSize:10] 
                   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    return size.height + 15;
}
*/


@end
