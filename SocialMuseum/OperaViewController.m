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

@interface OperaViewController ()

-(void)showPhotos:(NSArray *)stream;

@end


#define kThumb 30
#define kPad 3

@implementation OperaViewController

@synthesize artworkImage = _artworkImage;

@synthesize photoView = _photoView;
@synthesize artWork = _artWork;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.artworkImage.image = self.artWork.image;
}


- (void)viewDidUnload
{
    [self setArtworkImage:nil];
    [self setPhotoView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationItem.title = self.artWork.title;
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"stream", @"command",_artWork.IdOpera,@"IdOpera", nil] onCompletion:^(NSDictionary *json) {
        //Mostra lo stream
		[self showPhotos:[json objectForKey:@"result"]];
	}];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setArtWork:(ArtWork *)art{
        
    _artWork = art;

}

#pragma mark -
#pragma mark ===  Table View Delegate  ===
#pragma mark -

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"ShowStream" compare:[segue identifier]] == NSOrderedSame) {
        
        StreamScreen* stream = [segue destinationViewController];
        stream.navigationItem.title = _artWork.title;
        [stream setIdOpera:_artWork.IdOpera];
        
        self.navigationItem.title = nil;
    }
    
}


#pragma mark -
#pragma mark ===  Stream Photo  ===
#pragma mark -

-(void)showPhotos:(NSArray *)stream{
    
    for (UIView* view in _photoView.subviews) {
        [view removeFromSuperview];
    }
    API* api = [API sharedInstance];
    
    
    
    for (int i=0;i<[stream count];i++) {
        
        NSDictionary* photo = [stream objectAtIndex:i];
        
		int IdPhoto = [[photo objectForKey:@"IdPhoto"] intValue];
        int col = i%5;
        NSURL* imageURL = [api urlForImageWithId:[NSNumber numberWithInt: IdPhoto] isThumb:YES];
		AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
			//Crea ImageView e l'aggiunge alla vista
			UIImageView* thumbView = [[UIImageView alloc] initWithImage: image];
            thumbView.frame = CGRectMake(1.5*kPad+col*(kThumb+kPad), kPad, kThumb, kThumb);
			[_photoView addSubview:thumbView];
		}];
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
		[queue addOperation:imageOperation];
    }      
}

@end
