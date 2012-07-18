//
//  StreamPhotoScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamPhotoScreen : UIViewController
{
    IBOutlet UIImageView* photoView;
    IBOutlet UILabel* lblTitle;
}

@property (assign, nonatomic) NSNumber* IdPhoto;

@end