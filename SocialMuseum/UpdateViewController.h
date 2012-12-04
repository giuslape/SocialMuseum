//
//  UpdateViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddContentViewController.h"

@class MGScrollView;

@interface UpdateViewController : UIViewController <AddContentDelegate>
{
    
    NSArray* _comments;
}

@property (copy, nonatomic, readwrite)NSNumber* IdOpera;

@property (weak, nonatomic) IBOutlet MGScrollView *scroller;

@end
