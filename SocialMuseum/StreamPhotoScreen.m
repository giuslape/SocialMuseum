//
//  StreamPhotoScreen.m
//  Social Museum
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "StreamPhotoScreen.h"
#import "API.h"
#import "MGLine.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PhotoBox.h"
#import "ProfileViewController.h"
#import "NSString+Date.h"
#import "ArtWork.h"
#import "ProfileViewController.h"

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:10]
#define ROW_SIZE               (CGSize){self.view.bounds.size.width, 44}

static NSUInteger kNumberOfPages;

@implementation StreamPhotoScreen{
    
    MGBox* footerBox;
    FBProfilePictureView* profilePictureView;
}

@synthesize viewControllers, scrollView, firstPage;


-(void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    contentList = [[API sharedInstance] temporaryPhotosInfo];
    kNumberOfPages = [contentList count];
    
    NSMutableArray* controllers = [[NSMutableArray alloc] init];
    
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    
    self.viewControllers = controllers;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    [self loadScrollViewWithPage:[firstPage intValue]];

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

-(void)loadPhotoDetails:(NSDictionary *)infos inBox:(MGBox *)footer{
    
    
    MGTableBoxStyled* table = MGTableBoxStyled.box;
    [footer.boxes addObject:table];
    table.leftMargin = table.topMargin = 0;
    
    
    FBProfilePictureView* pictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];

    MGLine* line = [MGLine lineWithSize:(CGSize){self.view.bounds.size.width,48}];
    [line.leftItems addObject:[PhotoBox photoProfileBoxWithView:pictureView andSize:(CGSize){35,35}]];
    
    NSString* username = [infos objectForKey:@"username"];
    NSString* artWorkName = [[API sharedInstance] temporaryArtWork].title;
    
    [line.leftItems addObject:[NSString stringWithFormat:@"%@\nscattata nei pressi di %@",username,artWorkName]];
     
    NSString* datetime = [infos objectForKey:@"datetime"];
    
    NSString* temporalDifferences = [NSString determingTemporalDifferencesFromNowtoStartDate:datetime];
    [line.rightItems addObject:temporalDifferences];
    line.rightFont = HEADER_FONT;
    line.sidePrecedence = MGSidePrecedenceRight;
    
    line.topPadding  = 8;
    line.itemPadding = 8;
    [table.topLines addObject:line];
    line.font = HEADER_FONT;
    
    NSString* fbId = [infos objectForKey:@"FBId"];
    NSString* profileId = (fbId) ? fbId : nil;
    pictureView.profileID = profileId;
    
    [footer layout];
}

-(void)waitingForLoadPhoto:(UIImageView *)imageView{

    // add a loading spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.transform = CGAffineTransformMakeScale(2.0, 2.0);
    spinner.center = CGPointMake(scrollView.size.width / 2, scrollView.size.height / 2);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    spinner.color = UIColor.lightGrayColor;
    [imageView addSubview:spinner];
    [spinner startAnimating];

}

- (void)loadPhotoWithId:(NSNumber *)idPhoto andView:(UIImageView *)imageView{
        
        //Carica l'img
        API* api = [API sharedInstance];
        
        NSURL* imageURL = [api urlForImageWithId:idPhoto isThumb:NO];
        
        AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
            
            // Elimina lo spinner
            UIActivityIndicatorView *spinner = imageView.subviews.lastObject;
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
            imageView.image = image;
            imageView.alpha = 0;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
            
            // fade the image in
            [UIView animateWithDuration:0.2 animations:^{
                imageView.alpha = 1;
            }];
            
        }];
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        [queue addOperation:imageOperation];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"ShowProfile" compare:segue.identifier] == NSOrderedSame) {
        
        ProfileViewController* profile = segue.destinationViewController;
        profile.hiddenRightButton = YES;
    }
    
}

#pragma mark -
#pragma mark ===  Load Page  ===
#pragma mark -

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    UIImageView* imageView = [viewControllers objectAtIndex:page];
    
    if ((NSNull *)imageView == [NSNull null])
    {
        imageView = [[UIImageView alloc] init];
        //imageView.contentMode = UIViewContentModeScaleToFill;
        [viewControllers replaceObjectAtIndex:page withObject:imageView];
    }
    
    // add the controller's view to the scroll view
    if (imageView.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        frame.size.height = scrollView.size.height;
        imageView.frame = frame;
        [scrollView addSubview:imageView];
        
        NSDictionary *item = [contentList objectAtIndex:page];
        
        NSNumber* idPhoto = [NSNumber numberWithInt:[[item objectForKey:@"IdPhoto"] intValue]];
        [self waitingForLoadPhoto:imageView];
        [self loadPhotoWithId:idPhoto andView:imageView];
        
        MGBox* footer = [MGBox boxWithSize:ROW_SIZE];
        footer.origin = (CGPoint){scrollView.frame.size.width * page,0};
        [scrollView addSubview:footer];
                
        [self loadPhotoDetails:item inBox:footer];

        [footer layout];

        id block = self;
        footer.onTap = ^{
            [block performSegueWithIdentifier:@"ShowProfile" sender:nil];
        };

        if (page > 0) {
            CGRect frame = scrollView.frame;
            frame.origin.x = frame.size.width * page;
            frame.origin.y = 0;
            [scrollView scrollRectToVisible:frame animated:YES];
        }
        
    }
    
}

#pragma mark -
#pragma mark ===  Scroll Delegate  ===
#pragma mark -


- (void)scrollViewDidScroll:(UIScrollView *)sender
{
 
	
        
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    //[self loadScrollViewWithPage:page + 1];

}

@end
