//
//  SpadeContainerViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/15/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeContainerViewController.h"
#import "SCDragAffordanceView.h"
#import "SpadePresentTransistion.h"
#import "SpadeDismissTransistion.h"

@interface SpadeContainerViewController () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) SCDragAffordanceView *leftPullView;
@property (nonatomic, strong) SCDragAffordanceView *rightPullView;
@property (nonatomic, strong) SCDragAffordanceView *bottomPullView;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation SpadeContainerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    
    self.enclosingScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.enclosingScrollView.alwaysBounceHorizontal = YES;
    self.enclosingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.enclosingScrollView.delegate = self;
    
    if (self.shouldScroll) {
        self.enclosingScrollView.scrollEnabled = YES;
    }else{
        self.enclosingScrollView.scrollEnabled = NO;
    }
    
    [self.view addSubview:self.enclosingScrollView];
    
    
    if (self.mainViewController) {
        [self.enclosingScrollView   addSubview:self.mainViewController.view];
    }else if (self.mainTableViewController){
        [self.enclosingScrollView addSubview:self.mainTableViewController.view];
    }else if (self.mainNavigationController){
        
        [self.enclosingScrollView addSubview:self.mainNavigationController.view];

       // [self.enclosingScrollView addSubview:[[self.mainNavigationController.viewControllers objectAtIndex:0] view]];
    }
    
    if (self.isPullFromRightEnabled) {
        if (self.rightMenuViewController) {
            self.rightMenuViewController.transitioningDelegate = self;
            self.rightMenuViewController.modalPresentationStyle = UIModalPresentationCustom;
        }else if (self.rightMenuTableViewController){
            self.rightMenuTableViewController.transitioningDelegate = self;
            self.rightMenuTableViewController.modalPresentationStyle = UIModalPresentationCustom;
        }
        self.rightPullView = [[SCDragAffordanceView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.enclosingScrollView.bounds) + 10.f, CGRectGetMidY(self.enclosingScrollView.bounds) - 25.f, 50.f, 50.f)];
        [self.enclosingScrollView addSubview:self.rightPullView];
        
    }
    

    
    if (self.isPullFromLeftEnabled) {
        self.leftPullView = [[SCDragAffordanceView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.enclosingScrollView.bounds) -10.f, CGRectGetMidY(self.enclosingScrollView.bounds) - 25.f, 50.f, 50.f)];
        [self.enclosingScrollView addSubview:self.leftPullView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ScrollDirection scrollDirection;
    if (self.lastContentOffset > scrollView.contentOffset.x){
        scrollDirection = ScrollDirectionRight;
        self.leftPullView.progress = scrollView.contentOffset.x / CGRectGetWidth(self.leftPullView.bounds);
        
    }else if (self.lastContentOffset < scrollView.contentOffset.x)
        scrollDirection = ScrollDirectionLeft;
        self.rightPullView.progress = scrollView.contentOffset.x / CGRectGetWidth(self.rightPullView.bounds);

    //reset lastContenOffset
    //self.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (self.leftPullView.progress >= 1.f)
    {
        if (self.leftMenuTableViewController) {
            [self presentViewController:self.leftMenuTableViewController
                               animated:YES
                             completion:NULL];
        }else if (self.leftMenuViewController){
            [self presentViewController:self.leftMenuViewController
                               animated:YES
                             completion:NULL];
        }
    }else
    {
        self.leftPullView.progress = 0.f;
    }
    
    //Right
    if (self.rightPullView.progress >= 1.f)
    {
        if (self.rightMenuTableViewController) {
            [self presentViewController:self.rightMenuTableViewController
                               animated:YES
                             completion:NULL];
        }else if (self.rightMenuViewController){
            [self presentViewController:self.rightMenuViewController
                               animated:YES
                             completion:NULL];
        }
    }else
    {
        self.rightPullView.progress = 0.f;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[SpadePresentTransistion alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[SpadeDismissTransistion  alloc] init];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
