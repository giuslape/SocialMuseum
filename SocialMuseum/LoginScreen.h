//
//  LoginScreen.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 09/02/2012.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginScreen : UIViewController
{
    //the login form fields
    IBOutlet UITextField* fldUsername;
    IBOutlet UITextField* fldPassword;
}

//action for when either button is pressed
-(IBAction)btnLoginRegisterTapped:(id)sender;

@end