//
//  SpadeUtility.h
//  Spade
//
//  Created by Devon Ryan on 11/30/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpadeUtility : NSObject

+(NSInteger)age:(NSDate *)dateOfBirth;
+(void)processProfilePictureData:(NSData *)newProfilePictureData ;
+(void)processUserName:(NSString *)name forUser:(PFUser *)user;
+(NSString *)processCurrencyLevel:(NSNumber *)level;
+(NSString *)processBottleService:(BOOL)bottleServiceSupport;
+(void)loadFile:(PFFile *)file forImageView:(PFImageView *)imageView;
+(void)user:(PFUser *)user followingVenue:(PFObject *)venue;
+(void)user:(PFUser *)user followingUser:(PFUser *)user;
+(void)user:(PFUser *)user followingUsers:(NSArray *)users;

@end
