//
//  DynamicGridCell.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 24/09/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "DynamicGridCell.h"

@interface DynamicGridCell(){
    UIView * _gridContainerView;
}
@end

@implementation DynamicGridCell

@synthesize layoutStyle=_layoutStyle;
@synthesize viewBorderWidth;
@synthesize rowInfo;
@synthesize gridContainerView=_gridContainerView;

- (id)init
{
    self = [self initWithStyle:0 reuseIdentifier:@"GridCell"];
    if (self) {
    }
    return self;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _gridContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _gridContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
        [self.contentView addSubview:_gridContainerView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
    }
    return self;
}

- (id)initWithLayoutStyle:(DynamicGridCellLayoutStyle)layoutStyle reuseIdentifier:(NSString *)cellId
{
    self = [self initWithStyle:0 reuseIdentifier:cellId];
    if (self) {
        _layoutStyle=layoutStyle;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews{
    [self layoutSubviewsAnimated:NO];
}

- (void)layoutSubviewsAnimated:(BOOL)animated
{
    [super layoutSubviews];
    _gridContainerView.frame = CGRectMake(0, 0, 
                                          self.contentView.frame.size.width, 
                                          self.contentView.frame.size.height);
    NSArray * oldFrames = [NSArray array];
    if (animated) {
        for (int i=0; i<_gridContainerView.subviews.count; i++){
            UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
            oldFrames = [oldFrames arrayByAddingObject:[NSValue valueWithCGRect:subview.frame]];
        }
    }
    
    //layout what's in the cell
    CGFloat aRowHeight = self.frame.size.height;
    CGFloat totalWidth = 0;
    for (int i=0; i<_gridContainerView.subviews.count; i++){
        UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
        //assume that for UIImageView, the size we want is the image size
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *iv = (UIImageView*)subview;
            if (iv.image != nil && iv.image.size.width > 0) {
                iv.frame = CGRectMake(0, 0, iv.image.size.width, iv.image.size.height);
            }
        }
        totalWidth = totalWidth + subview.frame.size.width;
    }
    
    CGFloat widthScaling =  ((_gridContainerView.frame.size.width - ((_gridContainerView.subviews.count+1) * self.viewBorderWidth ))/totalWidth);
    CGFloat accumWidth = self.viewBorderWidth;
    //UIView* lastView;
    NSArray *newFrames = [NSArray array];
    for (int i=0; i<_gridContainerView.subviews.count; i++){
        UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
        CGRect newFrame = subview.frame;
        newFrame = CGRectMake(0, 0, newFrame.size.width * widthScaling, aRowHeight - self.viewBorderWidth);
        CGFloat leftMargin = i==0?0:(self.viewBorderWidth);
        newFrame = CGRectOffset(newFrame, accumWidth + leftMargin, 0);
        newFrame = CGRectIntegral(newFrame);
        accumWidth = accumWidth + newFrame.size.width + leftMargin;
        //lastView = subview;
        newFrames = [newFrames arrayByAddingObject:[NSValue valueWithCGRect:newFrame]];
    }
    
    if (!animated) {
        for (int i=0; i<_gridContainerView.subviews.count; i++){
            UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
            NSValue* newFrame = [newFrames objectAtIndex:i];
            subview.frame = [newFrame CGRectValue];
        }
    }else {
        for (int i=0; i<_gridContainerView.subviews.count; i++){
            UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
            NSValue* oldFrame = [oldFrames objectAtIndex:i];
            subview.frame = [oldFrame CGRectValue];
        }
        [UIView animateWithDuration:1.f
                         animations:^{
                             for (int i=0; i<_gridContainerView.subviews.count; i++){
                                 UIView* subview = [_gridContainerView.subviews objectAtIndex:i];
                                 NSValue* newFrame = [newFrames objectAtIndex:i];
                                 subview.frame = [newFrame CGRectValue];
                             } 
                         }];
    }
}

-(void)setViews:(NSArray *)views
{   
    //remove all subviews.
    if (views == nil || views.count == 0) {
        for (UIView* sb in _gridContainerView.subviews) {
            [sb removeFromSuperview];
        }
        return;
    }
    
    for(UIView * sv in views){
        sv.contentMode = UIViewContentModeScaleAspectFill;
        [_gridContainerView addSubview:sv];
    }
    
    [self setNeedsLayout];
}

@end
