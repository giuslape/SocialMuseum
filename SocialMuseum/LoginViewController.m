//
//  LoginViewController.m
//  SimpleLoginFacebook
//
//  Created by Giuseppe Lapenta on 30/08/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "LoginViewController.h"
#import "UIAlertView+error.h"
#import "API.h"
#import "AppDelegate.h"
#include <CommonCrypto/CommonDigest.h>

#define kSalt @"adlfu3489tyh2jnkLIUGI&%EV(&0982cbgrykxjnk8855"


@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize spinner;

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
    fldPassword.delegate = self;
    fldUsername.delegate = self;
    
}

- (void)viewDidUnload
{
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.spinner stopAnimating];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)performLogin:(UIButton *)sender {
    
    [self.spinner startAnimating];
    
    if (sender.tag == 4) {        
        // FBSample logic
        // The user has initiated a login, so call the openSession method.
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSessionWithAllowLoginUI:YES];
        return;
    }
    //Form di validazione
	if (fldUsername.text.length < 4 || fldPassword.text.length < 4) {
		[UIAlertView error:@"Enter username and password over 4 chars each."];
        [spinner stopAnimating];
		return;
	}
    //Password
	NSString* saltedPassword = [NSString stringWithFormat:@"%@%@", fldPassword.text, kSalt];
	
	NSString* hashedPassword = nil;
	unsigned char hashedPasswordData[CC_SHA1_DIGEST_LENGTH];
	
	NSData *data = [saltedPassword dataUsingEncoding:NSUTF8StringEncoding];
	if (CC_SHA1([data bytes], [data length], hashedPasswordData)) {
		hashedPassword = [[NSString alloc] initWithBytes:hashedPasswordData length:sizeof(hashedPasswordData) encoding:NSASCIIStringEncoding];
	} else {
		[UIAlertView error:@"Password can't be sent"];
		return;
	}
	//Cerca se è login o registrazione
	NSString* command = (sender.tag==1)?@"register":@"login";
	NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command", fldUsername.text, @"username", hashedPassword, @"password", nil];
	//chiama l'API web
	[[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
		//Risultato
		NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
		if ([json objectForKey:@"error"]==nil && [[res objectForKey:@"IdUser"] intValue]>0) {
			[[API sharedInstance] setUser: res];
            AppDelegate* ad = [UIApplication sharedApplication].delegate;
            [ad showInitialViewController];
            
			[ad.window.rootViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
			//Mostra Messaggio
			[[[UIAlertView alloc] initWithTitle:@"Logged in" message:[NSString stringWithFormat:@"Welcome %@",[res objectForKey:@"username"]] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
		} else {
			//error
			[UIAlertView error:[json objectForKey:@"error"]];
		}
	}];

}

- (void)loginFailed {
    // FBSample logic
    // Our UI is quite simple, so all we need to do in the case of the user getting
    // back to this screen without having been successfully authorized is to
    // stop showing our activity indicator. The user can initiate another login
    // attempt by clicking the Login button again.
    [self.spinner stopAnimating];
}


#pragma mark -
#pragma mark ===  UITextFieldDelegate  ===
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}
@end
