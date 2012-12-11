//
//  OperaViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "OperaViewController.h"
#import "StreamScreen.h"
#import "API.h"
#import "ChunkViewController.h"
#import "UpdateViewController.h"
#import "ArtWork.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "PhotoBox.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSString+Date.h"
#import "AddContentViewController.h"


#define IPHONE_TABLES_GRID          (CGSize){320, 0}
#define IPHONE_PORTRAIT_ARTWORK     (CGSize){288, 136}
#define IPHONE_PORTRAIT_GRID        (CGSize){312, 0}
#define IPHONE_PORTRAIT_PHOTO       (CGSize){51, 51}


#define ROW_IMAGE_ARTWORK           (CGSize){304, 152}
#define ROW_SIZE                    (CGSize){304, 44} 
#define ROW_STREAM_FOTO_SIZE        (CGSize){304, 68}
#define FOOTER_SIZE                 (CGSize){304,35}


#define LINE_FONT               [UIFont fontWithName:@"HelveticaNeue" size:12]
#define HEADER_FONT             [UIFont fontWithName:@"HelveticaNeue" size:14]
#define RIGHT_FONT              [UIFont fontWithName:@"HelveticaNeue" size:10]


@interface OperaViewController ()

-(void)showPhotos:(NSArray *)stream;

@end


#define kThumb 30
#define kPad 3

@implementation OperaViewController{
    
    ArtWork* artwork;
    MGBox *tablesGrid, *tableContent, *photosGrid, *tableComments;
    NSArray* chuncks;
    NSArray* comments;
    NSArray* photos;
    UIImage* arrow;
    
    bool isNewComment;
    bool isNewPhoto;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isNewComment = false;
    isNewPhoto = false;
    
    arrow = [UIImage imageNamed:@"arrow.png"];
    chuncks = [NSArray array];
    comments = [NSArray array];
    photos   = [NSArray array];
    
    artwork = [[API sharedInstance] temporaryArtWork];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    self.view.layer.shouldRasterize = YES;
    self.navigationItem.title = artwork.title;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading"];
    hud.dimBackground = YES;

    self.scroller.contentLayoutMode = MGLayoutTableStyle;
    self.scroller.bottomPadding = 8;
    
    CGSize tablesGridSize =  IPHONE_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    tableContent = MGBox.box;
    [tablesGrid.boxes addObject:tableContent];
    tableContent.sizingMode = MGResizingShrinkWrap;
    
    tableComments = MGBox.box;
    [tablesGrid.boxes addObject:tableComments];
    tableComments.sizingMode = MGResizingShrinkWrap;
    
    photosGrid = [MGBox boxWithSize:IPHONE_PORTRAIT_GRID];
    photosGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:photosGrid];
    
    [tablesGrid layout];
    [self.scroller layoutWithSpeed:0.3f completion:nil];
    [self loadArtWorkContent];
    [self loadComments];
    [self loadThumbPhotos];
}


- (void)viewDidUnload
{
    artwork = nil;
    comments = nil;
    chuncks = nil;
    isNewComment = false;
    [self setScroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
   
    /*[[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",_artWork.IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		[self showPhotos:[json objectForKey:@"result"]];
        
        }];*/
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}


#pragma mark -
#pragma mark ===  Stream Photo  ===
#pragma mark -

-(void)showPhotos:(NSArray *)stream{
    
   /* for (UIView* view in _photoView.subviews) {
        [view removeFromSuperview];
    }
    API* api = [API sharedInstance];
    
    for (int i=0;i<[stream count];i++) {
        
        NSDictionary* photo = [stream objectAtIndex:i];
        
		int IdPhoto = [[photo objectForKey:@"IdPhoto"] intValue];
        int col = i%8;
        NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
		AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
			//Crea ImageView e l'aggiunge alla vista
			UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
            thumbView.frame = CGRectMake(1.5*kPad+col*(kThumb+kPad), kPad, kThumb, kThumb);
			[_photoView addSubview:thumbView];
		}];
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
		[queue addOperation:imageOperation];
    }     */
}

#pragma mark -
#pragma mark ===  Artwork Content  ===
#pragma mark -

- (void)loadArtWorkContent{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"content", @"command",artwork.IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"]) {
                                       
                                       chuncks  = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                       [self chunckDidLoad];
                                   }
                                   
    }];
}

