//
//  SpadeChatCell.h
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpadeChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextView *textString;

@end
