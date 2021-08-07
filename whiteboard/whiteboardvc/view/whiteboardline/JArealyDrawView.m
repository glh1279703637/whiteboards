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
    UIBezierPath *path = [self.m_whiteboareView funj_getBezierPath:self.m_lineModel];
    UIColor *color = UIColorFromRGB([self.m_lineModel.lineColor intValue]);
    if(self.m_lineModel.m_bezierPathType == kMark_Type){
        color = [color colorWithAlphaComponent:0.3];
    }
    path.lineWidth = self.m_lineModel.lineWidth*0.6;
    [color setStroke];
        
    if(self.m_lineModel.m_bezierPathType == kEraser_bezierPath){
        [path strokeWithBlendMode:kCGBlendModeClear alpha:1];
    }else{
        [path stroke];
    }
}

@end
