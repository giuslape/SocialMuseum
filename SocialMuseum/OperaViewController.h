//
//  OperaViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AddContentViewController.h"

@class MGScrollView;


@interface OperaViewController : UIViewController <AddContentDelegate>


@property (weak, nonatomic) IBOutlet MGScrollView *scroller;

@end
