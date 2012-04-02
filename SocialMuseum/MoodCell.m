//
//  MoodCell.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 20/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import "MoodCell.h"

@implementation MoodCell

@synthesize nameLabel, imageRatingView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
