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

@interface LocationViewController ()

-(void)revGeocode:(CLLocation*)c;
-(void)geocode:(NSString*)address;

@end

@implementation LocationViewController


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -

-(void)geocode:(NSString*)address
{
    
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    
    [gc geocodeAddressString:address completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         if ([placemarks count]>0) {
             
             CLPlacemark* mark = (CLPlacemark*)
             [placemarks objectAtIndex:0];
             double lat = mark.location.coordinate.latitude;
             double lng = mark.location.coordinate.longitude;
             
             //show the coords text

            NSLog(@"Coordinate\nlat: %@, long: %@",[NSNumber numberWithDouble: lat], [NSNumber numberWithDouble: lng]);
             
             //show on the map
             
             CLLocationCoordinate2D coordinate;
             coordinate.latitude = lat;
             coordinate.longitude = lng;
             
             [map addAnnotation:(id)[[SMAnnotation alloc]
                                     initWithCoordinate:coordinate]];
             
             MKCoordinateRegion viewRegion =
             MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 1000, 1000);
             MKCoordinateRegion adjustedRegion = [map regionThatFits:viewRegion];
             [map setRegion:adjustedRegion animated:YES];
             map.showsUserLocation = YES;
         }
     }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //start updating the location
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    map.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [manager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [manager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}



#pragma mark -
#pragma mark ===  Delegate Methods  ===
#pragma mark -



#pragma mark -
#pragma mark Core Location

- (void)locationManager:(CLLocationManager *)manager
                        didUpdateToLocation:(CLLocation *)newLocation
                        fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.coordinate.latitude !=
        oldLocation.coordinate.latitude) {
        [self revGeocode: newLocation];
    }
}

-(void)revGeocode:(CLLocation*)c
{
 
    CLGeocoder* gcrev = [[CLGeocoder alloc] init];
    [gcrev reverseGeocodeLocation:c completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark* revMark = [placemarks objectAtIndex:0];
         NSArray* addressLines =
         [revMark.addressDictionary objectForKey:@"FormattedAddressLines"];
         NSString* revAddress =
         [addressLines componentsJoinedByString: @"\n"];
         NSLog(@"Reverse geocoded address: \n%@", revAddress);
         [self geocode:revAddress];
     }];
}

#pragma mark -
#pragma mark Map View


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation {
    if (annotation == mapView.userLocation) 
        return nil;
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    pinView.pinColor = MKPinAnnotationColorPurple;
    pinView.canShowCallout = YES;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pinView.animatesDrop = YES;
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
        
    [self performSegueWithIdentifier:@"Opera" sender:view];
    
}


#pragma mark -
#pragma mark ===  StoryBoard Method  ===
#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    
}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc
{
    manager.delegate = nil;
    map.delegate = nil;
}

@end
