//
//  RowInfo.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RowInfo : NSObject <NSCoding, NSCopying>

- (id)copy;

/**
 The number of views contained in this row. 
 */
@property (nonatomic, assign) NSUInteger viewsPerCell;
/**
 The number of views existing before this row.
 */
@property (nonatomic, assign) NSUInteger accumulatedViews;
/**
 The order of this row.
 */
@property (nonatomic, assign) NSUInteger order;
/**
 Whether row is the last row.
 */
@property (nonatomic, assign) BOOL isLastCell;

@end