- (void)chunckDidLoad{
    
    MGTableBoxStyled* art = MGTableBoxStyled.box;
    [tableContent.boxes addObject:art];
    
    MGLine* line = [MGLine lineWithLeft:[self photoBoxForArtwork:artwork.imageUrl andSize:IPHONE_PORTRAIT_ARTWORK] right:nil size:ROW_IMAGE_ARTWORK];
    [art.topLines addObject:line];
    line.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    
    for (NSDictionary* dict in chuncks) {
        
        MGLine* chunckLine = [MGLine lineWithMultilineLeft:[dict objectForKey:@"testo"] right:arrow width:304 minHeight:44];
        [art.topLines addObject:chunckLine];
        chunckLine.padding = UIEdgeInsetsMake(8, 8, 8, 8);
        chunckLine.font = LINE_FONT;
        chunckLine.sidePrecedence = MGSidePrecedenceRight;
        
        chunckLine.onTap = ^{
            
            
            [[API sharedInstance] setTemporaryChunck:@{@"testo": [dict objectForKey:@"testo"], @"IdChunk" : [NSNumber numberWithInt:[[dict objectForKey:@"IdChunk"] intValue]]}];
            
            [self performSegueWithIdentifier:@"ShowContent" sender:nil];
        
        };
    }
    
    [tableContent layout];
    [self.scroller layoutWithSpeed:0.3 completion:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

- (PhotoBox *)photoBoxForArtwork:(NSString *)urlImage andSize:(CGSize)size{
    
    PhotoBox* box = [PhotoBox photoArtworkWithUrl:urlImage andSize:size];
    
    return box;
}

#pragma mark -
#pragma mark ===  Comments  ===
#pragma mark -

- (void)loadComments{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",artwork.IdOpera,@"IdOpera",@"YES",@"limit", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"]count] > 0) {
                                       comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                       [self commentsDidLoad];
                                   }
                                   else if([json objectForKey:@"error"]){
                                       [self commentsDidError];
                                   }
                               }];

}

- (void)commentsDidLoad{
    
    if (tableComments.boxes.count >= 1)
        [tableComments.boxes removeAllObjects];
    
    MGTableBoxStyled* comment = MGTableBoxStyled.box;
    [tableComments.boxes addObject:comment];

    MGLine* line = [MGLine lineWithLeft:@"Commenti Recenti" right:nil size:ROW_SIZE];
    line.font = HEADER_FONT;
    line.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    [comment.topLines addObject:line];
    
    for (NSDictionary* dict in comments) {
        
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
        commentLine.rightFont = RIGHT_FONT;
        commentLine.maxHeight = 60;

        CGSize minSize = [commentText sizeWithFont:LINE_FONT];
        CGFloat height = minSize.height + commentLine.padding.top + commentLine.padding.bottom;
        
        commentLine.size = (CGSize){304,height};

        [comment.topLines addObject:commentLine];
        
        profilePictureView.profileID = ([fbId isEqual:[NSNull null]]) ? nil : fbId;
        
        if ([dict isEqualToDictionary:[comments objectAtIndex:0]] && isNewComment) {
            
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
            [self performSegueWithIdentifier:@"DetailComment" sender:nil];
        
        };

    }
    
    MGLine* footer = [MGLine lineWithLeft:nil right:nil size:FOOTER_SIZE];
    [footer.middleItems addObject:@"Visualizza tutti i Commenti"];
    footer.sidePrecedence = MGSidePrecedenceMiddle;
    footer.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    footer.middleFont = HEADER_FONT;
    footer.middleItemsTextAlignment = NSTextAlignmentCenter;
    [comment.bottomLines addObject:footer];
    footer.layer.cornerRadius = 2;
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
    //footer.layer.shouldRasterize = YES;
    
    footer.onTap = ^{
        [self performSegueWithIdentifier:@"StreamComment" sender:nil];
    };
    
    /*UIButton* commentBtn = [self buttonWithTitle:@"Aggiungi un commento"];
    commentBtn.tag = 1;
    
    MGBox* boxButton = [MGBox boxWithSize:(CGSize){304,44}];
    [boxButton addSubview:commentBtn];
    boxButton.contentLayoutMode = MGBoxLayoutAttached;
    [tableComments.boxes addObject:boxButton];*/
    
    [tableComments layout];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
    if (isNewComment)[self.scroller scrollToView:comment withMargin:8];
    isNewComment = false;
    
}

