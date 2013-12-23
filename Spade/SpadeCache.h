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

@property (strong, nonatomic) NSMutableArray *followingVenues;
@property (strong, nonatomic) NSMutableArray *followingUsers;
@property (strong, nonatomic) NSMutableArray *followingEvents;

+(SpadeCache *)sharedCache;


@end
