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

@property (strong,nonatomic) PFFile *pictureFile;
@property (strong,nonatomic) NSString *venueName;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *cover;
@property (nonatomic,strong) NSString *music;
@property (nonatomic,strong) NSString *spendLevel;
@property (nonatomic,strong) NSString *bottleService;
@property (nonatomic,strong) NSString *addressOfVenue;
@property (nonatomic, weak) PFObject *venue;


@end