- (void)commentsDidError{}


#pragma mark -
#pragma mark ===  Button  ===
#pragma mark -

- (UIButton *)buttonWithTitle:(NSString *)titleText{
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:titleText forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.size = CGSizeMake(250, 30);
    button.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, button.size.height / 2 + 8);
    
    button.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
    [button setBackgroundImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    
    // Btn shadow
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowRadius = 1;
    button.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    // Btn border
    button.layer.borderWidth = 0.35f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    
    //button.layer.shouldRasterize = YES;

    
    // Btn Font
    [button.titleLabel setFont:LINE_FONT];
    
    [button addTarget:self action:@selector(addContentFromButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark -
#pragma mark ===  Photo  ===
#pragma mark -

- (void)loadThumbPhotos{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",artwork.IdOpera,@"IdOpera",@"true",@"thumb", nil]
                               onCompletion:^(NSDictionary *json) {
                                   //Mostra lo stream
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"]count] > 0) {
                                       photos = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                       [self thumbPhotosDidLoad];
                                   }
                                   else if([json objectForKey:@"error"]){
                                       [self thumbPhotosDidError];
                                   }
                               }];

}


- (void)thumbPhotosDidLoad{
    
    if (photosGrid.boxes.count >= 1)
        [photosGrid.boxes removeAllObjects];
    
    
    MGTableBoxStyled* photosTable = MGTableBoxStyled.box;
    [photosGrid.boxes addObject:photosTable];
    
    MGLine* line = [MGLine lineWithLeft:@"Foto Recenti" right:nil size:ROW_SIZE];
    line.font = HEADER_FONT;
    line.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    [photosTable.topLines addObject:line];

    MGLine* streamLine = [MGLine lineWithSize:ROW_STREAM_FOTO_SIZE];
    [photosTable.topLines addObject:streamLine];
    streamLine.padding = UIEdgeInsetsMake(8, 0, 8, 8);
    streamLine.sidePrecedence = MGSidePrecedenceRight;
    //[streamLine.rightItems addObject:arrow];
    //streamLine.itemPadding = 2;
    
    for (NSDictionary* dict in photos) {
        
        [streamLine.leftItems addObject:[self streamThumbPhotoWithId:[dict objectForKey:@"IdPhoto"] andSize:IPHONE_PORTRAIT_PHOTO]];
        
        if ([dict isEqualToDictionary:[photos objectAtIndex:0]]) {
            
            [UIView animateWithDuration:0.2f
                                  delay:0.5f
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 streamLine.backgroundColor = [UIColor brownColor];
                                 streamLine.backgroundColor = [UIColor clearColor];
                             }
                             completion:nil];
        }
        
    }
    MGLine* footer = [MGLine lineWithLeft:nil right:nil size:FOOTER_SIZE];
    [footer.middleItems addObject:@"Visualizza tutte le Foto"];
    footer.sidePrecedence = MGSidePrecedenceMiddle;
    footer.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    footer.middleFont = HEADER_FONT;
    footer.middleItemsTextAlignment = NSTextAlignmentCenter;
    [photosTable.bottomLines addObject:footer];
    footer.layer.cornerRadius = 2;
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
    //footer.layer.shouldRasterize = YES;
    footer.onTap =^{
        
        [self performSegueWithIdentifier:@"ShowStream" sender:nil];
    
    };
    
   /* UIButton* photoBtn = [self buttonWithTitle:@"Aggiungi una foto"];
    photoBtn.tag = 2;

    MGBox* boxButton = [MGBox boxWithSize:(CGSize){304,44}];
    [boxButton addSubview:photoBtn];
    boxButton.contentLayoutMode = MGBoxLayoutAttached;
    [photosGrid.boxes addObject:boxButton];*/

    [photosGrid layout];
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
    if (isNewPhoto)[self.scroller scrollToView:photosTable withMargin:8];
    isNewPhoto = false;
}

