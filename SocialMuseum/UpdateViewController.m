//
//  UpdateViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "UpdateViewController.h"
#import "AddCommentViewController.h"
#import "API.h"
#import "MBProgressHUD.h"
#import "PullToRefreshView.h"

@interface UpdateViewController ()

@end

@implementation UpdateViewController

@synthesize IdOpera = _IdOpera;
@synthesize tableview = _tableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading..."];
    [hud setDimBackground:YES];
    
    [self.tableview addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh dataSource");
        [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",_IdOpera,@"IdOpera", nil]
                                   onCompletion:^(NSDictionary *json) {
                                       
                                       _comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                       [_tableview reloadData];
                                       [hud hide:YES];
                                        [_tableview.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];
                                       
                                   }];
    }];
    
    [self.tableview addInfiniteScrollingWithActionHandler:^{
        NSLog(@"load more data");
    }];
    
    // trigger the refresh manually at the end of viewDidLoad
    //[_tableview.pullToRefreshView triggerRefresh];

}

- (void)viewDidUnload
{
    [self setTableview:nil];
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
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UserCell";
    
    UITableViewCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;

    }
    
    NSDictionary * dictionary= [_comments objectAtIndex:indexPath.row];
    NSString* text = [dictionary objectForKey:@"testo"];
    cell.textLabel.text = text;
        
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* dictionary = [_comments objectAtIndex:indexPath.row];
    CGSize size = [[dictionary objectForKey:@"testo"] 
                   sizeWithFont:[UIFont systemFontOfSize:10] 
                   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    return size.height + 15;
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
        //UINavigationController *navigationController =segue.destinationViewController;
        AddCommentViewController*addCommentViewController =  segue.destinationViewController;
        [addCommentViewController setIdOpera:_IdOpera];
        //addCommentViewController.delegate = self;
    }
}

/*
- (void)addCommentDidSave:(AddCommentViewController *)viewController{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addCommentDidCancel:(AddCommentViewController *)viewController{
    
    [self dismissModalViewControllerAnimated:YES];
}
*/

@end
