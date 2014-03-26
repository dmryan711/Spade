//
//  SpadeUtility.m
//  Spade
//
//  Created by Devon Ryan on 11/30/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation SpadeUtility : NSObject 

+(NSInteger)age:(NSDate *)dateOfBirth {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day])))
    {
        return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
        
    } else {
        
        return [dateComponentsNow year] - [dateComponentsBirth year];
    }
}

+ (void)processProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:spadeUserMediumProfilePic];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:spadeUserSmallProfilePic];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }

}




#define LEVEL_1 1
#define LEVEL_2 2
#define LEVEL_3 3
#define LEVEL_4 4
+(NSString *)processCurrencyLevel:(NSNumber *)level
{
    switch ([level integerValue]) {
        case LEVEL_1:
            return @"$";
            break;
            
        case LEVEL_2:
            return @"$$";
            break;
            
        case LEVEL_3:
            return @"$$$";
            break;
            
        case LEVEL_4:
            return @"$$$";
            break;
            
        default:
            return @"N/A";
            break;
    }

}

+(NSString *)processBottleService:(BOOL)bottleServiceSupport
{
    if (bottleServiceSupport) {
        return @"Yes";
    }else{
        return @"No";
    }

}


+(void)loadFile:(PFFile *)file forImageView:(PFImageView *)imageView
{
    [imageView setFile:file];
    [imageView loadInBackground:^(UIImage *image, NSError *error) {
        if (!error) {
            [UIView animateWithDuration:0.200f animations:^{
                // profilePictureBackgroundView.alpha = 1.0f;
                //profilePictureStrokeImageView.alpha = 1.0f;
                //profilePictureImageView.alpha = 1.0f;
            }];
        }
    }];


}

+(void)user:(PFUser *)user followingVenue:(PFObject *)venue
{
    PFObject *activity =[[PFObject alloc]initWithClassName:spadeClassActivity];
    
    
    
    [activity setObject:[PFUser currentUser] forKey:spadeActivityFromUser];
    [activity setObject:venue forKey:spadeActivityToVenue];
    [activity setObject:spadeActivityActionFollowingVenue forKey:spadeActivityAction];
    [activity saveEventually];
    
}


+(void)user:(PFUser *)user unfollowingVenue:(PFObject *)venue
{
    PFQuery *activityFollowingQuery = [PFQuery queryWithClassName:spadeClassActivity];
    [activityFollowingQuery whereKeyExists:spadeActivityToVenue];
    [activityFollowingQuery whereKey:spadeActivityFromUser equalTo:user];
    [activityFollowingQuery whereKey:spadeActivityToVenue equalTo:venue];
    [activityFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            for(PFObject *followingActivity in objects){
                [followingActivity deleteEventually];
            }
        }
    }];

}

+(void)processUserName:(NSString *)name forUser:(PFUser *)user
{
    [user setObject:name forKey:spadeUserDisplayName];
    [user saveEventually];

}


+(void)user:(PFUser *)user followingUser:(PFUser *)friendUser
{
 
    PFObject *activity =[[PFObject alloc]initWithClassName:spadeClassActivity];
    [activity setObject:[PFUser currentUser] forKey:spadeActivityFromUser];
    [activity setObject:friendUser forKey:spadeActivityToUser];
    [activity setObject:spadeActivityActionFollowingUser forKey:spadeActivityAction];
    [activity saveEventually];
    
}


+(void)user:(PFUser *)user followingUsers:(NSArray *)friendUsers
{
    for (PFUser *friend in friendUsers){
        
        [self user:[PFUser currentUser] followingUser:friend];
    }
}


+(void)user:(PFUser *)user unfollowingUser:(PFUser *)friendUser
{
    PFQuery *activityFollowingQuery = [PFQuery queryWithClassName:spadeClassActivity];
    [activityFollowingQuery whereKeyExists:spadeActivityToUser];
    [activityFollowingQuery whereKey:spadeActivityFromUser equalTo:user];
    [activityFollowingQuery whereKey:spadeActivityToUser equalTo:friendUser];
    [activityFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            for(PFObject *followingActivity in objects){
                [followingActivity deleteEventually];
            }
        }
    }];
}
+(void)user:(PFUser *)user unfollowingUsers:(NSArray *)friendUsers
{
    
    PFQuery *activityFollowingQuery = [PFQuery queryWithClassName:spadeClassActivity];
    [activityFollowingQuery whereKeyExists:spadeActivityToUser];
    [activityFollowingQuery whereKey:spadeActivityFromUser equalTo:user];
    [activityFollowingQuery whereKey:spadeActivityToUser containedIn:friendUsers];
    [activityFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            for(PFObject *followingActivity in objects){
                [followingActivity deleteEventually];
            }
        }
    }];

}

+(void)user:(PFUser *)user creatingEventWithName:(NSString *)eventName forVenue:(PFObject *)venue forDate:(NSString *)date forTime:(NSString *)time withImageFile:(PFFile *)file
{
    PFObject *event =[PFObject objectWithClassName:spadeClassEvent];
    [event setObject:eventName forKey:spadeEventName];
    [event setObject:venue forKey:spadeEventVenue];
    [event setObject:date forKey:spadeEventWhen];
    [event setObject:time forKey:spadeEventTime];
    if (file) {
        [event setObject:file forKey:spadeEventImageFile];
    }
    [self createEventActivity:event];
    
    [event saveEventually];
    

}

+(void)createEventActivity:(PFObject *)event
{
    PFObject *eventCreated = [PFObject objectWithClassName:spadeClassActivity];
    [eventCreated setObject:[PFUser currentUser] forKey:spadeActivityFromUser]; // Se event user
    [eventCreated setObject:event forKey:spadeActivityToEvent];
    [eventCreated setObject:spadeActivityActionCreatedEvent forKey:spadeActivityAction];
    [eventCreated setObject:[event objectForKey:spadeEventVenue] forKey:spadeActivityForVenue];
    
    [eventCreated saveEventually];

}

+(void)user:(PFUser *)user attendingEvent:(PFObject *)event
{
    PFObject *eventAttending = [PFObject objectWithClassName:spadeClassActivity];
    [eventAttending setObject:user forKey:spadeActivityFromUser];
    [eventAttending setObject:event forKey:spadeActivityToEvent];
    [eventAttending setObject:[event objectForKey:spadeEventVenue] forKey:spadeActivityForVenue];
    [eventAttending setObject:spadeActivityActionAttendingEvent forKey:spadeActivityAction];
    
    [eventAttending saveEventually];
    
}

+(void)user:(PFUser *)user unAttendingEvent:(PFObject *)event
{
    
    PFQuery *attendingEvent = [PFQuery queryWithClassName:spadeClassActivity];
    [attendingEvent whereKey:spadeActivityAction containsString:spadeActivityActionAttendingEvent];
    [attendingEvent whereKey:spadeActivityFromUser equalTo:user];
    [attendingEvent whereKey:spadeActivityToEvent equalTo:event];
    
    [attendingEvent getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object) {
            [object deleteEventually];
        }
    
    }];
}

/*+(NSArray *)crunchAttendeeActivities:(NSMutableArray *)arrayOfAttendingActivities
{
    for (PFObject *attendingActivity in arrayOfAttendingActivities) {
        if
    }

    
}*/

@end
