//
//  LocationViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>{
    
    IBOutlet MKMapView* map;
    IBOutlet UIBarButtonItem* myPosition;
    CLLocationManager* manager;
}

@end
