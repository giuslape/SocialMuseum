//
//  FotoViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 27/06/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    __weak UIImageView* _imageView;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePicture:(id)sender;


@end
