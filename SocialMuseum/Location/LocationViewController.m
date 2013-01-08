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
#import "API.h"
#import "UIAlertView+error.h"
#import "AppDelegate.h"


@interface LocationViewController ()

@property NSMutableArray* worksVisited;
@property MKMapRect offsetRect;
-(void)refreshAnnotations;

@end

@implementation LocationViewController

@synthesize offsetRect;

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
    MKCoordinateRegionMakeWithDistance(_map.userLocation.coordinate, levelZoom*2, levelZoom*2);
    MKCoordinateRegion region = [_map regionThatFits:_regionVisible];
    [_map setRegion:region animated:YES];
    
    offsetRect = MKMapRectMake(_map.visibleMapRect.origin.x - distanceOffset, _map.visibleMapRect.origin.y - distanceOffset, _map.visibleMapRect.size.width + 2*distanceOffset, _map.visibleMapRect.size.height + 2*distanceOffset);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _map.delegate = self;
    _tagAnnotation = 0;
    offsetRect = MKMapRectNull;
    distanceOffset = 5000;
    levelZoom = 200;
    self.worksVisited = [NSMutableArray arrayWithCapacity:0];
    [[API sharedInstance] setTemporaryArtWork:nil];
    //Aspetto il caricamento della vista prima modificare l'area di interesse
    _isLoad = false;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionStateChanged:)
                                                 name:SMSessionStateChangedNotification
                                               object:nil];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _map.delegate = nil;

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
        
    //Definisco il quadrato che contiene la mappa
    MKMapPoint p11 = MKMapPointMake(MKMapRectGetMinX(offsetRect), MKMapRectGetMinY(offsetRect));
    MKMapPoint p22 = MKMapPointMake(MKMapRectGetMaxX(offsetRect), MKMapRectGetMaxY(offsetRect));
    
    NSString* latMin = [NSString stringWithFormat:@"%f",MKCoordinateForMapPoint(p22).latitude];
    NSString* latMax = [NSString stringWithFormat:@"%f",MKCoordinateForMapPoint(p11).latitude];
    NSString* longMin= [NSString stringWithFormat:@"%f",MKCoordinateForMapPoint(p11).longitude];
    NSString* longMax= [NSString stringWithFormat:@"%f",MKCoordinateForMapPoint(p22).longitude];
    
    [[API sharedInstance]commandWithParams:[NSMutableDictionary dictionaryWithObject:@"userInteractions" forKey:@"command"] onCompletion:^(NSDictionary *json) {
        
        if (![json objectForKey:@"error"]) {
            
        [self.worksVisited addObjectsFromArray:[json objectForKey:@"result"]];
            
        [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"artwork", @"command",latMax,@"lat_max",longMax,@"long_max",latMin,@"lat_min",longMin,@"long_min",nil] 
                               onCompletion:^(NSDictionary *json) {
        
                                   if (![json objectForKey:@"error"]) {
                                       //Carica i punti di interesse
                                       [self opereCaricate:[json objectForKey:@"result"]];
                                   } else {
                                       //Errore
                                       NSString* errorMsg = [json objectForKey:@"error"];
                                       [UIAlertView error:errorMsg];
                                   }
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                               }];
        }
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
    
    if (smAnnotation.isSelected) annotationView.pinColor = MKPinAnnotationColorGreen;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = 
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
     return annotationView;

    }else
        
        pinView.annotation = annotation;
    
    if (smAnnotation.isSelected) pinView.pinColor = MKPinAnnotationColorGreen;
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"Opera" sender:view];

    [mapView deselectAnnotation:view.annotation animated:YES];
    
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    if (!_isLoad) {
        [self adjustedRegion:self];
        _isLoad = true;
        [self refreshAnnotations];
    }
}


#pragma mark -
#pragma mark ===  Opere Caricate  ===
#pragma mark -


-(void)opereCaricate:(NSArray *)artworks{
            
    for (NSDictionary* object in artworks) {
                        
        CLLocationDegrees latitude =  [[object valueForKey:@"latitude"]  doubleValue];
        CLLocationDegrees longitude = [[object valueForKey:@"longitude"]  doubleValue];
        
        CLLocationCoordinate2D coordinate ;
        
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        SMAnnotation* annotation = [[SMAnnotation alloc] initWithLocation:coordinate];
        
        annotation.title = [object objectForKey:@"Nome"];
        
        NSString* imageUrl = [object objectForKey:@"Foto"];
                                      
        annotation.imageUrl = imageUrl;
        
        annotation.IdOpera = [object objectForKey:@"IdOpera"];
        
        //Controlla se l'opera è stata già visitata
        for (NSDictionary* dict in self.worksVisited) {
            
            if (annotation.isSelected) break;
            NSNumber* idOperaVisitata = [NSNumber numberWithInt:[[dict objectForKey:@"IdOpera"] intValue]];
            if ([idOperaVisitata intValue] == [annotation.IdOpera intValue])
            [annotation setIsSelected:YES];
        }
        
        [_map addAnnotation:(id)annotation];
        
        _tagAnnotation++;
                
        levelZoom =  MAX(levelZoom,MKMetersBetweenMapPoints(MKMapPointForCoordinate(_map.userLocation.coordinate), MKMapPointForCoordinate(coordinate)));
    }
    
    if ([artworks count] == 0) {
        
        distanceOffset = distanceOffset * 10;
        [self refreshAnnotations];        
    }
    
    [self adjustedRegion:self];

}


#pragma mark -
#pragma mark ===  StoryBoard Method  ===
#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([@"ShowProfile" compare:segue.identifier] == NSOrderedSame)return;
    
    if ([@"Opera" compare:segue.identifier] == NSOrderedSame) {
        
        MKAnnotationView* annotationView = (MKAnnotationView *)sender;
    
        SMAnnotation* annotation = (SMAnnotation *)annotationView.annotation;
    
        ArtWork* artWork = [[ArtWork alloc] init];
    
        [artWork setTitle:annotation.title];
        [artWork setIdOpera:annotation.IdOpera];
        [artWork setImageUrl:annotation.imageUrl];
     
        [[API sharedInstance] setTemporaryArtWork:artWork];
    
    }
}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc
{
    
}

#pragma mark -
#pragma mark ===  Login Handler  ===
#pragma mark -



- (void)sessionStateChanged:(NSNotification*)notification {
    
    if (![[API sharedInstance] isAuthorized]) {
        [[API sharedInstance] loginWithFacebook];
    }

}


@end
