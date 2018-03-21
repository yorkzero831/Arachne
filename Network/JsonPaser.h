//
//  JsonPaser.h
//  Arachne
//
//  Created by Jia on 2017/12/17.
//  Copyright © 2017年 zero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonPaser : NSObject

+(NSString *)getSearchJson : (NSString *)keyword;
+(NSString *)dictToJsonStr:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
