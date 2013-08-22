//
//
//  NSString+RegexString.h
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-8-1.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "HTView.h"

@interface MarkupParser : NSObject

@property (retain, nonatomic) NSString* font;
@property (retain, nonatomic) UIColor* color;
@property (retain, nonatomic) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;

@property (retain, nonatomic) NSMutableArray* images;
@property (retain, nonatomic) NSMutableArray *nodes;

-(NSMutableAttributedString*)attrStringFromMarkup:(NSString*)html;

@end
