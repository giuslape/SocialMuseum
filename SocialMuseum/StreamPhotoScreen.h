//
//  StreamPhotoScreen.h
//  Social Museum
//
//  Created by Giuseppe Lapenta on 10/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGBox;

@interface StreamPhotoScreen : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray *viewControllers;
    
    NSArray* contentList;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, readwrite) NSNumber* firstPage;
@end
