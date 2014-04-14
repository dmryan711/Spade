//
//  SpadeProfileController.h
//  Spade
//
//  Created by Devon Ryan on 12/10/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "FUIAlertView.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SpadeProfileController : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate,FUIAlertViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (strong,nonatomic) NSString *userName;
@property (strong, nonatomic)   PFFile *profileImageFile;

@end
