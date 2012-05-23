//
//  SMAnnotation.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "SMAnnotation.h"

@implementation SMAnnotation

@synthesize coordinate;
@synthesize description;
@synthesize image;
@synthesize title = _title;
@synthesize subTitle = _subTitle;



+(id)initWithLocation:(CLLocationCoordinate2D)c{
    
    return [[self alloc] initWithLocation:c];
    
}

-(id)initWithLocation:(CLLocationCoordinate2D)c
{
    if (self = [super init]) {
        
        coordinate = c;
        image = nil;
    }
    return self;
}

- (NSString *)title {
    
    return _title;
}

- (NSString *)subtitle {
    
    return _subTitle;
}

- (NSString *)description{
    
    return @"Description";
}

- (UIImage *)image{
    
    return image;
}


@end
