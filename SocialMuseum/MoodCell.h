//
//  MoodCell.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 20/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageRatingView;

@end
