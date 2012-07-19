//
//  StreamScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoView.h"

@interface StreamScreen : UIViewController <PhotoViewDelegate> {
    IBOutlet UIBarButtonItem* btnCompose;
    IBOutlet UIBarButtonItem* btnRefresh;
    IBOutlet UIScrollView* listView;
}

@property(nonatomic, weak) NSNumber* IdOpera;
//refresh the photo stream
-(IBAction)btnRefreshTapped;

@end
