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
    __weak NSString* _description;
     UIImage*  _image;
    
}

@property (nonatomic, readonly)             CLLocationCoordinate2D coordinate;
@property (weak, nonatomic, readonly)       NSString * description;
@property (nonatomic, copy,readwrite)       UIImage  * image;
@property (nonatomic, copy, readwrite)      NSString * title;
@property (nonatomic, copy, readwrite)      NSString * subTitle;
@property (nonatomic, copy, readwrite)      NSNumber * IdOpera;
@property (nonatomic, copy, readwrite)      NSArray  * chunkDescription;
@property (nonatomic, copy, readwrite)      NSString    * imageUrl;
@property bool isSelected;

+(id)initWithLocation:(CLLocationCoordinate2D)c;
-(id)initWithLocation:(CLLocationCoordinate2D)c;

@end
