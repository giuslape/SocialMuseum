//
//  DynamicGridViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "DynamicGridViewController.h"
#import "DynamicGridCell.h"
#import "RowInfo.h"
#define kDefaultBorderWidth 5


@interface DynamicGridViewController () <UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_rowInfos;
}

@end

@implementation DynamicGridViewController

@synthesize borderWidth;
@synthesize delegate;
@synthesize onLongPress;
@synthesize onDoubleTap;
@synthesize onSingleTap;


- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {}
    return self;
}

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
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.borderWidth = kDefaultBorderWidth;
    self.view.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_tableView];
    _tableView.frame = self.view.bounds;
    [self reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _tableView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [_tableView reloadData];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setBackgroundColor:(UIColor *)color
{
    _tableView.backgroundColor = color;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowInfos.count;
}


- (NSArray *)rowInfos
{
    NSArray *result = [NSArray array];
    for (RowInfo* rowInfo in _rowInfos) {
        result = [result arrayByAddingObject:[rowInfo copy]];
    }
    return _rowInfos;
}

- (NSArray *)visibleRowInfos
{
    NSArray *indexPaths = [_tableView indexPathsForVisibleRows];
    NSArray *result = [NSArray array];
    for (NSIndexPath *idp in indexPaths) {
        RowInfo *rowInfo = [_rowInfos objectAtIndex:idp.row];
        result = [result arrayByAddingObject:[rowInfo copy]];
    }
    return result;
}

- (void)reloadRows:(NSArray *)rowInfos
{
    NSArray *indexPaths = [NSArray array];
    for (RowInfo *row in rowInfos) {
        indexPaths = [indexPaths arrayByAddingObject: [NSIndexPath indexPathForRow:row.order inSection:0]];
    }
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadData
{
    if (self.delegate == nil) {
        return;
    }
    
    //rearrange views on the table by recalculating row infos
    _rowInfos = [NSArray new];
    NSUInteger accumNumOfViews = 0;
    RowInfo * ri;
    NSUInteger kMaxViewsPerCell = self.delegate.maximumViewsPerCell;
    NSAssert(kMaxViewsPerCell>0, @"Maximum number of views per cell must be greater than zero");
    NSUInteger kMinViewsPerCell = 1;
    
    if ([self.delegate respondsToSelector:@selector(minimumViewsPerCell)]) {
        kMinViewsPerCell = self.delegate.minimumViewsPerCell==0?1:self.delegate.minimumViewsPerCell;
    }
    
    NSAssert(kMinViewsPerCell <= kMaxViewsPerCell, @"Minimum number of views per row cannot be greater than maximum number of views per row.");
    
    while (accumNumOfViews < self.delegate.numberOfViews) {
        NSUInteger numOfViews = (arc4random() % kMaxViewsPerCell) + kMinViewsPerCell;   
        if (numOfViews > kMaxViewsPerCell) {
            numOfViews = kMaxViewsPerCell;
        }
        numOfViews = (accumNumOfViews+numOfViews <= self.delegate.numberOfViews)?numOfViews:(self.delegate.numberOfViews-accumNumOfViews);
        ri = [RowInfo new];
        ri.order = _rowInfos.count;
        ri.accumulatedViews = accumNumOfViews;
        ri.viewsPerCell = numOfViews;
        accumNumOfViews = accumNumOfViews + numOfViews;
        _rowInfos = [_rowInfos arrayByAddingObject:ri];
    }
    ri.isLastCell = YES;
    NSAssert(accumNumOfViews == self.delegate.numberOfViews, @"wrong accum %u ", ri.accumulatedViews);
    [_tableView reloadData];
}


- (void)updateLayoutWithRow:(RowInfo *)rowInfo animated:(BOOL)animated
{
    DynamicGridCell *cell = (DynamicGridCell*) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowInfo.order inSection:0]];
    [cell layoutSubviewsAnimated:animated];
}

- (UIView*)viewAtIndex:(NSUInteger)index
{
    UIView *view = nil;
    RowInfo *findRow = [[RowInfo alloc] init];
    findRow.accumulatedViews = index ;
    
    //use binary search for the cell that contains the specified index
    NSUInteger indexOfRow = [_rowInfos indexOfObject:findRow
                                       inSortedRange:(NSRange){0, _rowInfos.count  -1}
                                             options:NSBinarySearchingInsertionIndex|NSBinarySearchingLastEqual
                                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                         RowInfo *r1 = obj1;
                                         RowInfo *r2 = obj2;
                                         return (r1.accumulatedViews+r1.viewsPerCell) - (r2.accumulatedViews + r2.viewsPerCell);
                                     }];
    RowInfo *rowInfo = [_rowInfos objectAtIndex:indexOfRow];
    
    DynamicGridCell *cell =  (DynamicGridCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowInfo.order inSection:0]];
    NSUInteger realIndex = index - rowInfo.accumulatedViews;
    view = [cell.gridContainerView.subviews objectAtIndex:realIndex];
    
    return view;
}

