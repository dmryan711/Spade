//
//  SpadeCache.m
//  Spade
//
//  Created by Devon Ryan on 12/23/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeCache.h"
#import "SpadeConstants.h"
#import "SpadeUtility.h"

@interface SpadeCache ()

/*@property (strong, nonatomic) NSMutableArray *followingVenues;
@property (strong, nonatomic) NSMutableArray *followingUsers;
@property (strong, nonatomic) NSMutableArray *followingEvents;*/


@end

@implementation SpadeCache



static SpadeCache *sharedCache = nil;


+(SpadeCache *)sharedCache
{
    if (sharedCache == nil) {
        sharedCache = [[super allocWithZone:NULL]init];
    }
    
    return sharedCache;

}

-(SpadeCache *)init{
    self = [super init];
    
    if (self) {
        
        _cache = [[NSCache alloc]init];
      /*  _followingEvents = [[NSMutableArray alloc]init];
        _followingUsers = [[NSMutableArray alloc]init];
        _followingVenues = [[NSMutableArray alloc]init];*/
    }
    
    
    return self;

}


#pragma mark Add
-(void)addFollowedVenue:(PFObject *)followedVenue
{
    
    if ([self.cache objectForKey:spadeCache ]) {
       // NSLog(@"Major Diction Exists");
        if ([[self.cache objectForKey:spadeCache] objectForKey:spadeCacheVenues]) {
           // NSLog(@"Minor Diction Exists");
            [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues] addObject:followedVenue];
        }else{
            //Create Followed Venue Array
            NSLog(@"Creation");
            NSMutableArray *followedVenueArray = [[NSMutableArray alloc]initWithObjects:followedVenue, nil];
            [[self.cache objectForKey:spadeCache] addObject:followedVenueArray  forKey:spadeCacheVenues];
        }
    }else{
       // NSLog(@"Major Creation");
        //Create User Dictionary
        NSMutableArray *followedVenueArray = [[NSMutableArray alloc]initWithObjects:followedVenue, nil];
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]initWithDictionary:@{spadeCacheVenues: followedVenueArray}];
        [self.cache setObject:userDictionary forKey:spadeCache];
    }
    
    //Log to Parse
    //[SpadeUtility user:[PFUser currentUser] followingVenue:followedVenue]; //DO NOT LOG TO PARSE WHEN INITIALLY SETTING CACHE, IF ITS BEING LOADED INTO CACHE INITIALLY, WE ALREADY HAVE IT IN PARSE
   
}
-(void)addAttendingEvent:(PFObject *)attendingEvent
{
    if ([self.cache objectForKey:spadeCache ]) {
        if ([[self.cache objectForKey:spadeCache] objectForKey:spadeCacheEvents]) {
            [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents] addObject:attendingEvent];
        }else{
            //Create Attending Event Array
            NSMutableArray *attendingEventsArray = [[NSMutableArray alloc]initWithObjects:attendingEvent, nil];
            [[self.cache objectForKey:spadeCache] addObject:attendingEventsArray forKey:spadeCacheEvents];
        }
    }else{
        //Create User Dictionary
        NSMutableArray *attendingEventsArray = [[NSMutableArray alloc]initWithObjects:attendingEvent, nil];
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]initWithDictionary:@{spadeCacheEvents: attendingEventsArray}];
        [self.cache setObject:userDictionary forKey:spadeCache];
    }
    
    //Log to Parse
    //[SpadeUtility user:[PFUser currentUser] attendingEvent:attendingEvent]; //DO NOT LOG TO PARSE WHEN INITIALLY SETTING CACHE, IF ITS BEING LOADED INTO CACHE INITIALLY, WE ALREADY HAVE IT IN PARSE

}
-(void)addFollowedUser:(PFUser *)followedUser
{

    if ([self.cache objectForKey:spadeCache ]) {
        if ([[self.cache objectForKey:spadeCache] objectForKey:spadeCacheUser]) {
            [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser] addObject:followedUser];
        }else{
            //Create Following User Array
            NSMutableArray *followedUserArray = [[NSMutableArray alloc]initWithObjects:followedUser, nil];
            [[self.cache objectForKey:spadeCache] addObject:followedUserArray forKey:spadeCacheUser];
        }
    }else{
        //Create User Dictionary
        NSMutableArray *followedUserArray = [[NSMutableArray alloc]initWithObjects:followedUser, nil];
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]initWithDictionary:@{spadeCacheUser: followedUserArray}];
        [self.cache setObject:userDictionary forKey:spadeCache];
    }
    
    //Log to Parse
    //[SpadeUtility user:[PFUser currentUser] followingUser:followedUser]; //DO NOT LOG TO PARSE WHEN INITIALLY SETTING CACHE, IF ITS BEING LOADED INTO CACHE INITIALLY, WE ALREADY HAVE IT IN PARSE
    

}


#pragma mark Remove
-(void)removeFollowedVenue:(PFObject *)followedVenue
{
    if ([self.cache objectForKey:spadeCache]) {
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues]) {
            if ([[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues] containsObject:followedVenue]) {
                [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues] removeObject:followedVenue];
            }
        }
    }
    
    //Remove from Parse
    [SpadeUtility user:[PFUser currentUser] unfollowingVenue:followedVenue];
}
-(void)removeAttendedEvent:(PFObject *)attendingEvent
{
    if ([self.cache objectForKey:spadeCache]) {
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents]) {
            if ([[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents] containsObject:attendingEvent]) {
                [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents] removeObject:attendingEvent];
            }
        }
    }
    
    //Remove from Parse
    [SpadeUtility user:[PFUser currentUser] unAttendingEvent:attendingEvent];
}
-(void)removeFollowedUser:(PFUser *)followedUser
{
    if ([self.cache objectForKey:spadeCache]) {
         NSLog(@"Main Cache Exists");
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser]) {
             NSLog(@"     User Cache Exists");
            if ([[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser] containsObject:followedUser]) {
                [[[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser] removeObject:followedUser];
                 NSLog(@"   User Removed");
            }
        }
    }
    
    [SpadeUtility user:[PFUser currentUser] unfollowingUser:followedUser];
    
}




#pragma mark Get

-(NSArray *)followedVenues
{
    if ([self.cache objectForKey:spadeCache]) {
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues]) {
            return [[self.cache objectForKey:spadeCache]objectForKey:spadeCacheVenues];
        }
    }
    
    //No Cached Venues
    return nil;
}

-(NSArray *)attendingEvents
{
    if ([self.cache objectForKey:spadeCache]) {
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents]) {
            return [[self.cache objectForKey:spadeCache]objectForKey:spadeCacheEvents];
        }
    }
    
    //No Cached Events
    return nil;

}

-(NSArray *)followedUsers
{
    if ([self.cache objectForKey:spadeCache]) {
        if ([[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser]) {
            return [[self.cache objectForKey:spadeCache]objectForKey:spadeCacheUser];
        }
    }
    
    //No Cached Users
    return nil;
}



@end
