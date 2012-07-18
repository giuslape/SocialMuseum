//
//  OperaViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 05/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtWork.h"


@interface OperaViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>



@property (readwrite, copy, nonatomic) ArtWork *artWork; 

@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;


@end
