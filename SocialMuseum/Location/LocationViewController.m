//
//  LocationViewController.m
//  SocialMuseum
//
//  Created by Giuseppe Lapenta on 07/05/12.
//  Copyright (c) 2012 Lapenta. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "SMAnnotation.h"
#import "ArtWork.h"
#import "OperaViewController.h"
#import "API.h"
#import "UIAlertView+error.h"


@interface LocationViewController ()

-(void)refreshAnnotations;

@end

@implementation LocationViewController


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
    
    MKCoordinateRegion _regionVisible =
    MKCoordinateRegionMakeWithDistance(_map.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion region = [_map regionThatFits:_regionVisible];
    [_map setRegion:region animated:YES];
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
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //Aspetto il caricamento della vista prima modificare l'area di interesse
    _isLoad = false;

    [self performSelector:@selector(adjustedRegion:) withObject:self afterDelay:0.5f];
    
    [self performSelector:@selector(refreshAnnotations) withObject:nil afterDelay:2.0f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}


-(void)refreshAnnotations{
    
    for (id<MKAnnotation> annotation in _map.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            _isLoad = true;
            continue;
        }
        [_map removeAnnotation:annotation];
    }
    
    [_artWorks removeAllObjects];
    
    MKCoordinateRegion region = _map.region;
    
    NSLog(@"%f", region.center.latitude  -region.span.latitudeDelta);
    NSLog(@"%f", region.center.latitude  +region.span.latitudeDelta);
    NSLog(@"%f", region.center.longitude -region.span.longitudeDelta);
    NSLog(@"%f", region.center.longitude +region.span.longitudeDelta);
    
    
    NSString* latMin  = [NSString stringWithFormat:@"%f",region.center.latitude-region.span.latitudeDelta/2];
    NSString* latMax  = [NSString stringWithFormat:@"%f",region.center.latitude+region.span.latitudeDelta/2];
    NSString* longMin = [NSString stringWithFormat:@"%f",region.center.longitude-region.span.longitudeDelta/2];
    NSString* longMax = [NSString stringWithFormat:@"%f",region.center.longitude+region.span.longitudeDelta/2];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"artwork", @"command",latMax,@"lat_max", longMax,@"long_max",latMin,@"lat_min",longMin,@"long_min",nil] 
                               onCompletion:^(NSDictionary *json) {
        
        if (![json objectForKey:@"error"]) {
            //Carica i punti di interesse
            [self opereCaricate:[json objectForKey:@"result"]];
		} else {
			//Errore
			NSString* errorMsg = [json objectForKey:@"error"];
			[UIAlertView error:errorMsg];
		}
        [hud hide:YES];
	}];
}

#pragma mark -
#pragma mark ===  Delegate Methods  ===
#pragma mark -


#pragma mark Map View


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

    if (annotation == mapView.userLocation) 
        return nil;
    
    SMAnnotation* smAnnotation = (SMAnnotation *)annotation;
    
    static NSString* SMAnnotationIdentifier = @"SMAnnotationIdentifier";
    MKPinAnnotationView* pinView =
    (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:SMAnnotationIdentifier];
    if (!pinView)
    {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:smAnnotation 
                                                                          reuseIdentifier:SMAnnotationIdentifier];
    
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = 
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
     return annotationView;

    }else
        
        pinView.annotation = annotation;
        
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
        
    
    [self performSegueWithIdentifier:@"Opera" sender:view];

    [mapView deselectAnnotation:view.annotation animated:YES];
    
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
                
    if (_isLoad) [self refreshAnnotations];
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);    

}

#pragma mark -
#pragma mark ===  Opere Caricate  ===
#pragma mark -


-(void)opereCaricate:(NSArray *)artworks{
            
    for (int index = 0; index < [artworks count]; index++) {
        
        id object = [artworks objectAtIndex:index];
                
        CLLocationDegrees latitude =  [[object objectForKey:@"latitude"]  doubleValue];
        CLLocationDegrees longitude = [[object valueForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate ;
        
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        SMAnnotation* annotation = [[SMAnnotation alloc] initWithLocation:coordinate];
        
        annotation.title = [object objectForKey:@"Nome"];
        
        NSURL* imageUrl = [NSURL URLWithString:[object objectForKey:@"Foto"]];
                        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
              
        annotation.image = image;
        
        annotation.IdOpera = [object objectForKey:@"IdOpera"];
        
        [_map addAnnotation:(id)annotation];
        
        [_artWorks insertObject:object atIndex:_tagAnnotation];
        _tagAnnotation++;
        
    }

}


#pragma mark -
#pragma mark ===  StoryBoard Method  ===
#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
        
    MKAnnotationView* annotationView = (MKAnnotationView *)sender;
    
    SMAnnotation* annotation = (SMAnnotation *)annotationView.annotation;
    
    ArtWork* artWork = [[ArtWork alloc] init];
    
    [artWork setImage:annotation.image];
    [artWork setDescription:annotation.description];
    [artWork setTitle:annotation.title];
    [artWork setIdOpera:annotation.IdOpera];
        
    OperaViewController* viewController = [segue destinationViewController];
    
    viewController.artWork = [[ArtWork alloc] init];
        
    [viewController setArtWork:artWork];
    
}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc
{
    _map.delegate = nil;
}

@end
