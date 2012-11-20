//
//  ArtWork.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtWork : NSObject <NSCopying>

@property (strong, nonatomic, readwrite) NSString* title;
@property (strong, nonatomic, readwrite) NSString* description;
@property (strong, nonatomic, readwrite) NSString*  imageUrl;
@property (copy, nonatomic, readwrite)   NSNumber* IdOpera;

@end
