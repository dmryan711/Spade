//
//  SpadePresentTransistion.m
//  Spade
//
//  Created by Devon Ryan on 4/15/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadePresentTransistion.h"

@implementation SpadePresentTransistion


// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5f;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"BOOOOM");
    UIViewController *presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *overlayViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    [containerView  addSubview: presentingViewController.view];

    
    [containerView addSubview:overlayViewController.view];
    
    //overlayViewController.view.frame = CGRectMake(0, 0, 0, 0);
    
    overlayViewController.view.alpha  = 0.f;
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration
                     animations:^{
                         //overlayViewController.view.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height);
                        
                         overlayViewController.view.alpha = .8f;
                     } completion:^(BOOL finished){
                         BOOL transitionWasCancelled = [transitionContext transitionWasCancelled];
                         [transitionContext completeTransition:transitionWasCancelled == NO];
                     }];
    

}

@end
