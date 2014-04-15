//
//  SpadeDismissTransistion.m
//  Spade
//
//  Created by Devon Ryan on 4/15/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeDismissTransistion.h"

@implementation SpadeDismissTransistion

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *dissmissingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:transitionDuration
                     animations:^{
                         dissmissingViewController.view.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         BOOL transitionWasCancelled = [transitionContext transitionWasCancelled];
                         [transitionContext completeTransition:transitionWasCancelled == NO];
                     }];
}

@end
