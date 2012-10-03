//
//  UpdateViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UpdateViewController : UIViewController{
    
    NSArray* _comments;
}

@property (copy, nonatomic, readwrite)NSNumber* IdOpera;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end
