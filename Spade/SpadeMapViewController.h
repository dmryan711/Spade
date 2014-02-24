//
//  SpadeMapViewController.h
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import  <CoreLocation/CoreLocation.h>

@interface SpadeMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
