//
//  DetailPhotoViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 20/11/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailPhotoDelegate <NSObject>

- (void)deletePhotoDidPressed:(id)sender;

@end

@interface DetailPhotoViewController : UIViewController

@property (nonatomic,copy,readwrite) UIImage* image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak) id <DetailPhotoDelegate> delegate;

- (IBAction)trashPressed:(id)sender;

@end
