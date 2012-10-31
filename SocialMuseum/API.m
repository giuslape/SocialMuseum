//
//  API.m
//  iReporter
//
//  Created by Giuseppe Lapenta on 9/6/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "API.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIAlertView+error.h"
#import "AppDelegate.h"


//the web location of the service
#define kAPIHost @"http://trinity.micc.unifi.it/"
#define kAPIPath @"social-museum/"

NSString *const SMUserStateChangeNotification = @"UserDetailsLoaded";

@implementation API

@synthesize user;

#pragma mark - Singleton methods
/**
 * Singleton methods
 */
+(API*)sharedInstance {
    static API *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHost]];
    });
    
    return sharedInstance;
}

#pragma mark - init
//intialize the API class with the deistination host name

-(API*)init {
    //call super init
    self = [super init];
    if (self != nil) {
        //initialize the object
        user = nil;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

-(BOOL)isAuthorized {
    return [[user objectForKey:@"IdUser"] intValue]>0;
}

-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock {
	NSData* uploadFile = nil;
	if ([params objectForKey:@"file"]) {
		uploadFile = (NSData*)[params objectForKey:@"file"];
		[params removeObjectForKey:@"file"];
	}

    NSMutableURLRequest *apiRequest = [self multipartFormRequestWithMethod:@"POST" path:kAPIPath parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		if (uploadFile) {
			[formData appendPartWithFileData:uploadFile
                                        name:@"file"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
		}
	}];
    AFJSONRequestOperation* operation = [[AFJSONRequestOperation alloc] initWithRequest: apiRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success!
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failure
        completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
    }];
    [operation start];
}

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb {
    NSString* urlString = [NSString stringWithFormat:@"%@%@upload/%@%@.jpg", kAPIHost, kAPIPath, IdPhoto, (isThumb)?@"-thumb":@""];
    return [NSURL URLWithString:urlString];
}


-(void)loginWithFacebook{
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *userFB,
           NSError *error) {
             if (!error) {
                 NSString* command = @"loginWithFB";
                 NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command", userFB.name, @"username", userFB.id, @"FBId", nil];
                 //chiama l'API web
                 [self commandWithParams:params onCompletion:^(NSDictionary *json) {
                     //Risultato
                     NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
                     if ([json objectForKey:@"error"]==nil && [[res objectForKey:@"IdUser"] intValue]>0) {
                         [self setUser:res];
                         AppDelegate* delegate = [UIApplication sharedApplication].delegate;
                         [delegate showInitialViewController];
                         //Mostra Messaggio
                         [[[UIAlertView alloc] initWithTitle:@"Logged in" message:[NSString stringWithFormat:@"Welcome %@",[res objectForKey:@"username"]] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
                     } else {
                         //error
                         [UIAlertView error:[json objectForKey:@"error"]];
                     }
                 }];
                 
             }
         }];
    }
    
}


#pragma mark -
#pragma mark ===  Logout  ===
#pragma mark -

- (void)logoutDidPressed{
    
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else {
        NSString* command = @"logout";
        NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command",nil];
        //chiama l'API web
        [[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
            //Mostra Messaggio
            
            [self setUser:nil];
            
            AppDelegate* delegate = [UIApplication sharedApplication].delegate;
            
            [delegate logoutHandler];
            
        }];
        
    }
}

@end
