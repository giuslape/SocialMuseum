//
//  ChunkViewController.m
//  SocialMuseum
//
//  Created by Vincenzo Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ChunkViewController.h"
#import "AddCommentViewController.h"

#define MAX_HEIGHT 2000

@interface ChunkViewController ()

@end

@implementation ChunkViewController
@synthesize textView, chunk = _chunk, IdChunk = _IdChunk;
@synthesize IdOpera = _IdOpera;

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
	// Do any additional setup after loading the view.
        
    // Adatta l'altezza della Vista al testo
    CGSize size = [_chunk sizeWithFont:[UIFont systemFontOfSize:12] 
       constrainedToSize:CGSizeMake(320, MAX_HEIGHT) 
           lineBreakMode:UILineBreakModeWordWrap];
    [textView sizeThatFits:size];

 
   // [textView setFrame:CGRectMake(0, 10, 320, size.height + 10)];
    textView.text = _chunk;
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)setChunk:(NSString *)chunk{

    _chunk = chunk;

}

-(void)setIdChunk:(NSNumber *)IdChunk{
    
    _IdChunk = IdChunk;
    
}

-(void)setIdOpera:(NSNumber *)IdOpera{
    
    _IdOpera = IdOpera;
}


#pragma mark -
#pragma mark ===  Add Comment Delegate  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddComment"])
    {        
        AddCommentViewController*addCommentViewController = segue.destinationViewController;
        [addCommentViewController setIdChunk:_IdChunk];
        [addCommentViewController setIdOpera:_IdOpera];
        
       // addCommentViewController.delegate = self;
    }
}


/*
-(void)addCommentDidCancel:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void)addCommentDidSave:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
    
}*/


@end