- (NSArray *)visibleViews
{
    NSArray* cells = [_tableView visibleCells];
    NSArray* visibleViews = [[NSArray alloc] init];
    for (DynamicGridCell *cell in cells) {
        visibleViews = [visibleViews arrayByAddingObjectsFromArray:cell.gridContainerView.subviews];
    }
    return visibleViews;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RowInfo *ri = [_rowInfos objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    DynamicGridCell *cell = [tableView dequeueReusableCellWithIdentifier:[CellIdentifier stringByAppendingFormat:@"_viewCount%d", ri.viewsPerCell]];
    
    if (!cell) {
        cell = [[DynamicGridCell alloc] initWithLayoutStyle:DynamicGridCellLayoutStyleFill
                                              reuseIdentifier:CellIdentifier];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
        longPress.numberOfTouchesRequired = 1;
        [cell.gridContainerView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.delaysTouchesBegan = YES;
        [cell.gridContainerView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.delaysTouchesBegan = YES;
        [cell.gridContainerView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    
    //clear for updated list of views
    [cell setViews:nil];
    cell.viewBorderWidth = self.borderWidth;
    
    cell.rowInfo = ri;
    NSArray * viewsForRow = [NSArray array];
    for (int i=0; i<ri.viewsPerCell; i++) {
        viewsForRow = [viewsForRow arrayByAddingObject:[self.delegate viewAtIndex:i + ri.accumulatedViews rowInfo:ri]];
    }
    NSAssert(viewsForRow.count > 0, @"number of views per row must be greater than 0");
    [cell setViews:viewsForRow];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(rowHeightForRowInfo:)]) {
        RowInfo *rowInfo = [_rowInfos objectAtIndex:indexPath.row];
        return [self.delegate rowHeightForRowInfo:rowInfo];
    }else{
        return tableView.rowHeight;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(willDisplayRow:)]) {
        RowInfo *rowInfo = [_rowInfos objectAtIndex:indexPath.row];
        return [self.delegate willDisplayRow:rowInfo];
    }
}

#pragma mark - scrolling
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    DLog(@"willdecelerate %d", decelerate);
    if([self.delegate respondsToSelector:@selector(gridViewWillEndScrolling)]){
        [self.delegate gridViewWillEndScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    DLog(@"did end decel");
    if([self.delegate respondsToSelector:@selector(gridViewDidEndScrolling)]){
        [self.delegate gridViewDidEndScrolling];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView 
                     withVelocity:(CGPoint)velocity 
              targetContentOffset:(CGPoint *)targetContentOffset
{
    //    DLog(@"will end dragging vel: %@", NSStringFromCGPoint(velocity));
    if (velocity.y > 1.5) {
        if ([self.delegate respondsToSelector:@selector(gridViewWillStartScrolling)]) {
            [self.delegate gridViewWillStartScrolling];
        }
    }
}

#pragma mark - events

- (void)gesture:(UIGestureRecognizer*)gesture view:(UIView**)view viewIndex:(NSInteger*)viewIndex
{
    
    DynamicGridCell *cell = (DynamicGridCell*) [gesture.view.superview superview];
    
    CGPoint locationInGridContainer = [gesture locationInView:gesture.view];    
    for (int i=0; i < cell.gridContainerView.subviews.count; i++){
        UIView *subview = [cell.gridContainerView.subviews objectAtIndex:i];
        CGRect vincinityRect = CGRectMake(subview.frame.origin.x - self.borderWidth, 
                                          0, 
                                          subview.frame.size.width + (self.borderWidth * 2), 
                                          cell.gridContainerView.frame.size.height);
        
        if(CGRectContainsPoint(vincinityRect, locationInGridContainer)){
            *view = subview;
            *viewIndex = ((cell.rowInfo.accumulatedViews) + i );
            break;
        }
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer*)longPress
{
    
    UIView *view = nil;
    NSInteger viewIndex = -1;
    [self gesture:longPress view:&view viewIndex:&viewIndex];
    
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressDidBeginAtView:index:)]) {
            [self.delegate longPressDidBeginAtView:view index:viewIndex];
        }
    }else if (longPress.state == UIGestureRecognizerStateRecognized) {
        
        if ([self.delegate respondsToSelector:@selector(longPressDidEndAtView:index:)]) {
            [self.delegate longPressDidEndAtView:view index:viewIndex];
        }
        
        if (self.onLongPress) {
            self.onLongPress(view, viewIndex);
        }
        
    }
}

- (void)didDoubleTap:(UITapGestureRecognizer*)doubleTap
{
    if (doubleTap.state == UIGestureRecognizerStateRecognized) {
        UIView *view = nil;
        NSInteger viewIndex = -1;
        [self gesture:doubleTap view:&view viewIndex:&viewIndex];
        if (self.onDoubleTap) {
            self.onDoubleTap(view, viewIndex);
        }
    }
    
}


- (void)didSingleTap:(UITapGestureRecognizer*)singleTap
{
    if (singleTap.state == UIGestureRecognizerStateRecognized) {
        UIView *view = nil;
        NSInteger viewIndex = -1;
        //DLog(@"view %@, viewIndex %d", view, viewIndex);
        [self gesture:singleTap view:&view viewIndex:&viewIndex];
        if (self.onSingleTap) {
            self.onSingleTap(view, viewIndex);
        }
    }
}

@end
