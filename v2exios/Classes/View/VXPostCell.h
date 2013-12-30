//
//  VXPostCell.h
//  v2exios
//
//  Created by myoula on 13-12-27.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VXPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *posted;
@property (weak, nonatomic) IBOutlet UILabel *content;
@end
