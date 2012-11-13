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
#import "MGLine.h"
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

@synthesize artWork = _artWork, items = _items;


#pragma mark -
#pragma mark ===  dealloc  ===
#pragma mark -

- (void)dealloc {
   
    self.items = nil;
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];

    self.navigationItem.rightBarButtonItem = btnCompose;
    self.navigationItem.title = @"Foto";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
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
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",_artWork.IdOpera,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
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
    
    NSEnumerator* enumerator = [self.items reverseObjectEnumerator];
    
    for (NSDictionary* dict in enumerator) {
        
        NSArray* array;
        NSNumber* idPhoto = [NSNumber numberWithInt:[[dict objectForKey:@"IdPhoto"]intValue]];
        NSString* username = [dict objectForKey:@"username"];
        NSString* artWorkName = _artWork.title;
        
        NSString* fbId = ([[dict objectForKey:@"FBId"]intValue]> 0) ?
        [dict objectForKey:@"FBId"] : [NSNull null];
        
        NSNumber* Idu = [NSNumber numberWithInt:[[dict objectForKey:@"IdUser"]intValue]];
        
        NSString* datetime = [dict objectForKey:@"datetime"];
        array = [NSArray arrayWithObjects:idPhoto,username,artWorkName,fbId,datetime,Idu,nil];
        
        [photosGrid.boxes addObject:[self photoBoxFor:array]];
        [photosGrid layout];
    }
    [photosGrid layoutWithSpeed:0.3 completion:nil];
    [self.scroller layoutWithSpeed:0.3 completion:nil];
}

- (void)dataSourceDidError {
    
}

#pragma mark -
#pragma mark ===  Delegate Methods  ===
#pragma mark -


/*- (NSInteger)numberOfViewsInCollectionView:(CollectionView *)collectionView {
    return [self.items count];
}

- (CollectionViewCell *)collectionView:(CollectionView *)collectionView viewAtIndex:(NSInteger)index {
    
    NSDictionary *item = [self.items objectAtIndex:index];
    
    SMPhotoView *v = (SMPhotoView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[SMPhotoView alloc] initWithFrame:CGRectZero];
    }
    
    [v fillViewWithObject:item];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [SMPhotoView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(CollectionView *)collectionView didSelectView:(CollectionViewCell *)view atIndex:(NSInteger)index {
    
    NSDictionary *item = [self.items objectAtIndex:index];
    
    [self performSegueWithIdentifier:@"ShowPhoto" sender:[NSNumber numberWithInt:[[item objectForKey:@"IdPhoto"]intValue]]];
}*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([@"ShowPhoto" compare: segue.identifier]== NSOrderedSame) {
        sender = (NSArray *)sender;
        StreamPhotoScreen* streamPhotoScreen = segue.destinationViewController;
        streamPhotoScreen.IdPhoto =     [sender objectAtIndex:0];
        NSString* username =    [sender objectAtIndex:1];
        streamPhotoScreen.artWorkName = [sender objectAtIndex:2];
        NSString* fbId =        [sender objectAtIndex:3];
        streamPhotoScreen.datetime =    [sender objectAtIndex:4];
        NSNumber* IdUser =      [sender objectAtIndex:5];
        
        NSDictionary* userTemp = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",fbId,@"FBId",IdUser,@"IdUser", nil];
        [[API sharedInstance] setTemporaryUser:userTemp];

    }
    if ([@"ShowScreen" compare: segue.identifier] == NSOrderedSame) {
        PhotoScreen* photoScreen = segue.destinationViewController;
        [photoScreen setIdOpera:_artWork.IdOpera];
    }
}

-(void)setArtWork:(ArtWork *)artWork{
    
    _artWork = artWork;
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


-(MGBox *)photoBoxFor:(NSArray *)informations{
    
    NSNumber* idPhoto = [informations objectAtIndex:0];
    // make the box
    PhotoBox *box = [PhotoBox artWorkStreamWithPhotoId:idPhoto andSize:[self photoBoxSize]];
      // deal with taps
     box.onTap = ^{
        [self performSegueWithIdentifier:@"ShowPhoto" sender:informations];
     };
    
    return box;
}


@end



