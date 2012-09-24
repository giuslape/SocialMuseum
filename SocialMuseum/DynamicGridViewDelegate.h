//
//  DynamicGridViewDelegate.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RowInfo;

@protocol DynamicGridViewDelegate <NSObject>

- (NSUInteger)maximumViewsPerCell;
- (NSUInteger)numberOfViews;


/**
 This method is called to retreive the view for displayed at the specified index.
 @param index the index of the view
 @param rowInfo the information of the row this view appears in.
 @return the UIView to display at specified index.
 */
- (UIView*) viewAtIndex:(NSUInteger)index rowInfo:(RowInfo*)rowInfo;



@optional
/**
 Minimum number of views per row.
 1 is default if not implemented or when returning zero.
 */
- (NSUInteger)minimumViewsPerCell;

/**
 This method is called when long press is recognized.
 */
- (void)longPressDidBeginAtView:(UIView*)view index:(NSUInteger)index;
/**
 This method is called when long press ends and before the onLongPress block is executed.
 */
- (void)longPressDidEndAtView:(UIView*)view index:(NSUInteger)index;


/**
 @name Scrolling events
 
 In order to help optimize view loading, the class provides these methods that
 get called when events happen.
 */

/**
 This method gets called when grid view is scrolled with some velocity.
 Easy scrolling will not trigger this call.
 */
- (void) gridViewWillStartScrolling;

/**
 This method gets called when grid view's scrolling is going to halt.
 */
- (void) gridViewWillEndScrolling;


/**
 This method gets called when grid view's scrolling comes to a halt.
 */
- (void) gridViewDidEndScrolling;


/**
 This method is called to determine the height of the specified row.
 @param rowInfo the row which the grid view needs to know its height.
 @return height of row in CGFloat.
 */
- (CGFloat) rowHeightForRowInfo:(RowInfo*)rowInfo;

/**
 This method is calleed when the specified row is about to be displayed.
 @param rowInfo the row about to be displayed.
 */
- (void)willDisplayRow:(RowInfo*)rowInfo;

@end