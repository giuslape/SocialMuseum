//
//  LocationViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

#define khorizontalAccuracy 100


@interface LocationViewController : UIViewController <MKMapViewDelegate>{
    
    IBOutlet MKMapView* _map;
    IBOutlet UIBarButtonItem* myPosition;
    NSInteger _tagAnnotation;
    
    bool _isLoad;
    
    double distanceOffset;
    double levelZoom;
    
    CLLocationDistance minLatitudinalMeters;
    CLLocationDistance minLongitudinalMeters;
}

-(IBAction)adjustedRegion:(id)sender;

@end
