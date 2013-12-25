//
//  SpadeProfileController.h
//  Spade
//
//  Created by Devon Ryan on 12/10/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpadeProfileController : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate >

@property (strong,nonatomic) NSString *userName;
@property (strong, nonatomic)   PFFile *profileImageFile;

@end
