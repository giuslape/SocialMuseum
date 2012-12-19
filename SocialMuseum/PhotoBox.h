//
//  PhotoBox.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 18/12/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "MGBox.h"

@interface PhotoBox : MGBox

+ (PhotoBox *)photoProfileBoxWithView:(UIView *)view andSize:(CGSize)size;
+ (PhotoBox *)photoProfileOptionPhoto:(NSNumber *)idPhoto;
+ (PhotoBox *)photoProfileWithIdUser:(NSNumber *)idUser;
+ (PhotoBox *)photoProfileOptionAdvice;

+ (PhotoBox *)photoArtworkWithUrl:(NSString *)urlImage andSize:(CGSize)size;

+ (PhotoBox *)artWorkStreamWithPhotoId:(NSNumber *)idPhoto andSize:(CGSize)size;

-(void)loadPhotoWithInset:(UIEdgeInsets)padding;


@end
