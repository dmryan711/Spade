//
//  SpadeCache.h
//  Spade
//
//  Created by Devon Ryan on 12/23/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface SpadeCache : NSObject


+(SpadeCache *)sharedCache;

@property (strong, nonatomic) NSCache *cache;

-(void)addFollowedVenue:(PFObject *)followedVenue;
-(void)addAttendingEvent:(PFObject *)attendingEvent;
-(void)addFollowedUser:(PFUser *)followedUser;

-(void)removeFollowedVenue:(PFObject *)followedVenue;
-(void)removeAttendedEvent:(PFObject *)attendingEvent;
-(void)removeFollowedUser:(PFUser *)followedUser;

-(NSArray *)followedVenues;
-(NSArray *)attendingEvents;
-(NSArray *)followedUsers;


@end
