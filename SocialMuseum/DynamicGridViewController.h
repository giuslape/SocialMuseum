//
//  DynamicGridViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicGridViewDelegate.h"


@interface DynamicGridViewController : UIViewController

/**
 @abstract Retrieve the view at the specified index.
 @param index the index of the view.
 @return the view, or nil if the view is not currently visible.
 */
- (UIView*) viewAtIndex:(NSUInteger)index;

/**
 @return the views that are currently visible.
 */
- (NSArray*) visibleViews;

/**
 
 @return BDRowInfo instances for the currently visible rows 
 */
- (NSArray*) visibleRowInfos;

/**
 Metadata of the current layout rows.
 @return list of BDRowInfo. Each BDRowInfo instance describes layout info of the current row.
 */
- (NSArray*) rowInfos;

/**
 Reload the entire view by asking the delegate for the latest data.
 */
- (void)reloadData;

/**
 Reload the views in rows specified by the input BDRowInfo objects.
 @param rowInfos list of BDRowInfo to be reloaded.
 */
- (void)reloadRows:(NSArray*)rowInfos;

/**
 Refresh layout on a specific row.
 @param rowInfo the row
 @param animated YES to see animation of layout refresh.
 */
- (void)updateLayoutWithRow:(RowInfo*)rowInfo animated:(BOOL)animated;

/**
 @param color color for the background.
 */
- (void)setBackgroundColor:(UIColor*)color;

/**
 @name Properties
 */

/**
 The delegate of this class. Can be nil, but nothing will display.
 */
@property (nonatomic, strong) id<DynamicGridViewDelegate> delegate;

/**
 Top, left, right, buttom margin of each UIView in layout.
 */
@property (nonatomic, assign) CGFloat borderWidth;



/**
 @name Method delegator blocks
 */

/**
 Block executed when a UIView is long pressed. 
 The block is supplied by the view and its index in the UIView list.
 */
@property (nonatomic, copy) void (^onLongPress)(UIView*, NSInteger);

/**
 Block executed when a UIView is single tapped.
 The block is supplied by the view and its index in the UIView list.
 */
@property (nonatomic, copy) void (^onSingleTap)(UIView*, NSInteger);


/**
 Block executed when a UIView is double tapped.
 The block is supplied by the view and its index in the UIView list.
 */
@property (nonatomic, copy) void (^onDoubleTap)(UIView*, NSInteger);

@end
