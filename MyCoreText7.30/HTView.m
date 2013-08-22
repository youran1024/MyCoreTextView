//
//  HTView.m
//  MyCoreText7.30
//
//  Created by Mr.Yang on 13-7-30.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "HTView.h"
#import "MarkupParser.h"
#import "UIImageView+WebCache.h"

//热点触发消失区域
#define HOTSPACE    -20


/* Callbacks */
static void deallocCallback( void* ref ){
    [(id)ref release];
}
static CGFloat ascentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@implementation BaseNode

- (void)dealloc
{
    [_string release];
    [_rects release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.rects = [NSMutableArray array];
    }
    return self;
}

- (NSAttributedString *)attributedString
{
    return nil;
}

@end

@implementation ImageNode

- (void)dealloc
{
    
    [super dealloc];
}

+ (ImageNode *)imageNode
{
    return [[[[self class] alloc] init] autorelease];
}

- (NSAttributedString *)attributedString
{
    //render empty space for drawing the image in the text //1
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    
    NSDictionary* imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys: //2
                              _width, @"width",
                              _height, @"height",
                              nil] retain];
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr); //3
    NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                            //set the delegate
                                            (id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                            nil];
    
    return [[[NSAttributedString alloc] initWithString:_string attributes:attrDictionaryDelegate] autorelease];
}

@end

@implementation CoreNode

- (void)dealloc
{
    [_font release];
    [_fontName release];
    [_color release];
    [_strokeColor release];
    
    [super dealloc];
}

+ (CoreNode *)coreNode
{
    return [[[[self class] alloc] init] autorelease];
}

- (NSAttributedString *)attributedString
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.fontName,
                                             24.0f, NULL);
    if (_font) {
        //i don't confirmed if this convert is validate.????
        fontRef = (CTFontRef)_font;
    }
    
    //apply the current text style
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)self.color.CGColor, kCTForegroundColorAttributeName,
                           (id)fontRef, kCTFontAttributeName,
                           (id)self.strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat:self.strokeWidth], (NSString *)kCTStrokeWidthAttributeName,nil];
    CFRelease(fontRef);
    return [[[NSAttributedString alloc] initWithString:self.string attributes:attrs] autorelease];
}


@end

@interface HTView ()
@property (nonatomic, retain)   NSAttributedString *attriString;
@property (nonatomic, retain)   NSArray *nodes;
@end

@implementation HTView

- (void)dealloc
{
    [_string release];
    [_activyNode release];
    [super dealloc];
}

- (void)setString:(NSString *)string
{
    if (![_string isEqualToString:string]) {
        [_string release];
        _string = [string retain];
        MarkupParser *markUp = [[MarkupParser alloc] init];
        self.attriString = [markUp attrStringFromMarkup:_string];
        self.nodes = markUp.nodes;
        [markUp release];
        [self parseString:self.bounds];
    }
}

- (CGRect)getCTRunBoundsRect:(CTRunRef)run line:(CTLineRef)line orign:(CGPoint)orign
{
    CGRect      rect;
    CGFloat     ascent;
    CGFloat     descent;
    CGFloat     leading;
    CGFloat     width;
    CGFloat     height;
    CGFloat     offsetX;
    
    width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
    height = ascent + descent + leading;
    offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    rect = CGRectMake(offsetX + orign.x, orign.y - descent, width, height);
    return rect;
}

