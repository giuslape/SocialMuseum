//
//  DynamicGridCell.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RowInfo.h"
/**
 Layout style
 */
enum DynamicGridCellLayoutStyle {
    /**
     Each view is made aspect fit.
     */
    DynamicGridCellLayoutStyleEven = 0,
    /**
     Each view is made aspect fill and its size varying to fill the cell.
     */
    DynamicGridCellLayoutStyleFill = 1
};
typedef NSUInteger DynamicGridCellLayoutStyle;

/**
 This class is responsible for laying out each table row.
 */


@interface DynamicGridCell : UITableViewCell

- (id)initWithLayoutStyle:(DynamicGridCellLayoutStyle)layoutStyle reuseIdentifier:(NSString*)cellId;


/**
 Sets UIViews the cell and lays them out in the process based on
 the cell's BDDynamicGridCellLayoutStyle. 
 
 To clear all views, set nil or zero NSArray to this method.
 */
- (void) setViews:(NSArray*)views;


- (void) layoutSubviewsAnimated:(BOOL)animated;

/**
 the cell's BDDynamicGridCellLayoutStyle.
 */
@property (nonatomic, assign, readonly) DynamicGridCellLayoutStyle layoutStyle;
/**
 Width of each view's border.
 */
@property (nonatomic, assign) CGFloat viewBorderWidth;
/**
 row info associated with this cell.
 */
@property (nonatomic, strong) RowInfo* rowInfo;

/**
 The view that grid views are contained in.
 */
@property (nonatomic, strong, readonly) UIView* gridContainerView;


@end
