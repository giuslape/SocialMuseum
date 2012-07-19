//
//  OperaViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "OperaViewController.h"
#import "StreamScreen.h"

@interface OperaViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation OperaViewController

@synthesize containerView = _containerView;

@synthesize artworkImage = _artworkImage;

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
    [self setContainerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationItem.title = self.artWork.title;

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

@end
