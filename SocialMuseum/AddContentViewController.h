//
//  AddContentViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 14/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailPhotoViewController.h"


@protocol AddContentDelegate <NSObject>

- (void)submitCommentDidPressed:(id)sender;
- (void)submitPhotoDidPressed:(id)sender;

@end

@class MGScrollView;
@class ArtWork;

@interface AddContentViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, DetailPhotoDelegate>


@property (weak, nonatomic) IBOutlet MGScrollView *scroller;
@property (copy,nonatomic, readwrite) ArtWork* artWork;
@property (weak) id <AddContentDelegate> delegate;



- (IBAction)cancelDidPress:(id)sender;

@end
