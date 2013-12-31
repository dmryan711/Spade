//
//  SpadeConstants.h
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpadeConstants : NSObject

extern NSString * const spadePicFLag;
extern NSString * const spadeNameFlag;
extern NSString * const spadeFirstLoginFlag;

//User Class
extern NSString * const spadeClassUser;

extern NSString * const spadeUserFriends;
extern NSString * const spadeUserEmail;
extern NSString * const spadeUserGender;
extern NSString * const spadeUserLocale;
extern NSString * const spadeUserBirthday;
extern NSString * const spadeUserAge;
extern NSString * const spadeUserFacebookId;
extern NSString * const spadeUserDisplayName;
extern NSString * const spadeUserMediumProfilePic;
extern NSString * const spadeUserSmallProfilePic;


//Activity Class
extern NSString * const spadeClassActivity;

extern NSString * const spadeActivityFromUser;
extern NSString * const spadeActivityToUser;
extern NSString * const spadeActivityToVenue;
extern NSString * const spadeActivityToEvent;
extern NSString * const spadeActivityAction;

extern NSString * const spadeActivityActionFollowingVenue;
extern NSString * const spadeActivityActionFollowingUser;


//Venue
extern NSString * const spadeClassVenue;
extern NSString * const spadeVenueName;
extern NSString * const spadeVenueCategory;
extern NSString * const spadeVenueSpendLevel;
extern NSString * const spadeVenueAddress;
extern NSString * const spadeVenueTableService;
extern NSString * const spadeVenueGenre;
extern NSString * const spadeVenuePicture;
extern NSString * const spadeVenueCover;

//Event
extern NSString * const spadeClassEvent;
extern NSString * const spadeEventCreatedBy;
extern NSString * const spadeEventVenue;
extern NSString * const spadeEventImageFile;
extern NSString * const spadeEventWhen;
extern NSString * const spadeEventName;


//AlertView Titles Used for Comparison
extern NSString * const spadeAlertViewTitleConfirmFollower;
extern NSString * const spadeAlertViewTitleConfirmEvent;

//Follow Button Title
extern NSString * const spadeFollowButtonTitleFollow ;
extern NSString * const spadeFollowButtonTitleUnfollow;

//Spade Team Facebook Ids
extern NSString * const spadeDevonFacebookId;

//Event Placeholder Text
extern NSString  * const spadeEventPlaceHolderWhereLabel;
extern NSString  * const spadeEventPlaceHolderWhenLabel;



@end
