//
//  SpadeEventCell.h
//  Spade
//
//  Created by Devon Ryan on 1/8/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpadeEventCell : UITableViewCell
@property BOOL showCell;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *value;


-(void)toggleShowCell;
@end
