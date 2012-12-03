//
//  LoginViewController.h
//  SimpleLoginFacebook
//
//  Created by Giuseppe Lapenta on 30/08/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LoginViewController : UIViewController <UITextFieldDelegate>{
    
    IBOutlet UITextField* fldUsername;
    IBOutlet UITextField* fldPassword;

}

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFBButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)performLogin:(id)sender;
-(void)loginFailed;

@end
