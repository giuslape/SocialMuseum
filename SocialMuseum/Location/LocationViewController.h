//
//  LocationViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OpereDaoXML.h"


@interface LocationViewController : UIViewController <MKMapViewDelegate>{
    
    IBOutlet MKMapView* _map;
    IBOutlet UIBarButtonItem* myPosition;
    id <OpereDao> dao;
    NSMutableArray* _artWorks;
    MKCoordinateRegion _regionVisible;
    NSInteger _tagAnnotation;
}

-(IBAction)adjustedRegion:(id)sender;

@end
