//
//  AppDelegate.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 13/12/11.
//  Copyright (c) 2011 Lapenta. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LocationViewController.h"
#import <FacebookSDK/FacebookSDK.h>

NSString *const SMSessionStateChangedNotification =
@"com.tadaa.SocialMuseum:FBSessionStateChangedNotification";

@interface AppDelegate ()

@property (strong, nonatomic) LocationViewController *mainViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize loginViewController = _loginViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBProfilePictureView class];
    
    // See if we have a valid token for the current state.
    if (![self openSessionWithAllowLoginUI:NO]) {
        // No? Display the login page.
        [self showLoginView];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [FBSession.activeSession handleDidBecomeActive];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [FBSession.activeSession close];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // FBSample logic
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
}

- (void)showLoginView {
    
    if (self.loginViewController == nil) {
        [self createAndPresentLoginView];
    } else {
        [self.loginViewController loginFailed];
    }
}

- (void)createAndPresentLoginView {
    
    if (self.loginViewController == nil) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        self.loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        self.window.rootViewController = self.loginViewController;
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            if (self.loginViewController != nil)
                self.loginViewController = nil;                
                [self showInitialViewController];
            
            
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            // FBSample logic
            // Once the user has logged out, we want them to be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
            [self logoutHandler];
            
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SMSessionStateChangedNotification
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


-(void)showInitialViewController{
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UITabBarController* tbc = [storyBoard instantiateInitialViewController];
    
    self.window.rootViewController = tbc;

}

- (void)logoutHandler{
    
    UINavigationController* navController = (UINavigationController *)[[(UITabBarController *) self.window.rootViewController viewControllers]objectAtIndex:0];
    [navController popToRootViewControllerAnimated:NO];

    if (self.loginViewController != nil)
            self.loginViewController = nil;
        
    // if the token goes invalid we want to switch right back to
    // the login view, however we do it with a slight delay in order to
    // account for a race between this and the login view dissappearing
    // a moment before
    [self performSelector:@selector(showLoginView)
               withObject:nil
               afterDelay:0.5f];
}


@end
