//
//  VXThreadDetailCell.h
//  v2exios
//
//  Created by myoula on 13-12-27.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLabel.h"

@interface VXThreadDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *notename;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *posthit;
@property (weak, nonatomic) IBOutlet RCLabel *content;

@end
