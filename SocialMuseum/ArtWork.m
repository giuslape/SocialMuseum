//
//  ArtWork.m
//  SocialMuseum
//
//  Created by Vincenzo Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "ArtWork.h"

@implementation ArtWork

@synthesize imageUrl, title, description, IdOpera;

- (id)copyWithZone:(NSZone *)zone{
    
    ArtWork* artWork = [[self class] allocWithZone:zone];
    
    artWork.imageUrl = self.imageUrl;
    artWork.title = self.title;
    artWork.description = self.description;
    artWork.IdOpera = self.IdOpera;
    
    return artWork;
    
}

@end
