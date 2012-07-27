//
//  UpdateViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "UpdateViewController.h"

@interface UpdateViewController ()

@end

@implementation UpdateViewController

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UserCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
   // cell.textLabel.text = [NSString stringWithFormat:@"UserCell %d", indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

/*
#pragma mark -
#pragma mark ===  Add Comment Delegate  ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddComment"])
    {
        //UINavigationController *navigationController =segue.destinationViewController;
       // AddCommentViewController*addCommentViewController =  segue.destinationViewController;
//        [[navigationController viewControllers]objectAtIndex:0];
        //addCommentViewController.delegate = self;
    }
}

- (void)addCommentDidSave:(AddCommentViewController *)viewController{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addCommentDidCancel:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
}
*/

@end
