//
//  LocationViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SMAnnotation.h"
#import "SMAnnotationView.h"

@interface LocationViewController ()

-(void)reuseAnnotation;

@end

@implementation LocationViewController


-(id<OpereDao>)dao{
    
    if (!dao) {
        
        dao = [[OpereDaoXML alloc] init];
    }
    
    return dao;
}


+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


-(IBAction)adjustedRegion:(id)sender{
    
    _regionVisible =
    MKCoordinateRegionMakeWithDistance(_map.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [_map regionThatFits:_regionVisible];
    [_map setRegion:adjustedRegion animated:YES];
    [self reuseAnnotation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _map.delegate = self;
    _tagAnnotation = 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
   // [manager stopUpdatingLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
        
    //Aspetto il caricamento della vista prima modificare l'area di interesse
    
    [self performSelector:@selector(adjustedRegion:) withObject:self afterDelay:0.5f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


-(void)reuseAnnotation{
    
    for (id<MKAnnotation> annotation in _map.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        [_map removeAnnotation:annotation];
    }
    
    
    [_artWorks removeAllObjects];

    NSDictionary* artworks = [self.dao loadArtWorksInRegion];
        
    for (id index in artworks) {
        
        id object = [artworks objectForKey:index];
        
        CLLocationDegrees latitude =  [[object valueForKey:@"latitude"]  doubleValue];
        CLLocationDegrees longitude = [[object valueForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate ;
        
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        SMAnnotation* annotation = [[SMAnnotation alloc] initWithLocation:coordinate];
        
        annotation.title = [object objectForKey:@"title"];
        
        [_map addAnnotation:(id)annotation];
        
        [_artWorks addObject:object];
    }
        
}

#pragma mark -
#pragma mark ===  Delegate Methods  ===
#pragma mark -


#pragma mark Map View


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

    if (annotation == mapView.userLocation) 
        return nil;
    
    
    static NSString* SMAnnotationIdentifier = @"SMAnnotationIdentifier";
    MKPinAnnotationView* pinView =
    (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:SMAnnotationIdentifier];
    if (!pinView)
    {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                                                                          reuseIdentifier:SMAnnotationIdentifier];
    
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = 
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.tag = _tagAnnotation++;
        
     return annotationView;

    }else
        
        pinView.annotation = annotation;
        
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
        
    
    [self performSegueWithIdentifier:@"Opera" sender:view];

}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    

}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}




#pragma mark -
#pragma mark ===  StoryBoard Method  ===
#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc
{
    _map.delegate = nil;
}

@end
