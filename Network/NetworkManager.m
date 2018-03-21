//
//  NetworkManager.m
//  Arachne
//
//  Created by Jia on 2017/12/17.
//  Copyright © 2017年 zero. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager* _instance = nil;

+ (instancetype) getInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (void)sentMessage:(NSString *)subURL :(NSString *)message :(void (^)(NSString *data)) callback{
    
    NSString* fixMessage = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlS = [NSString stringWithFormat:@"http://172.20.10.9:8080/%@?value=%@", subURL, fixMessage];
    NSURL *url = [NSURL URLWithString:urlS];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSString *receiveStr = nil;
        if(httpResponse.statusCode == 200) {
            receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(receiveStr);
            
        }
        callback(receiveStr);
    }];
    
    [sessionDataTask resume];
}

@end
