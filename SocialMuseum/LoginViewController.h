//
//  LoginViewController.h
//  SimpleLoginFacebook
//
//  Created by Giuseppe Lapenta on 30/08/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate

-(void)loginButtonDidPressed:(LoginViewController *)sender;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate>{
    
    IBOutlet UITextField* fldUsername;
    IBOutlet UITextField* fldPassword;

}


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;
- (IBAction)performLogin:(id)sender;

-(void)loginFailed;

@end
