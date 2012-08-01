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
    MKCoordinateRegionMakeWithDistance(_map.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion region = [_map regionThatFits:_regionVisible];
    [_map setRegion:region animated:YES];
    
    offsetRect = MKMapRectMake(_map.visibleMapRect.origin.x - kOffsetRect, _map.visibleMapRect.origin.y - kOffsetRect, _map.visibleMapRect.size.width + 2*kOffsetRect, _map.visibleMapRect.size.height + 2*kOffsetRect);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _map.delegate = self;
    _tagAnnotation = 0;
    offsetRect = MKMapRectNull;
    //Aspetto il caricamento della vista prima modificare l'area di interesse
    _isLoad = false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
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
          
    MKMapRect rect = mapView.visibleMapRect;
    
    if (!MKMapRectContainsRect(offsetRect, rect) && _isLoad) {
        
        [self refreshAnnotations];
        
        offsetRect.origin = MKMapPointMake(rect.origin.x - kOffsetRect, rect.origin.y - kOffsetRect);
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    if (!_isLoad) {
        
        [self adjustedRegion:self];
        _isLoad = true;
        [self refreshAnnotations];

    }
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    SMAnnotation* annotation = (SMAnnotation *)view.annotation;
    
    if ([annotation isKindOfClass:[MKUserLocation class]])return;
    AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:annotation.imageUrl] success:^(UIImage *image) {
        [annotation setImage:image];
        
    }];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [queue addOperation:imageOperation];
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"content", @"command",annotation.IdOpera,@"IdOpera", nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   annotation.chunkDescription = [NSArray arrayWithArray:[json objectForKey:@"result"]];
                                  // annotation.chunkDescription = [[annotation.chunkDescription reverseObjectEnumerator] allObjects];
                               }];
}

#pragma mark -
#pragma mark ===  Opere Caricate  ===
#pragma mark -


-(void)opereCaricate:(NSArray *)artworks{
            
    for (int index = 0; index < [artworks count]; index++) {
        
        id object = [artworks objectAtIndex:index];
                
        CLLocationDegrees latitude =  [[object valueForKey:@"latitude"]  doubleValue];
        CLLocationDegrees longitude = [[object valueForKey:@"longitude"]  doubleValue];
        
        CLLocationCoordinate2D coordinate ;
        
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        SMAnnotation* annotation = [[SMAnnotation alloc] initWithLocation:coordinate];
        
        annotation.title = [object objectForKey:@"Nome"];
                
        NSURL* imageUrl = [NSURL URLWithString:[object objectForKey:@"Foto"]];
                                      
        annotation.imageUrl = imageUrl;
        
        annotation.IdOpera = [object objectForKey:@"IdOpera"];
        
        [_map addAnnotation:(id)annotation];
        
        _tagAnnotation++;
        
    }

}


#pragma mark -
#pragma mark ===  StoryBoard Method  ===
#pragma mark -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
            
    MKAnnotationView* annotationView = (MKAnnotationView *)sender;
    
    SMAnnotation* annotation = (SMAnnotation *)annotationView.annotation;
    
    ArtWork* artWork = [[ArtWork alloc] init];
    
    [artWork setDescription:annotation.description];
    [artWork setTitle:annotation.title];
    [artWork setIdOpera:annotation.IdOpera];
    [artWork setImage:annotation.image];
    
    OperaViewController* viewController = [segue destinationViewController];
    
    viewController.artWork = [[ArtWork alloc] init];
        
    [viewController setArtWork:artWork];
    
    [viewController setDescription:annotation.chunkDescription];

}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc
{
    _map.delegate = nil;
}

@end
