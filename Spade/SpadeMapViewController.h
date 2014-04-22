//
//  SpadeMapViewController.h
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import  <CoreLocation/CoreLocation.h>

@protocol SpadeMapViewControllerDelegate <NSObject>

@optional
- (void)movePanelUp;
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;


@end

@interface SpadeMapViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) PFObject *venue;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong,nonatomic) UIButton *bottomButton;
@property (strong, nonatomic) UIButton *directionsButton;

@property (nonatomic) CGRect frame;

@property (nonatomic, assign) id<SpadeMapViewControllerDelegate> delegate;


-(void)addLocations:(NSArray *)venueObjects atIndex:(int)index;
-(void)shiftDirectionsButton;

@end
