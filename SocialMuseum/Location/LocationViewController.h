//
//  LocationViewController.h
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOffsetRect 3000


@interface LocationViewController : UIViewController <MKMapViewDelegate>{
    
    IBOutlet MKMapView* _map;
    IBOutlet UIBarButtonItem* myPosition;
    NSMutableArray* _artWorks;
    NSInteger _tagAnnotation;
    
    bool _isLoad;
}

-(IBAction)adjustedRegion:(id)sender;

@end
