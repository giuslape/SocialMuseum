//
//  AddCommentViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "AddCommentViewController.h"
#import "API.h"
#import "UIAlertView+error.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

@synthesize delegate;
@synthesize commentView;
@synthesize IdChunk = _IdChunk;
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
    if (![[API sharedInstance] isAuthorized]) {
		[self performSegueWithIdentifier:@"ShowLogin" sender:nil];
	}

}

- (void)viewDidUnload
{
    delegate = nil;
    [self setCommentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender {
    
    //Carica il commento sul server
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"addComment", @"command",commentView.text,@"testo",_IdOpera,@"IdOpera",_IdChunk,@"IdChunk",nil] onCompletion:^(NSDictionary *json) {
		//Completamento
		if (![json objectForKey:@"error"]) {
			//Successo
			[[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Your comment is uploaded" delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles: nil] show];
            [self.navigationController popViewControllerAnimated:YES];
			
		} else {
			//Errore, Cerca se la sessione è scaduta e se l'utente è autorizzato
			NSString* errorMsg = [json objectForKey:@"error"];
			[UIAlertView error:errorMsg];
			if ([@"Authorization required" compare:errorMsg]==NSOrderedSame) {
				[self performSegueWithIdentifier:@"ShowLogin" sender:nil];
			}
		}
	}];
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ===  Set Methods  ===
#pragma mark -

-(void)setIdChunk:(NSNumber *)IdChunk{
    _IdChunk = IdChunk;
}

-(void)setIdOpera:(NSNumber *)IdOpera{
    _IdOpera = IdOpera;
}
@end
