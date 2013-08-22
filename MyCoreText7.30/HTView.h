//
//  HTView.h
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-7-30.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class ImageNode;
@class CoreNode;
@protocol HTViewDelegate <NSObject>

- (void)hTViewLinkClickedWhenTouchesBegin:(CoreNode *)node;
- (void)hTViewLinkClickedWhenTouchesEnded:(CoreNode *)node;

@end

@interface BaseNode : NSObject
{
    @public
    NSString *_string;
    NSRange _range;
    NSMutableArray *_rects;
}
@property (nonatomic, retain)   NSString *string;
@property (nonatomic, assign)   NSRange range;
@property (nonatomic, retain)   NSMutableArray *rects;
- (NSAttributedString *)attributedString;
@end

@interface CoreNode : BaseNode

@property (nonatomic, retain)   UIFont *font;
@property (nonatomic, retain)   NSString *fontName;
@property (nonatomic, retain)   UIColor *color;
@property (nonatomic, retain)   UIColor *strokeColor;
@property (nonatomic, assign)   CGFloat strokeWidth;
@property (nonatomic, assign)   BOOL isHttpLink;
+ (CoreNode *)coreNode;

@end

@interface ImageNode : BaseNode

@property (nonatomic, retain)   NSNumber *width;
@property (nonatomic, retain)   NSNumber *height;
@property (nonatomic, retain)   UIImage  *image;
@property (nonatomic, retain)   NSString *imageName;

+ (ImageNode *)imageNode;

@end

@interface HTView : UIView

@property (nonatomic, assign)   id <HTViewDelegate> delegate;
@property (nonatomic, retain)   NSString *string;
@property (nonatomic, retain)   CoreNode *activyNode;
@end
