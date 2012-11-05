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

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:10]
#define ROW_SIZE               (CGSize){self.view.bounds.size.width, 44}


@implementation StreamPhotoScreen{
    MGBox* footerBox;
    FBProfilePictureView* profilePictureView;
}

@synthesize IdPhoto, IdUser, username, artWorkName, datetime;


-(void)viewDidLoad {
    
    profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
    [self waitingForLoadPhoto];
    
    [self performSelector:@selector(loadPhoto) withObject:nil afterDelay:1.0f];
        
    footerBox = [MGBox boxWithSize:ROW_SIZE];
    [self.view addSubview:footerBox];
    footerBox.origin = (CGPoint){0,self.view.bounds.origin.y + photoView.size.height};
    footerBox.backgroundColor = [UIColor blueColor];
    
    [self loadPhotoDetails];
    
    [footerBox layout];
    
    footerBox.onTap = ^{
    
        NSLog(@"Sto Cliccado sul Box");
        
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
    
    MGLine* line = [MGLine lineWithSize:(CGSize){self.view.bounds.size.width,42}];
    [line.leftItems addObject:[PhotoBox photoProfileBoxWithView:profilePictureView andSize:(CGSize){35,35}]];
    line.multilineMiddle = [NSString stringWithFormat:@"%@ ha scattato una foto nei pressi di %@",username, artWorkName];
    
    
    line.multilineRight = [NSString stringWithFormat:@"%@ \n",datetime];
    line.rightFont = HEADER_FONT;
    line.middleItemsTextAlignment = UITextAlignmentLeft;
    line.sidePrecedence = MGSidePrecedenceRight;
    
    line.leftPadding = line.topPadding = 4;
    [table.topLines addObject:line];
    line.font = HEADER_FONT;
    
    profilePictureView.profileID = [NSString stringWithFormat:@"%d",[IdUser intValue]];
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
        
        NSURL* imageURL = [api urlForImageWithId:IdPhoto isThumb:NO];
        
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
@end
