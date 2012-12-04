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
@optional
- (void)submitCommentDidPressed:(id)sender;
- (void)submitPhotoDidPressed:(id)sender;

@end

@class MGScrollView;
@class ArtWork;

@interface AddContentViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, DetailPhotoDelegate>


@property (weak, nonatomic) IBOutlet MGScrollView *scroller;
@property (copy,nonatomic, readwrite) ArtWork* artWork;
@property (weak) id <AddContentDelegate> delegate;
@property (readwrite, nonatomic) bool isChunck;
@property (nonatomic, readwrite, copy)NSNumber* IdChunk;
@property (nonatomic,readwrite) bool isAddComment;
@property (nonatomic,readwrite) bool isAddPhoto;


- (IBAction)cancelDidPress:(id)sender;

@end
