//
//  CoverFlowViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "ArtWorkViewController.h"
#import "ArtWorkViewController.h"

@implementation CoverFlowViewController

@synthesize dao;
@synthesize textView;
@synthesize flowView = _flowView;

-(id<OpereDao>)dao{
    
    if (!dao) {
        
        dao = [[OpereDaoXML alloc] init];
    }
    
    return dao;
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

 */
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)viewWillAppear:(BOOL)animated{
    
    if (!self.navigationController.navigationBarHidden)
        self.navigationController.navigationBarHidden = YES;
    
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"Opera"]) {
    
    ArtWorkViewController* artworkViewController = segue.destinationViewController;
    
        ArtWork* artWork = [[ArtWork alloc] init];
        
        NSDictionary* artWorkFeatures = [_artWorks objectForKey:[NSNumber numberWithInt:_indexArtWork]];
        
        NSString* filename = [artWorkFeatures objectForKey:@"filename"];
        
        artWork.image = [UIImage imageNamed:filename];
        
        artworkViewController.artWorkToModify = artWork;
    
    }

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _flowView = (AFOpenFlowView *)[[self.view subviews] objectAtIndex:0];

    _artWorks = (NSMutableDictionary *)[self.dao loadArtWorks];
    
    int numberOfImages = [_artWorks count];
        
    for (id index in _artWorks) {
        
        id artWorkFeatures = [_artWorks objectForKey:index];
        
        NSString* filename = [artWorkFeatures objectForKey:@"filename"];
        
        NSString* title = [artWorkFeatures objectForKey:@"title"];
        
		[_flowView setImage:[UIImage imageNamed:filename]
                  forIndex:[index intValue]];
        
        [_flowView setDescription:[artWorkFeatures objectForKey:@"description"]
                    forIndex:[index intValue]];
        
        [_flowView setTitle:title
                  forIndex:[index intValue]];
        
	}
    
    id dictTemp = [_artWorks objectForKey:[NSNumber numberWithInt:0]];
        
    NSString* descriptionTemp = [dictTemp objectForKey:@"description"];
    
    self.textView.text = descriptionTemp;
    
    [_flowView setNumberOfImages:numberOfImages];
        
    [_flowView setViewDelegate:self];
    
    [_flowView setDataSource:self];
    
    UISearchBar* mySearchBar = (UISearchBar *)[[self.view subviews] objectAtIndex:1];
    
    mySearchBar.delegate = self;
}


#pragma mark -
#pragma mark ===  Delegate Methods Open Flow  ===
#pragma mark -

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
	
    textView.text = [[openFlowView selectedCoverView] descriptionItem];
    
    _indexArtWork = index;

	NSLog(@"%@ %d is selected",NSStringFromSelector(_cmd),index);

	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index{
    
    
    NSLog(@"%@ %d is request", NSStringFromSelector(_cmd), index);
    
    
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidSame:(int)index{
    
    NSLog(@"%@ %d", NSStringFromSelector(_cmd), index);
    
}


- (UIImage *)defaultImage{
	
	return [UIImage imageNamed:@"cover_1.jpg"];
}
- (void)viewDidUnload
{
    [self setFlowView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark ===  Delegate Methods Search Bar  ===
#pragma mark -


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    searchBar.showsCancelButton = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [_flowView searchItemFromText:searchText];
    
}


@end