- (void)thumbPhotosDidError{}

- (PhotoBox *)streamThumbPhotoWithId:(NSNumber *)idPhoto andSize:(CGSize)size{
    
    PhotoBox* box = [PhotoBox artWorkStreamWithPhotoId:idPhoto andSize:size];
    box.topMargin = 0;
    
    return box;
}

#pragma mark -
#pragma mark ===  Add Content  ===
#pragma mark -

- (void)addContentFromButton:(id)sender{
    
    UIButton* button = (UIButton *)sender;
    
    [self performSegueWithIdentifier:@"AddContent" sender:[NSNumber numberWithInteger:button.tag]];
}

#pragma mark -
#pragma mark ===  Storyboard  ===
#pragma mark -


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    /*  if ([@"ShowStream" compare:[segue identifier]] == NSOrderedSame) {
     
     StreamScreen* stream = [segue destinationViewController];
     [stream setArtWork:_artWork];
     
     self.navigationItem.title = nil;
     }
     
     if ([@"ShowContent" compare:segue.identifier] == NSOrderedSame) {
     
     UITableViewCell* cell = (UITableViewCell *)sender;
     ChunkViewController* chunk = [segue destinationViewController];
     chunk.chunk = cell.textLabel.text;
     chunk.IdChunk = [NSNumber numberWithInt:cell.tag];
     [chunk setIdOpera:_artWork.IdOpera];
     }*/
    
    
    if ([@"StreamComment" compare:segue.identifier] == NSOrderedSame) {
        UpdateViewController* update = segue.destinationViewController;
        [update setIdOpera:artwork.IdOpera];
    }
    
    if ([@"AddContent" compare:[segue identifier]] == NSOrderedSame) {
        
        //int tagButton = [(NSNumber *)sender intValue];
        
        UINavigationController* viewController = segue.destinationViewController;
        AddContentViewController* contentViewController = (AddContentViewController *)viewController.topViewController;
        contentViewController.artWork = [artwork copy];
        contentViewController.delegate = self;
        contentViewController.isAddComment = true;
        contentViewController.isAddPhoto = true;
        contentViewController.isChunck = false;
        
        /*switch (tagButton) {
            case 1:
                contentViewController.isAddComment = true;
                break;
            case 2:
                contentViewController.isAddPhoto = true;
                break;
            default:
                break;
        }*/
    }
    
}


#pragma mark -
#pragma mark ===  Add Content Delegate Methods  ===
#pragma mark -

- (void)contentDidLoad:(bool)newPhoto isComment:(bool)newComment{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    if (newComment) {
        [self performSelector:@selector(loadComments) withObject:nil afterDelay:1.6f];
        isNewComment = true;
    }
    
    if (newPhoto) {
        [self performSelector:@selector(loadThumbPhotos) withObject:nil afterDelay:1.6f];
        isNewPhoto = true;
    }
}
/*- (void)submitCommentDidPressed:(id)sender{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    [self performSelector:@selector(loadComments) withObject:nil afterDelay:1.6f];
    isNewComment = true;
    
}

- (void)submitPhotoDidPressed:(id)sender{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    [self performSelector:@selector(loadThumbPhotos) withObject:nil afterDelay:1.6f];
    isNewPhoto = true;
}
*/
@end
