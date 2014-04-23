//
//  SpadeContainerViewController.h
//  Spade
//
//  Created by Devon Ryan on 4/15/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpadeContainerViewController : UIViewController

//@property (assign) BOOL isPullFromBottomEnabled;
@property (assign) BOOL isPullFromLeftEnabled;
@property (assign) BOOL isPullFromRightEnabled;

@property (nonatomic, strong) UIScrollView *enclosingScrollView;

@property (nonatomic, strong) UITableViewController *rightMenuTableViewController;
@property (nonatomic, strong) UITableViewController *leftMenuTableViewController;
@property (nonatomic, strong) UIViewController *rightMenuViewController;
@property (nonatomic, strong) UIViewController *leftMenuViewController;


@property (nonatomic, strong) UITableViewController *mainTableViewController;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UINavigationController *mainNavigationController;

@property (nonatomic) BOOL shouldScroll;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;




@end
