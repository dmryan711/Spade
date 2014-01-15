//
//  SpadeNameCell.h
//  Spade
//
//  Created by Devon Ryan on 1/11/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventCell.h"

@interface SpadeNameCell : SpadeEventCell

@property (weak,nonatomic) IBOutlet UITextField *nameEntry;
@property (weak,nonatomic) IBOutlet UILabel *nameLabel;

@end
