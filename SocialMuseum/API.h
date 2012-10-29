//
//  API.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 9/6/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"

typedef void (^JSONResponseBlock)(NSDictionary* json);

@interface API : AFHTTPClient

@property (strong, nonatomic) NSDictionary* user;

+(API*)sharedInstance;
//check whether there's an authorized user
-(BOOL)isAuthorized;
//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;
-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;

-(void)populateFacebookUserDetails;


@end