- (CGPoint)flipLocationInUICoordinate:(CGPoint)location
{
    return CGPointMake(location.x, CGRectGetMaxY(self.bounds) - location.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.activyNode = nil;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    location = [self flipLocationInUICoordinate:location];

    for (NSInteger i = 0; i < self.nodes.count; i++) {
        CoreNode *node = self.nodes[i];
        for (NSInteger j = 0; j < node.rects.count; j++) {
            CGRect rect = [node.rects[j] CGRectValue];
            if (CGRectContainsPoint(rect, location)) {
                self.activyNode = node;
                [self setNeedsDisplay];
                if (_delegate && [_delegate respondsToSelector:@selector(hTViewLinkClickedWhenTouchesBegin:)]) {
                    [_delegate hTViewLinkClickedWhenTouchesBegin:node];
                }
                return;
            }
        }

    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_activyNode) {
        UITouch *touche = [touches anyObject];
        CGPoint location = [touche locationInView:self];
        location = [self flipLocationInUICoordinate:location];
        if (![self isLocationInCoreNode:_activyNode andLocation:location]) {
            [self cancelActivyNodeDisplay];
        }    
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    location = [self flipLocationInUICoordinate:location];
    
    if ([self isLocationInCoreNode:_activyNode andLocation:location]) {
        if (_delegate && [_delegate respondsToSelector:@selector(hTViewLinkClickedWhenTouchesEnded:)]) {
            [_delegate hTViewLinkClickedWhenTouchesEnded:_activyNode];
        }
    }
    
    [self cancelActivyNodeDisplay];
}

- (BOOL)isLocationInCoreNode:(CoreNode *)node  andLocation:(CGPoint)location
{
    if (!node) return NO;
    
    for (NSValue *rectValue in _activyNode.rects) {
        CGRect rect = [rectValue CGRectValue];
        rect = CGRectInset(rect, HOTSPACE, HOTSPACE);
        if (CGRectContainsPoint(rect, location)) {
            return YES;
        }
    }
    return NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancelActivyNodeDisplay];
}

- (void)cancelActivyNodeDisplay
{
    self.activyNode = nil;
    [self setNeedsDisplay];
}

- (void)parseString:(CGRect)rect
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, rect);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attriString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), pathRef, NULL);
    CFArrayRef lineArray = CTFrameGetLines(frameRef);
    NSInteger lineCount = CFArrayGetCount(lineArray);
    
    if (![self.nodes count]) {
        return;
    }
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    CoreNode *node = [self.nodes objectAtIndex:0];
    
    for (NSInteger i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        
        CFArrayRef runArray = CTLineGetGlyphRuns(line);
        NSInteger runCount = CFArrayGetCount(runArray);
        for (NSInteger j = 0; j < runCount; j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runArray, j);
            CFRange range = CTRunGetStringRange(run);
            NSRange range_ = NSMakeRange(range.location, range.length);

            if (NSIntersectionRange(range_, node.range).length <= 0) {
                static NSInteger imageCounter = 1;
                if ([node.rects count] != 0) {
                    
                    if (imageCounter < [self.nodes count]) {
                        node = self.nodes[imageCounter++];
                    }
                    
                    if (NSIntersectionRange(range_, node.range).length <= 0) {
                        continue;
                    }
                    
                }else {
                    continue;
                }
            }
            
            CGPoint origin = origins[i];
            CGRect rect = [self getCTRunBoundsRect:run line:line orign:origin];
            [node.rects addObject:[NSValue valueWithCGRect:rect]];
        }
    
    }
}

- (CGRect)flipRectToUICoordinate:(CGRect)rect
{
    return CGRectMake(rect.origin.x, CGRectGetMaxY(self.bounds) - CGRectGetMaxY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(contextRef, 0, rect.size.height);
    CGContextScaleCTM(contextRef, 1, -1);
    [self.backgroundColor setFill];
    CGContextFillRect(contextRef, rect);
    [[UIColor greenColor] setFill];
    if (self.activyNode) {
        
        for (NSInteger i = 0; i < self.activyNode.rects.count; i++) {
            
            CGRect rect = [self.activyNode.rects[i] CGRectValue];
            rect = CGRectIntegral(rect);
            rect = CGRectInset(rect, -1, -1);
            CGContextFillRect(contextRef, rect);
            
        }
    }

    CGMutablePathRef mutablePathRef = CGPathCreateMutable();
    CGPathAddRect(mutablePathRef, NULL, rect);
    
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attriString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), mutablePathRef, NULL);
    
    CTFrameDraw(frameRef, contextRef);
    for (NSInteger i = 0; i < self.nodes.count; i++) {
        CoreNode *node = [self.nodes objectAtIndex:i];
        if ([node isKindOfClass:[ImageNode class]]) {
            ImageNode * imageNode = (ImageNode *)node;
            CGRect rect;
            if (imageNode.rects.count > 0) {
                rect = [imageNode.rects[0] CGRectValue];
                rect = [self flipRectToUICoordinate:rect];
            }
//            CGContextDrawImage(contextRef, rect, imageNode.image.CGImage);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            [self addSubview:imageView];
            [imageView release];
            NSURL *url = [NSURL URLWithString:imageNode.imageName];
            [imageView setImageWithURL:url placeholderImage:imageNode.image];
        }
    }
    
    CFRelease(frameRef);
    CFRelease(frameSetterRef);
    CFRelease(mutablePathRef);
}

@end
