//
//  ChunkViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 26/07/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddContentViewController.h"

@class MGScrollView;

@interface ChunkViewController : UIViewController <AddContentDelegate>{
    
    NSArray* _comments;
}

@property (weak, nonatomic) IBOutlet MGScrollView *scroller;

@end
