//
//  CollectionView.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CollectionViewCell;

@protocol CollectionViewDelegate, CollectionViewDataSource;

@interface CollectionView : UIScrollView

#pragma mark - Public Properties

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UIView *emptyView;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, assign, readonly) CGFloat colWidth;
@property (nonatomic, assign, readonly) NSInteger numCols;
@property (nonatomic, assign) NSInteger numColsLandscape;
@property (nonatomic, assign) NSInteger numColsPortrait;
@property (nonatomic, assign) id <CollectionViewDelegate> collectionViewDelegate;
@property (nonatomic, assign) id <CollectionViewDataSource> collectionViewDataSource;

#pragma mark - Public Methods

/**
 Reloads the collection view
 This is similar to UITableView reloadData)
 */
- (void)reloadData;

/**
 Dequeues a reusable view that was previously initialized
 This is similar to UITableView dequeueReusableCellWithIdentifier
 */
- (UIView *)dequeueReusableView;

@end

#pragma mark - Delegate

@protocol CollectionViewDelegate <NSObject>

@optional
- (void)collectionView:(CollectionView *)collectionView didSelectView:(CollectionViewCell *)view atIndex:(NSInteger)index;

@end

#pragma mark - DataSource

@protocol CollectionViewDataSource <NSObject>

@required
- (NSInteger)numberOfViewsInCollectionView:(CollectionView *)collectionView;
- (CollectionViewCell *)collectionView:(CollectionView *)collectionView viewAtIndex:(NSInteger)index;
- (CGFloat)heightForViewAtIndex:(NSInteger)index;


@end
