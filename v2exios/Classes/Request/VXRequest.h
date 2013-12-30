//
//  VXRequest.h
//  v2exios
//
//  Created by myoula on 13-12-26.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VXRequestDelegate

@required
-(void) requestFinished:(NSData *)data withErrot:(NSString *)error;

@end

@interface VXRequest : NSObject

@property (nonatomic, retain) id<VXRequestDelegate> delegate;

-(void) createConnection:(NSString *)requesturl;

@end
