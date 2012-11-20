//
//  DetailPhotoViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 20/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "DetailPhotoViewController.h"

@interface DetailPhotoViewController ()

@end

@implementation DetailPhotoViewController

@synthesize image;
@synthesize delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"texture.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
}




- (IBAction)trashPressed:(id)sender {
    
    [delegate deletePhotoDidPressed:self];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
