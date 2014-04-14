//
//  SpadeMapViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeMapViewController.h"
#import "UIColor+FlatUI.h"

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
       _address = [[NSString alloc]init];
    }
    return self;
}


-(void)awakeFromNib
{
    if (!_address) _address = [[NSString alloc]init];

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
    
    self.locationManager = [[CLLocationManager alloc]init];
    
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self processDestination];
    
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftBtn.frame = CGRectMake(-10, 380, 30, 50);
    [leftBtn setTitle:@"☰" forState:UIControlStateNormal];
    leftBtn.backgroundColor = [UIColor blackColor];
    leftBtn.titleLabel.textColor = [UIColor amethystColor];
    leftBtn.alpha = .6;
    leftBtn.tag = 1;
    [leftBtn.layer setCornerRadius:0.0f];
    [leftBtn.layer setShadowOffset:CGSizeMake(2, 2)];
    [leftBtn.layer setShadowColor:[UIColor whiteColor].CGColor];
    [leftBtn.layer setShadowOpacity:0.8];
    [leftBtn addTarget:self action:@selector(getDirectionsPressed) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton = leftBtn;
    [self.view addSubview:self.leftButton];
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

-(void)getDirectionsPressed{
    
    NSLog(@"Directions Fired");
    MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:self.destinationPlaceMark];
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc]init];
    [directionsRequest setRequestsAlternateRoutes:YES];
    
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    [directionsRequest setSource:source];
    [directionsRequest setDestination:destination];
    //directionsRequest.
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:directionsRequest];
    
    
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        if (error) {
            NSLog(@"Directions Error");
           // return;
        }else{
            NSLog(@"Response From Apple API:%@",response);
            NSLog(@"Route From Apple API:%@",response.description);
            _currentRoute = [response.routes firstObject];
            NSLog(@"%@",_currentRoute.description);
            [self plotRoute:_currentRoute];
            [self includeAllPoints];
            
            for (MKRouteStep *step in _currentRoute.steps)
            {
                NSLog(@"%@: %f", step.instructions, step.distance);
                
            }
            
            
        }
    
    }];
    
  
}

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
    NSLog(@"Adress in Mapis %@",self.address);
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

- (void)movePanelRight:(UIButton *)sender {
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelRight];
            break;
        }
            
        default:
            break;
    }
}

- (void)movePanelUp:(UIButton *)sender {
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelUp];
            break;
        }
            
        default:
            break;
    }
}

@end
