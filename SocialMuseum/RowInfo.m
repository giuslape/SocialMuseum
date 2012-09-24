//
//  RowInfo.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "RowInfo.h"

@implementation RowInfo

@synthesize order;
@synthesize accumulatedViews;
@synthesize viewsPerCell;
@synthesize isLastCell;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Row %d has %d views, and %d views before.>", order, viewsPerCell, accumulatedViews];
}

#define kVIEWS_PER_CELL 						@"viewsPerCell"
#define kACCUMULATED_VIEWS 						@"accumulatedViews"
#define kORDER                                  @"order"
#define kIS_LAST_CELL                           @"isLastCell"



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeInteger:self.viewsPerCell forKey:kVIEWS_PER_CELL];
    [encoder encodeInteger:self.accumulatedViews forKey:kACCUMULATED_VIEWS];
    [encoder encodeInteger:self.order forKey:kORDER];
    [encoder encodeBool:self.isLastCell forKey:kIS_LAST_CELL];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.viewsPerCell = [decoder decodeIntegerForKey:kVIEWS_PER_CELL];
        self.accumulatedViews = [decoder decodeIntegerForKey:kACCUMULATED_VIEWS];
        self.order = [decoder decodeIntegerForKey:kORDER];
        self.isLastCell = [decoder decodeBoolForKey:kIS_LAST_CELL];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = nil;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    if (data)
        theCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return theCopy;
}

- (id)copy
{
    return [self copyWithZone:nil];
}



@end
