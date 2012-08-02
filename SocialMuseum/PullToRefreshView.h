//
//  PullToRefreshView.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 01/08/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullToRefreshView : UIView

@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@property (nonatomic, strong) NSDate *lastUpdatedDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)triggerRefresh;
- (void)startAnimating;
- (void)stopAnimating;

@end


// Categoria che estende UIScrollView

@interface UIScrollView (SVPullToRefresh)

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;

@property (nonatomic, strong) PullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) PullToRefreshView *infiniteScrollingView;

@property (nonatomic, assign) BOOL showsPullToRefresh;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;

@end