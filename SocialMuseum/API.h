//
//  API.h
//  iReporter
//
//  Created by Giuseppe Lapenta on 9/6/12.
//  Copyright (c) 2012 Giuseppe Lapenta. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"

@class ArtWork;

typedef void (^JSONResponseBlock)(NSDictionary* json);

@interface API : AFHTTPClient

@property (strong, nonatomic) NSDictionary* user;
@property (strong, nonatomic) NSDictionary* temporaryUser;
@property (strong, nonatomic) NSDictionary* temporaryComment;
@property (strong, nonatomic) NSDictionary* temporaryPhoto;
@property (strong, nonatomic) NSDictionary* temporaryChunck;
@property (strong, nonatomic) NSArray* temporaryPhotosInfo;
@property (strong, nonatomic) ArtWork* temporaryArtWork;

+(API*)sharedInstance;
//check whether there's an authorized user
-(BOOL)isAuthorized;

-(BOOL)isMe;

//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;
-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;

-(void)loginWithFacebook;

-(void)logoutDidPressed;


@end
