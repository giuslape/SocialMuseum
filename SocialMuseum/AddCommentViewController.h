//
//  AddCommentViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddCommentViewController;

@protocol AddCommentDelegate <NSObject>

-(void)addCommentDidCancel:(AddCommentViewController *)viewController;

-(void)addCommentDidSave:(AddCommentViewController *)viewController;

@end



@interface AddCommentViewController : UIViewController


@property (nonatomic, weak) id <AddCommentDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *commentView;
@property (strong, nonatomic, readwrite) NSNumber* IdChunk;
@property (strong, nonatomic, readwrite) NSNumber* IdOpera;

- (IBAction)done:(id)sender;

- (IBAction)cancel:(id)sender;


@end
