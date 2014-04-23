//
//  SpadeUtility.h
//  Spade
//
//  Created by Devon Ryan on 11/30/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface SpadeUtility : NSObject

+(NSInteger)age:(NSDate *)dateOfBirth;
+(void)processProfilePictureData:(NSData *)newProfilePictureData ;
+(void)processUserName:(NSString *)name forUser:(PFUser *)user;
+(NSString *)processCurrencyLevel:(NSNumber *)level;
+(NSString *)processBottleService:(BOOL)bottleServiceSupport;
+(void)loadFile:(PFFile *)file forImageView:(PFImageView *)imageView;
+(void)user:(PFUser *)user followingVenue:(PFObject *)venue;
+(void)user:(PFUser *)user unfollowingVenue:(PFObject *)venue;
+(void)user:(PFUser *)user attendingEvent:(PFObject *)event;
+(void)user:(PFUser *)user unAttendingEvent:(PFObject *)event;
+(void)user:(PFUser *)user followingUser:(PFUser *)friendUser;
+(void)user:(PFUser *)user followingUsers:(NSArray *)friendUsers;
+(void)user:(PFUser *)user unfollowingUser:(PFUser *)friendUser;
+(void)user:(PFUser *)user unfollowingUsers:(NSArray *)friendUsers;
+(void)user:(PFUser *)user creatingEventWithName:(NSString *)eventName forVenue:(PFObject *)venue forDate:(NSString *)date forTime:(NSString *)time withImageFile:(PFFile *)file;
+(long double)milesFromMeters:(long double)meters;
+(NSArray *)crunchUpdates:(NSMutableArray *)objectsFoundInQuery;
+(NSString *)dateStringFromString:(NSString *)dateString;


@end
