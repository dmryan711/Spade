//
//  SpadeMapSlideViewController.h
//  Spade
//
//  Created by Devon Ryan on 3/28/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpadeMapViewController.h"

@interface SpadeMapSlideViewController : UIViewController <SpadeMapViewControllerDelegate>

@property (strong, nonatomic) SpadeMapViewController *centerViewController;

@end
