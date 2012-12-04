//
//  StreamScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

@class MGScrollView, ArtWork;

#import <UIKit/UIKit.h>
#import "AddContentViewController.h"


@interface StreamScreen : UIViewController <AddContentDelegate>{
    bool phone;
}

@property (nonatomic, strong) ArtWork* artWork;
@property (nonatomic, weak) IBOutlet   MGScrollView *scroller;

//- (IBAction)photoBtnDidPressed:(id)sender;

@end
