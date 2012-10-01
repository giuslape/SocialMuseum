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
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileViewController.h"

NSString *const SMSessionStateChangedNotification = 
@"com.tadaa.Login:FBSessionStateChangedNotification";

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
    levelZoom = 500;
    
    // See if we have a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // To-do, show logged in view
        [self openSession];
    } else {
        // No, display the login page.
        [self showLoginView];
    }

    //Aspetto il caricamento della vista prima modificare l'area di interesse
    _isLoad = false;
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
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

- (void)viewWillAppear:(BOOL)animated{
    
    if (![[API sharedInstance] isAuthorized]) {
        
        [self showLoginView];
    }
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
                
        offsetRect.origin = MKMapPointMake(rect.origin.x - distanceOffset, rect.origin.y - distanceOffset);
        [self refreshAnnotations];
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
    
    if ([@"ShowLogin" compare:segue.identifier] == NSOrderedSame) {
        
        LoginViewController* login = [segue destinationViewController];
        
        login.delegate = self;
        
        return;
    }
    
    if ([@"ShowProfile" compare:segue.identifier] == NSOrderedSame)return;
    
    if ([@"Opera" compare:segue.identifier] == NSOrderedSame) {
        
    
    
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

- (void)showLoginView 
{    
    UIViewController *modalViewController = [self presentedViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is 
    // displayed, then getting back here means the login in progress did not successfully 
    // complete. In that case, notify the login view so it can update its UI appropriately.
    
    if (![modalViewController isKindOfClass:[LoginViewController class]]) {
        
        [self performSegueWithIdentifier:@"ShowLogin" sender:self];
        
    } else {
        LoginViewController* loginViewController = 
        (LoginViewController*)modalViewController;
        [loginViewController loginFailed];
    }
}

- (void)sessionStateChanged:(FBSession *)session 
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            if ([[self presentedViewController] 
                 isKindOfClass:[LoginViewController class]]) {
                [self dismissModalViewControllerAnimated:YES];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to 
            // be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:SMSessionStateChangedNotification 
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
         [self sessionStateChanged:session 
                             state:status
                             error:error];
     }];
}

-(void)loginButtonDidPressed:(LoginViewController *)sender{
    
    [self openSession];
    sender.delegate = nil;
    
    
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

-(void)populateUserDetails{
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, 
           NSDictionary<FBGraphUser> *user, 
           NSError *error) {
             if (!error) {
                 NSString* command = @"loginWithFB";
                 NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:command, @"command", user.name, @"username", user.id, @"FBId", nil];
                 //chiama l'API web
                 [[API sharedInstance] commandWithParams:params onCompletion:^(NSDictionary *json) {
                     //Risultato
                     NSDictionary* res = [[json objectForKey:@"result"] objectAtIndex:0];
                     if ([json objectForKey:@"error"]==nil && [[res objectForKey:@"IdUser"] intValue]>0) {
                         [[API sharedInstance] setUser: res];
                         //Mostra Messaggio
                         [[[UIAlertView alloc] initWithTitle:@"Logged in" message:[NSString stringWithFormat:@"Welcome %@",[res objectForKey:@"username"]] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
                     } else {
                         //error
                         [UIAlertView error:[json objectForKey:@"error"]];
                     }
                 }];
                 
             }
         }];      
    }

}


@end
