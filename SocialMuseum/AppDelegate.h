//
//  AppDelegate.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SMSessionStateChangedNotification;

@class LocationViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// AppDelegate è il responsabile del mantenimento della sessione con Facebook.
// se la FBSession non è valida viene visualizzata la schermata di login.

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)showInitialViewController;
- (void)logoutHandler;

@end
