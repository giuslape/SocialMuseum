//
//  PhotoScreen.h
//  Social Museum
//
//  Created by Giuseppe Lapenta on 09/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoScreen : UIViewController<UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>
{
    IBOutlet UIImageView* photo;
    IBOutlet UIBarButtonItem* btnAction;
    IBOutlet UITextField* fldTitle;
}

//Mostra il menu dell'app
-(IBAction)btnActionTapped:(id)sender;

@property(nonatomic, copy, readwrite)NSNumber* IdOpera;


@end
