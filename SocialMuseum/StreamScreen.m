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
#import "SMPhotoView.h"

@interface StreamScreen()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) CollectionView *collectionView;

@end

@implementation StreamScreen

@synthesize IdOpera, items = _items,collectionView = _collectionView;


#pragma mark -
#pragma mark ===  dealloc  ===
#pragma mark -

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.collectionViewDelegate = nil;
    self.collectionView.collectionViewDataSource = nil;
    
    self.collectionView = nil;
    self.items = nil;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = btnCompose;
    self.navigationItem.title = @"Foto";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.collectionView = [[CollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.collectionView];
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
       
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
    loadingLabel.text = @"Loading...";
    loadingLabel.textAlignment = UITextAlignmentCenter;
    self.collectionView.loadingView = loadingLabel;
    
    self.collectionView.numColsPortrait = 2;
    self.collectionView.numColsLandscape = 3;
    
    [self loadDataSource];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.collectionView.delegate = nil;
    self.collectionView.collectionViewDelegate = nil;
    self.collectionView.collectionViewDataSource = nil;
    
    self.collectionView = nil;
}

    
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(IBAction)btnRefreshTapped {
}

- (void)loadDataSource {
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",IdOpera,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		self.items = [json objectForKey:@"result"];
        if ([self.items count] > 0)
            [self dataSourceDidLoad];
        else 
            [self dataSourceDidError];
        
	}];
        
}

- (void)dataSourceDidLoad {
    [self.collectionView reloadData];
}

- (void)dataSourceDidError {
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark ===  Delegate Methods  ===
#pragma mark -


- (NSInteger)numberOfViewsInCollectionView:(CollectionView *)collectionView {
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
    
    //    NSDictionary *item = [self.items objectAtIndex:index];
    
    // You can do something when the user taps on a collectionViewCell here
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"ShowPhoto" compare: segue.identifier]==NSOrderedSame) {
        StreamPhotoScreen* streamPhotoScreen = segue.destinationViewController;
        streamPhotoScreen.IdPhoto = sender;
    }
    if ([@"ShowScreen" compare: segue.identifier] == NSOrderedSame) {
        PhotoScreen* photoScreen = segue.destinationViewController;
        photoScreen.IdOpera = self.IdOpera;
    }
}

@end



