//
//  StreamScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

@class MGScrollView, ArtWork;

#import <UIKit/UIKit.h>

@interface StreamScreen : UIViewController {
    IBOutlet UIBarButtonItem* btnCompose;
    bool phone;
}

@property (nonatomic, strong) ArtWork* artWork;
@property (nonatomic, weak) IBOutlet   MGScrollView *scroller;

@end
