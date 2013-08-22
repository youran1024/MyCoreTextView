//
//  NSString+RegexString.h
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-8-1.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//


#import "MarkupParser.h"
#import "HTView.h"
#import "RegexKitLite.h"
#import "NSString+RegexString.h"


#define kHTML @"These are <font color=\"red\">red<font color=\"black\"> and\
<font color=\"blue\">blue <font color=\"black\">words."

@implementation MarkupParser

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.font = @"Arial";
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
        self.nodes = [NSMutableArray array];
    }
    
    return self;
}


-(NSMutableAttributedString*)attrStringFromMarkup:(NSString*)markup
{
   markup = [self markUpPlainText:markup];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    NSRegularExpression* regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil]; //2
    NSArray* chunks = [regex matchesInString:markup options:0
                                       range:NSMakeRange(0, [markup length])];
    [regex release];
    
    for (NSTextCheckingResult* b in chunks)
    {
        NSArray* parts = [[markup substringWithRange:b.range]
                          componentsSeparatedByString:@"<"]; //1
        
        CoreNode *node = [CoreNode coreNode];
        node.string = [parts objectAtIndex:0];
        node.range = NSMakeRange(string.string.length, ((NSString *)[parts objectAtIndex:0]).length);
        node.fontName = self.font;
        node.color = self.color;
        node.strokeWidth = self.strokeWidth;
        node.strokeColor = self.strokeColor;
        [string appendAttributedString:[node attributedString]];
        
        if (![node.string isEqualToString:@""] && node.string && ![node.string
             isEqualToString:@"\n"]) {
            [self.nodes addObject:node];
        }
        
        if ([parts count]>1) 
        {
            NSString* tag = (NSString*)[parts objectAtIndex:1];
            if ([tag hasPrefix:@"font"]) {
                //stroke color
                NSRegularExpression* scolorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=[\'\"])\\w+" options:0 error:NULL] autorelease];
                [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    if ([[tag substringWithRange:match.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    } else {
                        self.strokeWidth = -2.0;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                }];
                
                //color
                NSRegularExpression* colorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=color=[\'\"])\\w+" options:0 error:NULL] autorelease];
                [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
                    self.color = [UIColor performSelector:colorSel];
                }];
                
                //face
                NSRegularExpression* faceRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=face=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    self.font = [tag substringWithRange:match.range];
                }];
            }
            //end of font parsing
            
            if ([tag hasPrefix:@"img"]) {
                
                __block NSNumber *width = [NSNumber numberWithInt:0];
                __block NSNumber *height = [NSNumber numberWithInt:0];
                __block NSString *fileName = @"";
                __block NSString *type = @"";
                __block NSString *placeHold = @"";
                
                //width
                NSRegularExpression* widthRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=width=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){ 
                    width = [NSNumber numberWithInt: [[tag substringWithRange: match.range] intValue] ];
                }];
                
                //height
                NSRegularExpression* faceRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=height=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    height = [NSNumber numberWithInt: [[tag substringWithRange:match.range] intValue]];
                }];
                
                //image
                NSRegularExpression* srcRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=src=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    fileName = [tag substringWithRange: match.range];
                }];
                
                //type
                NSRegularExpression* placeHoldRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=placeHold=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [placeHoldRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    placeHold = [tag substringWithRange: match.range];
                }];
                
                //type
                NSRegularExpression* typeRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=type=[\'\"])[^[\'\"]]+" options:0 error:NULL] autorelease];
                [typeRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                    type = [tag substringWithRange: match.range];
                }];
                        
                //add a space to the text so that it can call the delegate
                ImageNode *node = [ImageNode imageNode];
                
                node.range = NSMakeRange(string.string.length, 1);
                node.string = @" ";
                node.height = height;
                node.width = width;
                [self.nodes addObject:node];
                if ([fileName hasPrefix:@"http://"]) {
                    node.imageName = fileName;
                    node.image = [UIImage imageNamed:placeHold];
                }else {
                    node.image = [UIImage imageNamed:fileName];
                }
                [string appendAttributedString:[node attributedString]];
            }
        }
    }
    return (NSMutableAttributedString*)string;
}

//查找表情， 电话号码， HTTP连接地址
- (NSString *)markUpPlainText:(NSString *)plainText
{
//    plainText = [self transformHttpArrayToFormatPlaintText:plainText];
    plainText = [self transformTelphoneArrayToFormatPlainText:plainText];
    plainText = [self transformEmotionArrayToFormatPlainText:plainText];
    return plainText;
}

- (NSString *)transformHttpArrayToFormatPlaintText:(NSString *)plainText;
{
    NSArray *httpArray = [self getHttpArrayFromPlainText:plainText];
    NSRange range = NSMakeRange(0, plainText.length);
    for (NSString *httpStr in httpArray) {
        range = [plainText rangeOfString:httpStr options:NSCaseInsensitiveSearch range:range];
        if (range.location > 0) {
            NSString *replaceString = [NSString stringWithFormat:@"<font >%@", httpStr];
            plainText = [plainText stringByReplacingCharactersInRange:range withString:replaceString];
            range = NSMakeRange(range.location + range.length, plainText.length);
        }
    }
    return plainText;
}

- (NSString *)transformTelphoneArrayToFormatPlainText:(NSString *)plainText
{
    NSArray *phoneArray = [self getPhoneNumArrayFromPlainText:plainText];
    NSRange range = NSMakeRange(0, plainText.length);
    for (NSString *phoneStr in phoneArray) {
        range = [plainText rangeOfString:phoneStr options:NSCaseInsensitiveSearch range:range];
        if (range.location > 0) {
            NSString *replaceString = [NSString stringWithFormat:@"<font >%@", phoneStr];
            plainText = [plainText stringByReplacingCharactersInRange:range withString:replaceString];
            range = NSMakeRange(range.location + range.length, plainText.length - range.location - range.length);
        }
    }
    return plainText;
}

- (NSString *)transformEmotionArrayToFormatPlainText:(NSString *)plainText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emotionImage" ofType:@"plist"];
    if (!path) {
        return plainText;
    }
    NSDictionary *emotionDic = [NSDictionary dictionaryWithContentsOfFile:path];
    //从文本中获取所有的表情字符
    NSArray *emotionArray = [self getEmotionArrayFromPlainText:plainText];
    
    for (NSString *emotionStr in emotionArray) {
        NSRange range = [plainText rangeOfString:emotionStr];
        NSString *emotionName = [emotionDic objectForKey:emotionStr];
        NSString *replaceString = [NSString stringWithFormat:@"<img src=\"%@\" height=\"26\" width=\"26\">", emotionName];
        plainText = [plainText stringByReplacingCharactersInRange:range withString:replaceString];
    }
    
    return plainText;
}

//解析网络地址
- (NSArray *)getHttpArrayFromPlainText:(NSString *)text
{
    NSString *regex_http = [NSString regexHttpLink];
    return [text componentsMatchedByRegex:regex_http];
}

//解析phoneNum
- (NSArray *)getPhoneNumArrayFromPlainText:(NSString *)text
{
    NSString *regex_phonenum = [NSString regexTelPhone];
    return [text componentsMatchedByRegex:regex_phonenum];
}

//解析表情
- (NSArray*)getEmotionArrayFromPlainText:(NSString *)plainText
{
    NSString *regex_emoji = [NSString regexEmotion];
    return [plainText componentsMatchedByRegex:regex_emoji];
}

-(void)dealloc
{ 
    [_font release];
    [_color release];
    [_strokeColor release];
    [_images release];
    [_nodes release];
    [super dealloc];
}

@end
