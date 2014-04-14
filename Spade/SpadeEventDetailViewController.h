//
//  SpadeEventDetailViewController.h
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpadeFollowCell.h"
#import <Parse/Parse.h>

@protocol SpadeEventDetailControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;


@end

@interface SpadeEventDetailViewController : UIViewController <SpadeFollowCellDelegate>

@property (weak, nonatomic)  UIButton *leftButton;
@property (weak, nonatomic)  UIButton *rightButton;
@property (strong, nonatomic) PFObject *object;
@property (weak, nonatomic) IBOutlet UIButton *attendButton;

@property (nonatomic, assign) id<SpadeEventDetailControllerDelegate> delegate;


@end
