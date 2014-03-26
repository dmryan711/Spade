//
//  SpadeMapViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeMapViewController.h"

//#define GOOGLE_API_KEY @"AIzaSyAttvyb7k5KKfUpD-TYZlGutUQNMWBovUY"


@interface SpadeMapViewController ()

@property (strong, nonatomic) MKPlacemark* destinationPlaceMark;
@property (weak, nonatomic) MKPolyline *routeOverlay;
@property (strong, nonatomic) MKRoute *currentRoute;

@end

@implementation SpadeMapViewController

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
	// Do any additional setup after loading the view.
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Directions" style:UIBarButtonItemStyleBordered target:self action:@selector(getDirectionsPressed)];
    
    self.mapview.delegate  = self;
    self.locationManager.delegate  = self;
    
    [self.mapview setShowsUserLocation:YES];
    [self.mapview setShowsBuildings:YES];
    
   // [self processDestination];
    
    self.locationManager = [[CLLocationManager alloc]init];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self processDestination];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods.
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(self.destinationPlaceMark.coordinate,1700,1700);
   

    
    [mv setRegion:region animated:YES];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return  renderer;
}

/*-(void)getDirectionsPressed{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:self.destinationPlaceMark];
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc]init];
    [directionsRequest setRequestsAlternateRoutes:YES];
    
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    [directionsRequest setSource:source];
    [directionsRequest setDestination:destination];
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:directionsRequest];
    
    
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        if (error) {
            NSLog(@"Directions Error");
           // return;
        }else{
            _currentRoute = [response.routes firstObject];
            [self plotRoute:_currentRoute];
            [self includeAllPoints];
        }
    
    }];
    
  
}*/

#pragma mark Location Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  /*  //if we pressed get directions call it again
    if (!self.navigationItem.rightBarButtonItem.isEnabled) {
        [self getDirectionsPressed];
    }*/
}


#pragma mark { }

-(void)processDestination{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         self.destinationPlaceMark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
                         [self.mapview addAnnotation:self.destinationPlaceMark];
                         
                     }
                 }
     ];

}

-(void)plotRoute:(MKRoute *)route
{
    if (_routeOverlay) {
        [self.mapview removeOverlay:_routeOverlay];
    }
    
    _routeOverlay = route.polyline;
    [self.mapview addOverlay:_routeOverlay];
}

#define MAP_PADDING 1.5
#define MINIMUM_VISIBLE_LATITUDE 0.01
-(void)includeAllPoints
{
    
    CLLocationDegrees currentLocationLat =self.locationManager.location.coordinate.latitude;
    CLLocationDegrees currentLocationLong = self.locationManager.location.coordinate.longitude;
    
    CLLocationDegrees destinationLat = self.destinationPlaceMark.coordinate.latitude;
    CLLocationDegrees destinationLong = self.destinationPlaceMark.coordinate.longitude;
    
    MKCoordinateRegion region;
    region.center.latitude = (currentLocationLat + destinationLat)/2;
    region.center.longitude = (currentLocationLong + destinationLong)/2;
    
    if (currentLocationLat >= destinationLat) {
        region.span.latitudeDelta = (currentLocationLat - destinationLat) * MAP_PADDING;
    }else{
         region.span.latitudeDelta = (destinationLat - currentLocationLat) * MAP_PADDING;
    }
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    if (currentLocationLong >= destinationLong) {
        region.span.longitudeDelta = (currentLocationLong - destinationLong) * MAP_PADDING;
    }else{
        region.span.longitudeDelta = (destinationLong - currentLocationLong) * MAP_PADDING;
    }
    
    MKCoordinateRegion scaledRegion = [self.mapview regionThatFits:region];
    [self.mapview setRegion:scaledRegion animated:YES];
    
    
}

@end
