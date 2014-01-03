//
//  SpadeVenueDetailViewController.h
//  Spade
//
//  Created by Devon Ryan on 12/14/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface SpadeVenueDetailViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) PFObject *venue;
@property BOOL isFollowing;


@end
