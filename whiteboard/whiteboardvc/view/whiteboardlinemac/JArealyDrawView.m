//
//  JArealyDrawView.m
//  DevelopArchitecture
//
//  Created by 123 on 2017/5/11.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JArealyDrawView.h"
#import "JLineModel.h"
#import "JWhiteBoardView.h"
@implementation JArealyDrawView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
#if TARGET_OS_IPHONE
    CGContextRef context = UIGraphicsGetCurrentContext();
#else
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
#endif
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 10);
    if(self.m_lineModel.m_bezierPathType == kEraser_bezierPath){
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }else{
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
    NSColor* color = NSColorFromRGB([self.m_lineModel.lineColor intValue]);
    if(self.m_lineModel.m_bezierPathType == kMark_Type){
        color = [color colorWithAlphaComponent:0.3];
    }
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, self.m_lineModel.lineWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    [self.m_whiteboareView funj_getBezierPath:context :self.m_lineModel ];
    CGContextStrokePath(context);
}
@end
