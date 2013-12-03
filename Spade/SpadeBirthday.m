//
//  SpadeBirthday.m
//  Spade
//
//  Created by Devon Ryan on 11/30/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeBirthday.h"

@implementation SpadeBirthday

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
    

@end
