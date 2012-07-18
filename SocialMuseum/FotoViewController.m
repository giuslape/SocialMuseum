//
//  FotoViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "FotoViewController.h"

@interface FotoViewController ()

@end

@implementation FotoViewController

@synthesize imageView = _imageView;

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
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)takePicture:(id)sender {
    
    UIImagePickerController* ipc = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [ipc setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    [ipc setDelegate:self];
    
    [self presentModalViewController:ipc animated:YES];
    
}


#pragma mark -
#pragma mark ===  Picker Controller Delegate  ===
#pragma mark -


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.imageView setImage:img];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
