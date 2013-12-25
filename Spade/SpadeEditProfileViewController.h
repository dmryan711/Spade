//
//  SpadeEditProfileViewController.h
//  Spade
//
//  Created by Devon Ryan on 12/24/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface SpadeEditProfileViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,UITextFieldDelegate>
@property (strong, nonatomic) PFFile *profileFileForEdit;
@property (strong, nonatomic) NSString *userNameForEdit;

@end
