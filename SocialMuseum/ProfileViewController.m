//
//  ProfileViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ProfileViewController.h"
#import "API.h"
#import "UIAlertView+error.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"
#import "SMPhotoView.h"

#define MARGIN 30

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerPhoto;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) CollectionView *collectionView;
@end

@implementation ProfileViewController

@synthesize userNameLabel;
@synthesize userProfileImage;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.items = [NSMutableArray array];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 2000)];
    self.headerPhoto.backgroundColor = [UIColor grayColor];
    
    self.collectionView = [[CollectionView alloc] initWithFrame:CGRectMake(0, self.headerPhoto.frame.origin.y + self.headerPhoto.frame.size.height + MARGIN, self.view.frame.size.width, 0)];
    
    [scroller addSubview:self.collectionView];
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor blueColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.scrollEnabled = NO;
    
    self.collectionView.numColsPortrait = 2;
    self.collectionView.numColsLandscape = 3;
    
    __block ProfileViewController * blockSelf = self;
    
    [scroller addPullToRefreshWithActionHandler:^{
        
        [blockSelf loadDataSource];
    }];
    
}

- (void)loadDataSource {
    
    [self populateUserDetails];
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"userStream", @"command",[[[API sharedInstance] user] objectForKey:@"IdUser"],@"IdUser", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   if (![json objectForKey:@"error"] && [[json objectForKey:@"result"] count] > 0) {
                                       
                                       self.items = [json objectForKey:@"result"];
                                       if ([self.items count] > 0)
                                           [self dataSourceDidLoad];
                                       else
                                           [self dataSourceDidError];
                                      
                                   }
                                   [MBProgressHUD hideHUDForView:scroller animated:YES];
                                   [scroller.pullToRefreshView stopAnimating];
                                   
                               }];
}

- (void)dataSourceDidLoad {
    [self.collectionView reloadData];
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.view.frame.size.width, self.collectionView.contentSize.height);
}

- (void)dataSourceDidError {
    [self.collectionView reloadData];
}

- (void)viewDidUnload
{
    [self setUserNameLabel:nil];
    [self setUserProfileImage:nil];
    scroller = nil;
    self.collectionView.delegate = nil;
    self.collectionView.collectionViewDelegate = nil;
    self.collectionView.collectionViewDataSource = nil;
    
    self.collectionView = nil;
    self.items = nil;

    [self setHeaderPhoto:nil];
    [super viewDidUnload];
   
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:scroller animated:YES];
    [hud setLabelText:@"Loading..."];
    [hud setDimBackground:YES];
    [hud show:YES];

    [self performSelector:@selector(loadDataSource) withObject:nil afterDelay:1];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)populateUserDetails 
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, 
           NSDictionary<FBGraphUser> *user, 
           NSError *error) {
             if (!error) {
                 
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = user.id;
             }
         }];      
    }
    else {
        
            NSString* nameUser = [[[API sharedInstance] user] objectForKey:@"username"];
        
            self.userNameLabel.text = nameUser;
            self.userProfileImage.profileID = nil;
           
    }
}

- (IBAction)logoutButtonWasPressed:(id)sender {
    
    [self unloadImages];

    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else {
        NSString* command = @"logout";
        NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command",nil];
        //chiama l'API web
        [[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
            //Mostra Messaggio
            
            [[API sharedInstance] setUser:nil];
            self.userNameLabel.text = nil;
            
            AppDelegate* delegate = [UIApplication sharedApplication].delegate;
            
            [delegate logoutHandler];
            
        }];
    
    }
        
}

-(void)unloadImages{
    
    for (UIImageView* image in scroller.subviews) {
        
        if ([image isMemberOfClass:[UIView class]] || [image isMemberOfClass:[UILabel class]])continue;
        [image removeFromSuperview];
    }
    
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
    
  /*  NSDictionary *item = [self.items objectAtIndex:index];
    
    [self performSegueWithIdentifier:@"ShowPhoto" sender:[NSNumber numberWithInt:[[item objectForKey:@"IdPhoto"]intValue]]];*/
}


@end
