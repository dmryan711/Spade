//
//  SpadeConstants.m
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeConstants.h"

@implementation SpadeConstants


NSString * const spadePicFLag = @"picChangedFlag";
NSString * const spadeNameFlag = @"nameChangedFlag";
NSString * const spadeFirstLoginFlag = @"firstLgoinFlag";

//User Class
NSString * const spadeClassUser = @"_User";

NSString * const spadeUserFriends = @"Friends";
NSString * const spadeUserEmail = @"email";
NSString * const spadeUserGender = @"gender";
NSString * const spadeUserLocale = @"locale";
NSString * const spadeUserBirthday = @"birthday";
NSString * const spadeUserAge = @"age";
NSString * const spadeUserFacebookId = @"FacebookID";
NSString * const spadeUserDisplayName = @"DisplayName";
NSString * const spadeUserMediumProfilePic = @"MediumProfilePic";
NSString * const spadeUserSmallProfilePic = @"SmallProfilePic";


//Activity Class
NSString * const spadeClassActivity = @"Activity";

NSString * const spadeActivityFromUser = @"fromUser";
NSString * const spadeActivityToUser= @"toUser";
NSString * const spadeActivityToVenue = @"toVenue";
NSString * const spadeActivityToEvent = @"toEvent";
NSString * const spadeActivityAction = @"action";


NSString * const spadeActivityActionFollowingVenue = @"Following Venue";
NSString * const spadeActivityActionFollowingUser = @"Following User";
NSString * const spadeActivityActionAttendingEvent = @"Attending Event";
NSString * const spadeActivityActionCreatedEvent  = @"Created Event";

//Venue Class
NSString * const spadeClassVenue = @"Venue";

NSString * const spadeVenueName = @"Name";
NSString * const spadeVenueCategory = @"Category";
NSString * const spadeVenueSpendLevel = @"SpendLevel";
NSString * const spadeVenueAddress = @"Address";
NSString * const spadeVenueTableService = @"TableService";
NSString * const spadeVenueGenre = @"MusicGenre";
NSString * const spadeVenuePicture = @"Picture";
NSString * const spadeVenueCover  = @"Cover";

//Event Class
NSString * const spadeClassEvent  = @"Event";
NSString * const spadeEventName = @"Name";
NSString * const spadeEventVenue =  @"Venue";
NSString * const spadeEventImageFile = @"ImageFile";
NSString * const spadeEventWhen = @"EventWhen";

//Alert View Titles for Comparison
NSString * const spadeAlertViewTitleConfirmFollower = @"Just Asking!";
NSString * const spadeAlertViewTitleConfirmEvent = @"Create Event";

//Follow Button Title
NSString * const spadeFollowButtonTitleFollow = @"Follow";
NSString * const spadeFollowButtonTitleUnfollow = @"Unfollow";


//Spade Team Facebook Ids
NSString * const spadeDevonFacebookId = @"15723417";

//Event Placeholder Text
NSString  * const spadeEventPlaceHolderWhereLabel = @"Press Here";
NSString  * const spadeEventPlaceHolderWhenLabel = @"And Here";



@end
