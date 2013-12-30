//
//  VXRequest.m
//  v2exios
//
//  Created by myoula on 13-12-26.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXRequest.h"

@interface VXRequest ()<NSURLConnectionDelegate>

@end

@implementation VXRequest
{
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

-(void) createConnection:(NSString *)requesturl
{
    NSLog(@"%@", requesturl);
    NSURL *url=[NSURL URLWithString:requesturl];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30.0f];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"http://www.baidu.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
    
    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
    
    if (statusCode > 400)
    {
        [connection cancel];
        [self.delegate requestFinished:nil withErrot:@"网络连接失败！"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate requestFinished:nil withErrot:@"网络连接失败！"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.delegate requestFinished:receivedData withErrot:nil];
}

@end
