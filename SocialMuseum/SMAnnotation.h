//
//  SMAnnotation.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SMAnnotation : NSObject <MKAnnotation>{
    
    NSString* _title;
    NSString* _subTitle;
    
}

@property (nonatomic, readonly)             CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly)             NSString * description;
@property (nonatomic, readonly)             UIImage  * image;
@property (nonatomic, copy, readwrite)      NSString* title;
@property (nonatomic, copy, readwrite)      NSString* subTitle;


+(id)initWithLocation:(CLLocationCoordinate2D)c;
-(id)initWithLocation:(CLLocationCoordinate2D)c;

@end
