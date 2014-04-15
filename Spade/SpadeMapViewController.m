//
//  SpadeMapViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeMapViewController.h"
#import "UIColor+FlatUI.h"
#import "NSString+URLEncoding.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SpadeConstants.h"

#define GOOGLE_API_KEY @"AIzaSyCR-VUyP05mZowGrUyzlD0qzVPOH2UbKaE"


@interface SpadeMapViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) GMSMarker *venueLocation;
@property GMSMapView *mapView_;
@property (strong, nonatomic) NSString *address;
@property BOOL didUpdateScreen;




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
    
    self.address = [self.venue objectForKey:spadeVenueAddress];
    self.didUpdateScreen = NO;
    //self.tabBarController.tabBar.hidden = YES;
    //self.view = self.mapView
    
    //self.view = self.mapView;
    //[self geoCodeAddress:self.address];
	// Do any additional setup after loading the view.
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Directions" style:UIBarButtonItemStyleBordered target:self action:@selector(getDirectionsPressed)];
    
    //https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=true_or_false&key=API_KEY

    
   // self.mapview.delegate  = self;
    self.locationManager.delegate  = self;
    
   // [self.mapview setShowsUserLocation:YES];
    //[self.mapview setShowsBuildings:YES];
    
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
    [leftBtn addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton = leftBtn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*#pragma mark - MKMapViewDelegate methods.
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

-(void)geoCodeAddress:(NSString *)address
{
    NSURL *url  =[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&key=%@",[self.address URLEncodedString_ch],GOOGLE_API_KEY]];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSError *error;
    
    NSData *googleGeoCodeResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *string = [[NSString alloc]initWithData:googleGeoCodeResponse encoding:NSUTF8StringEncoding];
    if (!error) {
        NSLog(@"%@",string);
    }else{
        NSLog(@"Error");
       
    }
    

    

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
    
  
}*/

#pragma mark Location Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Called");
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
                     if (placemarks && placemarks.count > 0)
                     {
                         NSLog(@"Placemark: %@",[[placemarks objectAtIndex:0]description]);
                         MKPlacemark *placemark = [[MKPlacemark alloc]initWithPlacemark:[placemarks objectAtIndex:0]];
                         
                         _venueLocation = [[GMSMarker alloc]init];
                         self.venueLocation.position =CLLocationCoordinate2DMake(placemark.coordinate.latitude, placemark.coordinate.longitude);
                         
                         self.venueLocation.snippet  = @"Test";
                         
                         NSLog(@"%f   %f",self.venueLocation.position.latitude,self.venueLocation.position.longitude);
                         
                         GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.venueLocation.position.latitude longitude:self.venueLocation.position.longitude zoom:15];
                        _mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
                         self.mapView_.myLocationEnabled = YES;
                         self.mapView_.buildingsEnabled = YES;
                         self.view = self.mapView_;
                         self.venueLocation.title = [self.venue objectForKey:spadeVenueName];
                         self.venueLocation.snippet = [NSString stringWithFormat:@"%@\nCategory:%@\nMusic Genre:%@",[self.venue objectForKey:spadeVenueAddress],[self.venue objectForKey:spadeVenueCategory],[self.venue objectForKey:spadeVenueGenre]];
                         self.venueLocation.map = self.mapView_;
                         [self.mapView_ addSubview:self.leftButton];
                         [self.mapView_ addObserver:self forKeyPath:@"myLocation" options:0 context:nil];
                         self.mapView_.settings.myLocationButton = YES;
                         [self.mapView_ bringSubviewToFront:self.leftButton];
                         NSLog(@"MY LOCATION: %@", self.mapView_.myLocation);
                         
                     }
                 }
     ];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"myLocation"]) {
        if (!self.didUpdateScreen) {
            self.didUpdateScreen = YES;
            CLLocation *myLoc = [object myLocation];
            GMSCoordinateBounds *boundsWithUserLocation = [[GMSCoordinateBounds alloc]initWithCoordinate:self.venueLocation.position coordinate:myLoc.coordinate];
             [self.mapView_ animateToCameraPosition:[self.mapView_ cameraForBounds:boundsWithUserLocation insets:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height+20, 0, self.tabBarController.tabBar.frame.size.height+10,0 )]];
            
            [self.mapView_ animateToViewingAngle:45];
        }
        
    }
}

-(void)getDirections
{
    
    NSString *origin = [NSString stringWithFormat:@"%f%%2C%f",self.mapView_.myLocation.coordinate.latitude, self.mapView_.myLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat:@"%f%%2C%f",self.venueLocation.position.latitude, self.venueLocation.position.longitude];
    NSLog(@"%@",origin);
    NSLog(@"%@",destination);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true&departure_time=%d&mode=transit",origin,destination,1396539817]];
    
    NSLog(@"%@",url.description);
                  
                      //http://maps.googleapis.com/maps/api/directions/json?origin=360+W+34th+street+new+york&destination=92+Ludlow+Street+new+york&sensor=false&departure_time=1396539817&mode=transit"];
                        //https://maps.googleapis.com/maps/api/directions/json?origin=40.745242-73.985625&destination=40.718372-73.988938&sensor=true&departure_time=1396539817&mode=transit
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *string = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    if (!error) {
        NSLog(@"%@",string);
    }
    [self parseGoogleResponse:responseData];
}

-(void)parseGoogleResponse:(NSData *)response
{
    /*NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSArray *routes = [json objectForKey:@"routes"];
    NSDictionary *directions = [routes objectAtIndex:0];
    NSDictionary *legs = [[directions objectForKey:@"legs"] objectAtIndex:0];
    NSLog(@"Count %lu",(unsigned long)legs.count);
    
    NSEnumerator *enumer = [legs objectEnumerator];
    id step;
    NSMutableArray *steps = [[NSMutableArray alloc]init];
    while (step  = [enumer nextObject]) {
        [steps addObject:step];
    }
    
    
    
   // NSArray *steps = [legs objectAtIndex:1];
   // NSArray *detailedSteps = [steps objectAtIndex:1];
    
   NSLog(@"HERE:%@",[steps description]);*/

}




/*-(void)plotRoute:(MKRoute *)route
{
    if (_routeOverlay) {
     //   [self.mapview removeOverlay:_routeOverlay];
    }
    
    _routeOverlay = route.polyline;
    //[self.mapview addOverlay:_routeOverlay];
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
    
    //MKCoordinateRegion scaledRegion = [self.mapview regionThatFits:region];
    //[self.mapview setRegion:scaledRegion animated:YES];
    
    
}*/

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
