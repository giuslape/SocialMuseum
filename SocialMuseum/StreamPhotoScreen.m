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


@implementation StreamPhotoScreen{
    MGBox* footerBox;
    FBProfilePictureView* profilePictureView;
    
    NSDictionary* photoDetails;
}


-(void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    photoDetails = [[API sharedInstance] temporaryPhoto];
    
    profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
    [self waitingForLoadPhoto];
    
    [self performSelector:@selector(loadPhoto) withObject:nil afterDelay:1.0f];
        
    footerBox = [MGBox boxWithSize:ROW_SIZE];
    [self.view addSubview:footerBox];
    footerBox.origin = (CGPoint){0,self.view.bounds.origin.y + photoView.size.height};
    
    [self loadPhotoDetails];
    
    [footerBox layout];
    
    id block = self;
    footerBox.onTap = ^{
        [block performSegueWithIdentifier:@"ShowProfile" sender:nil];
    };
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)loadPhotoDetails{
    
    MGTableBoxStyled* table = MGTableBoxStyled.box;
    [footerBox.boxes addObject:table];
    table.leftMargin = table.topMargin = 0;
    
    MGLine* line = [MGLine lineWithSize:(CGSize){self.view.bounds.size.width,48}];
    [line.leftItems addObject:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){35,35}]];
    
    NSString* username = [[[API sharedInstance] temporaryUser] objectForKey:@"username"];
    NSString* artWorkName = [[API sharedInstance] temporaryArtWork].title;
    
    [line.leftItems addObject:[NSString stringWithFormat:@"%@ \nscattata nei pressi di %@",username,artWorkName]];
     
    NSString* datetime = [photoDetails objectForKey:@"datetime"];
    
    NSString* temporalDifferences = [NSString determingTemporalDifferencesFromNowtoStartDate:datetime];
    [line.rightItems addObject:temporalDifferences];
    line.rightFont = HEADER_FONT;
    line.sidePrecedence = MGSidePrecedenceRight;
    
    line.topPadding  = 8;
    line.itemPadding = 8;
    [table.topLines addObject:line];
    line.font = HEADER_FONT;
    
    NSString* fbId = [[[API sharedInstance] temporaryUser] objectForKey:@"FBId"];
   // NSString* profileId = (fbId) ? fbId : nil;
    profilePictureView.profileID = fbId;
}

-(void)waitingForLoadPhoto{

    // add a loading spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.transform = CGAffineTransformMakeScale(2.0, 2.0);
    spinner.center = CGPointMake(photoView.width / 2, photoView.height / 2);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    spinner.color = UIColor.lightGrayColor;
    [photoView addSubview:spinner];
    [spinner startAnimating];

}

- (void)loadPhoto{
        
        //Carica l'img
        API* api = [API sharedInstance];
        
        NSURL* imageURL = [api urlForImageWithId:[photoDetails objectForKey:@"IdPhoto"] isThumb:NO];
        
        AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
            
            // Elimina lo spinner
            UIActivityIndicatorView *spinner = photoView.subviews.lastObject;
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
            photoView.image = image;
            photoView.alpha = 0;
            photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
            
            // fade the image in
            [UIView animateWithDuration:0.2 animations:^{
                photoView.alpha = 1;
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

@end
