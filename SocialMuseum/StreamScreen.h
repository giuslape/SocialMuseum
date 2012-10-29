//
//  StreamScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

@class MGScrollView;

#import <UIKit/UIKit.h>

@interface StreamScreen : UIViewController {
    IBOutlet UIBarButtonItem* btnCompose;
    
    bool phone;
}

@property(nonatomic, copy, readwrite) NSNumber* IdOpera;
@property (nonatomic, weak) IBOutlet MGScrollView *scroller;

@end
