//
//  SpadeChatViewController.h
//  Spade
//
//  Created by Devon Ryan on 1/7/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface SpadeChatViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) PFObject *event;

@end
