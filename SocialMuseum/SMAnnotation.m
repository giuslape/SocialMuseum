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


-(id)initWithCoordinate:(CLLocationCoordinate2D)c
{
    if (self = [super init]) {
        
        coordinate = c;
        
    }
    return self;
}

- (NSString *)title {
    return @"Prova";
}

- (NSString *)subtitle {
    return @"Prova";
}


@end
