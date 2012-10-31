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

#import "MGTableBoxStyled.h"
#import "MGLine.h"
#import "MGScrollView.h"

#define ROW_SIZE               (CGSize){304, 44}

#define IPHONE_TABLES_GRID     (CGSize){320, 0}
#define IPAD_TABLES_GRID       (CGSize){624, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:14]



@interface UpdateViewController (){
    
    MGBox* tablesGrid, *tableComments;
    bool phone;
}

@end

@implementation UpdateViewController

@synthesize IdOpera = _IdOpera;
@synthesize scroller = _scroller;


- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    
    CGSize tablesGridSize = phone ? IPHONE_TABLES_GRID : IPAD_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];

    tableComments = MGBox.box;
    [tablesGrid.boxes addObject:tableComments];
    tableComments.sizingMode = MGResizingShrinkWrap;
   
    [self loadComments];
    
    [self.scroller addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh dataSource");
        [self loadComments];
    }];
    
    [self.scroller.pullToRefreshView setArrowColor:[UIColor whiteColor]];
    [self.scroller.pullToRefreshView setTextColor:[UIColor whiteColor]];
    [self.scroller.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    [tablesGrid layout];
    // relayout the sections
    [self.scroller layoutWithSpeed:1 completion:nil];
}

-(void)loadComments{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading..."];
    [hud setDimBackground:YES];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"streamCommenti", @"command",_IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                    if (![json objectForKey:@"error"] && [[json objectForKey:@"result"]count] > 0) {
                                       
                        _comments = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                        [self sourceDidLoad];
                    }
                    else if([json objectForKey:@"error"]){
                            [self sourceDidError];
                        }
                            [self.scroller.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5f];
                                   [hud hide:YES];
                        }];
}

- (void)viewDidUnload
{
    [self setScroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)sourceDidError{
    
    
    
}
- (void)sourceDidLoad{
    
    if ([tableComments.boxes count] > 0) {
        [tableComments.boxes removeAllObjects];
    }
    MGTableBoxStyled* activity = MGTableBoxStyled.box;
    [tableComments.boxes addObject:activity];

    MGLine* header = [MGLine lineWithLeft:@"Commenti Recenti" right:nil size:ROW_SIZE];
    header.font = HEADER_FONT;
    header.leftPadding = header.rightPadding = header.topPadding = 0;
    [activity.topLines addObject:header];
    
    for (NSDictionary* dict in _comments) {
        
        MGLine* line = [MGLine lineWithLeft:[dict objectForKey:@"testo"] right:nil size:ROW_SIZE];
        line.topPadding = line.leftPadding = 8;
        [activity.topLines addObject:line];
    }
    
    [self.scroller layoutWithSpeed:0.5f completion:nil];
    
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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

@end
