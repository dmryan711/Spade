//
//  SpadeCache.m
//  Spade
//
//  Created by Devon Ryan on 12/23/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeCache.h"

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
        _followingEvents = [[NSMutableArray alloc]init];
        _followingUsers = [[NSMutableArray alloc]init];
        _followingVenues = [[NSMutableArray alloc]init];
    }
    
    
    return self;

}

@end
