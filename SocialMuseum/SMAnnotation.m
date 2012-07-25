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
@synthesize description = _description;
@synthesize image = _image;
@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize IdOpera = _IdOpera;
@synthesize chunkDescription = _chunkDescription;
@synthesize imageUrl = _imageUrl;



+(id)initWithLocation:(CLLocationCoordinate2D)c{
    
    return [[self alloc] initWithLocation:c];
    
}

-(id)initWithLocation:(CLLocationCoordinate2D)c
{
    if (self = [super init]) {
        
        coordinate = c;
        _image = nil;
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
    
    return _image;
}

-(NSArray *)chunkDescription{
    
    return _chunkDescription;
}

@end
