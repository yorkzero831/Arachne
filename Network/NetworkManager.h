//
//  NetworkManager.h
//  Arachne
//
//  Created by Jia on 2017/12/17.
//  Copyright © 2017年 zero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (instancetype) getInstance;

- (void)sentMessage:(NSString *)subURL :(NSString *)message :(void (^)(NSString *data)) callback;

@end
