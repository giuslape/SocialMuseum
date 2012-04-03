//
//  ArtWorkViewController.m
//  SocialMuseum
//
//  Created by Vincenzo Lapenta on 26/01/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ArtWorkViewController.h"

@implementation ArtWorkViewController


@synthesize artWorkImage;
@synthesize artWorkToModify = _artWorkToModify;
@synthesize label;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
        
    self.artWorkImage.image = _artWorkToModify.image;
    
    [self.artWorkImage sizeThatFits:_artWorkToModify.image.size];
    
    
}


- (void)viewDidUnload
{
    [self setArtWorkImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setArtWorkToModify:(ArtWork *)artWorkToModify{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _artWorkToModify = artWorkToModify;

}
@end
