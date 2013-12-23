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
+(NSString *)processCurrencyLevel:(NSNumber *)level;
+(NSString *)processBottleService:(BOOL)bottleServiceSupport;
+(void)loadFile:(PFFile *)file forImageView:(PFImageView *)imageView;
+(void)user:(PFUser *)user followingVenue:(PFObject *)venue;

@end
