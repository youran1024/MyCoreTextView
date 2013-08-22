//
//  NSString+RegexString.m
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-8-1.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "NSString+RegexString.h"

@implementation NSString (RegexString)

+ (NSString *)regexTelPhone
{
    return @"\\d{3}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}";
}

+ (NSString *)regexHttpLink
{
    return @"[a-zA-z]+://[^\\s]/*";
}

//-------------------------------------------------------
// 校验邮政编码
//-------------------------------------------------------
+ (NSString *)regexMailCode
{
    return @"/^[+]{0,1}(\\d){1,3}[ ]?([-]?((\\d)|[ ]){1,12})+$/";
}

//-------------------------------------------------------
//  检查座机电话号码和传真号，可以“+”开头，除数字外，可含有“-”
//-------------------------------------------------------
+(NSString *)regexFaxCode
{
    return @"/^[+]{0,1}(\\d){1,3}[ ]?([-]?((\\d)|[ ]){1,12})+$/";
}

//-------------------------------------------------------
//  验证有两位小数的正实数
//-------------------------------------------------------
+ (NSString *)regexTwoDecimal
{
    return @"^[0-9]+(.[0-9]{2})?$";
}

//-------------------------------------------------------
//  验证如下格式的字符串：[**], [**];
//-------------------------------------------------------
+ (NSString *)regexEmotion
{
    return @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
}

+ (NSString *)regexMD5
{
    return @"^[a-fA-F0-9]{32,32}$";
}

@end