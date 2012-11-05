//
//  StreamPhotoScreen.h
//  Social Museum
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGBox;

@interface StreamPhotoScreen : UIViewController
{
    IBOutlet UIImageView* photoView;
}

@property (copy, nonatomic, readwrite) NSNumber* IdPhoto;
@property (copy, nonatomic, readwrite) NSNumber* IdOpera;
@property (copy, nonatomic, readwrite) NSString* username;
@property (copy, nonatomic, readwrite) NSString* artWorkName;

@end
