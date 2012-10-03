//
//  ChunkViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ChunkViewController.h"
#import "AddCommentViewController.h"
#import "MBProgressHUD.h"
#import "API.h"
#import "PullToRefreshView.h"

#define MAX_HEIGHT 2000

@interface ChunkViewController ()

@end

@implementation ChunkViewController
@synthesize textView, chunk = _chunk, IdChunk = _IdChunk;
@synthesize IdOpera = _IdOpera;
@synthesize tableView = _tableView;

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
    
   
    [self streamCommenti];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh dataSource");
        [self streamCommenti];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        NSLog(@"load more data");
    }];

}

-(void)streamCommenti{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading..."];
    [hud setDimBackground:YES];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",_IdOpera,@"IdOpera",_IdChunk,@"IdChunk", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   _comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                   [_tableView reloadData];
                                   [_tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5f];
                                   [hud hide:YES];
                               }];

}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setTableView:nil];
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

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UserCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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



@end
