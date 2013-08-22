//
//  NSString+RegexString.h
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-8-1.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegexString)

//手机
+ (NSString *)regexTelPhone;
//HTTP连接
+ (NSString *)regexHttpLink;
//传真
+ (NSString *)regexFaxCode;
//邮件
+ (NSString *)regexMailCode;
//两位小数
+ (NSString *)regexTwoDecimal;
//表情【***】
+ (NSString *)regexEmotion;

@end
