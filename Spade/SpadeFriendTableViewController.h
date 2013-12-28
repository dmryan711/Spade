//
//  SpadeFriendTableViewController.h
//  Spade
//
//  Created by Devon Ryan on 12/25/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SpadeFollowCell.h"

@interface SpadeFriendTableViewController : PFQueryTableViewController <UIAlertViewDelegate,SpadeFollowCellDelegate>

@end
