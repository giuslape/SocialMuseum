//
//  StreamScreen.m
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "StreamScreen.h"
#import "API.h"
#import "StreamPhotoScreen.h"
#import "PhotoScreen.h"
#import "PullToRefreshView.h"
#import "MGScrollView.h"
#import "PhotoBox.h"
#import "ArtWork.h"

#define IPHONE_PORTRAIT_PHOTO  (CGSize){148, 148}
#define IPHONE_LANDSCAPE_PHOTO (CGSize){152, 152}

#define IPAD_PORTRAIT_PHOTO    (CGSize){128, 128}
#define IPAD_LANDSCAPE_PHOTO   (CGSize){122, 122}

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPAD_PORTRAIT_GRID     (CGSize){136, 0}
#define IPAD_LANDSCAPE_GRID    (CGSize){390, 0}
#define IPHONE_LANDSCAPE_GRID  (CGSize){160, 0}



@interface StreamScreen(){
    
    MGBox *photosGrid;
}

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation StreamScreen

@synthesize artWork, items = _items;


#pragma mark -
#pragma mark ===  dealloc  ===
#pragma mark -

- (void)dealloc {
   
    self.items = nil;
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    self.items = [NSMutableArray array];

    self.navigationItem.title = @"Foto";
    
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;

    // setup the main scroller (using a grid layout)
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    // iPhone or iPad grid?
    CGSize photosGridSize = phone ? IPHONE_PORTRAIT_GRID : IPAD_PORTRAIT_GRID;
    
    // the photos grid
    photosGrid = [MGBox boxWithSize:photosGridSize];
    photosGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:photosGrid];

    [self loadDataSource];

    __block StreamScreen * blockSelf = self;

    [self.scroller addPullToRefreshWithActionHandler:^{
        [blockSelf loadDataSource];
    }];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[API sharedInstance] setTemporaryPhotosInfo:nil];
    self.scroller.pullToRefreshView = nil;
    self.scroller = nil;
}

    
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - Rotation and resizing


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    BOOL portrait = UIInterfaceOrientationIsPortrait(orient);
    
    // grid size
    photosGrid.size = phone ? portrait
    ? IPHONE_PORTRAIT_GRID
    : IPHONE_LANDSCAPE_GRID : portrait
    ? IPAD_PORTRAIT_GRID
    : IPAD_LANDSCAPE_GRID;
    
    // photo sizes
    CGSize size = phone
    ? portrait ? IPHONE_PORTRAIT_PHOTO : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;
    
    // apply to each photo
    for (MGBox *photo in photosGrid.boxes) {
        photo.size = size;
        photo.layer.shadowPath
        = [UIBezierPath bezierPathWithRect:photo.bounds].CGPath;
        photo.layer.shadowOpacity = 0;
    }
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient {
    for (MGBox *photo in photosGrid.boxes) {
        photo.layer.shadowOpacity = 1;
    }
}

- (void)loadDataSource {
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",artWork.IdOpera,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		self.items = [json objectForKey:@"result"];
        if ([self.items count] > 0)
            [self dataSourceDidLoad];
        else 
            [self dataSourceDidError];
        [self.scroller.pullToRefreshView stopAnimating];
	}];
        
}

- (void)dataSourceDidLoad {
    
    [photosGrid.boxes removeAllObjects];
    
    [[API sharedInstance] setTemporaryPhotosInfo:self.items];
    
    //NSEnumerator* enumerator = [self.items ];
    
    for (NSDictionary* dict in self.items){
        
        int index = [self.items indexOfObject:dict];
        
        [photosGrid.boxes addObject:[self photoBoxFor:dict andTag:index]];
    }
    
    
    [photosGrid layoutWithSpeed:0.3 completion:nil];
    [self.scroller layoutWithSpeed:0.3 completion:nil];
}

- (void)dataSourceDidError {
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([@"ShowPhoto" compare: segue.identifier]== NSOrderedSame) {
        sender = (NSNumber *)sender;
        StreamPhotoScreen* streamPhotoScreen = segue.destinationViewController;
        streamPhotoScreen.firstPage = sender;
    }
    
    if ([@"AddPhoto" compare:[segue identifier]] == NSOrderedSame) {
                
        UINavigationController* viewController = segue.destinationViewController;
        AddContentViewController* contentViewController = (AddContentViewController *)viewController.topViewController;
        contentViewController.artWork = [artWork copy];
        contentViewController.delegate = self;
        contentViewController.isAddPhoto = true;
        contentViewController.isAddComment = false;
        contentViewController.isChunck = false;
    }

    
}

#pragma mark -
#pragma mark ===  PhotoBox  ===
#pragma mark -

#pragma mark - Photo Box factories

- (CGSize)photoBoxSize {
    BOOL portrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    // what size plz?
    return phone
    ? portrait ? IPHONE_PORTRAIT_PHOTO : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;
}


-(MGBox *)photoBoxFor:(NSDictionary *)dict andTag:(int)tag{
    
    NSNumber* idPhoto = [NSNumber numberWithInt:[[dict objectForKey:@"IdPhoto"]intValue]];

    // make the box
    PhotoBox *box = [PhotoBox artWorkStreamWithPhotoId:idPhoto andSize:[self photoBoxSize]];
      // deal with taps
     box.onTap = ^{
                  
         NSString* username = [dict objectForKey:@"username"];
         
         NSNumber* idUser = [NSNumber numberWithInt:[[dict objectForKey:@"IdUser"] intValue]];
         
         NSString* fbId = ([[dict objectForKey:@"FBId"]intValue]> 0) ?
         [dict objectForKey:@"FBId"] : [NSNull null];

         [[API sharedInstance] setTemporaryUser:@{@"IdUser" : idUser, @"username" : username, @"FBId" : fbId}];
         [[API sharedInstance] setTemporaryPhoto:dict];
        [self performSegueWithIdentifier:@"ShowPhoto" sender:[NSNumber numberWithInt:tag]];
     };
    
    return box;
}

#pragma mark -
#pragma mark ===  Add Content Delegate  ===
#pragma mark -

- (void)contentDidLoad:(bool)newPhoto isComment:(bool)newComment{
    
    AddContentViewController* contentViewController = (AddContentViewController *)[self presentedViewController];
    [contentViewController performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.3];
    
    [self performSelector:@selector(loadDataSource) withObject:nil afterDelay:1.6f];
}

/*- (IBAction)photoBtnDidPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"AddContent" sender:nil];
    
}*/
@end



