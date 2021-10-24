//
//  JWhiteBoardView.m
//  MZCloudClass
//
//  Created by 123 on 2016/12/14.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardView.h"
#import <Quartz/Quartz.h>
#import "JTimerHolder.h"
#import "JMeetingRolesManager.h"
#import "JArealyDrawView.h"
#import "JMeetingRolesManager.h"
#import "JWhiteboardVC.h"

@interface JWhiteBoardView(){
    BOOL _needMustReload;
}
@property(nonatomic,assign)BOOL m_shouldDraw2;

@property(nonatomic,strong)JArealyDrawView *m_alreayDrawView;

@end
@implementation JWhiteBoardView
@synthesize m_lineColor,m_lineWidth;

#pragma mark - public methods
- (id)initWithFrame:(CGRect)frame :(NSInteger)fromVc{
    if (self = [super initWithFrame:frame]) {
        self.wantsLayer = YES;
        CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
        shapeLayer.fillColor = [NSColor clearColor].CGColor;

        self.layer.opaque = NO;
        _m_myLinesArr=[[NSMutableArray alloc]init];
        _m_fromVC = fromVc;
        _m_currentPage = @"1";
        _m_myAllLinesDic=[[NSMutableDictionary alloc]init];
        JMeetingRole *myRole =[[JMeetingRolesManager share]myRole];
        m_lineColor =  self.m_colorArray[myRole.m_drawDefaultColorType];
        m_lineWidth = 3;
        _m_eraserWidth = 30;
        self.m_bezierPathType= kPen_bezierPath;

        [[JTimerHolder share]funj_addToShareThreadPools:@{@"targert":self,@"selector":@"funj_onDisplayLinkFire",@"types":[NSString stringWithFormat:@"%zd",self.m_fromVC],@"repeattimer":@(1)}];

        _m_alreayDrawView=[[JArealyDrawView alloc]initWithFrame:self.bounds];
        _m_alreayDrawView.m_whiteboareView = self;
        [self addSubview:_m_alreayDrawView];
        self.m_alreayDrawView.wantsLayer = YES;
    }
    return self;
}
-(NSArray*)m_colorArray{
    return @[@(0xed5565),@(0xff7e00),@(0xffce54),@(0x48cfad),@(0x5d9cec),@(0x000000)];
}
- (CALayer *)layer{
    return  [CAShapeLayer layer];
}
-(void)funj_reloadAlreadyDrawViewColor{
    _m_alreayDrawView.layer.backgroundColor = RGB(150, 150, 150, 0.001).CGColor;
}
//设置颜色
- (void)setLineColor:(NSNumber*)color :(CGFloat)width :(BOOL) isEraser{
    if(color ){m_lineColor =color;_m_lineColor2 = nil;}
    if(width>0 && !isEraser) m_lineWidth = width;
    if(width >0 && isEraser) _m_eraserWidth = width;
}
//设置颜色
- (void)setLineColor2:(NSColor*)color2{
    m_lineColor =nil;_m_lineColor2 = color2;
}
//设置绘制类型
- (void)setBezierPathType:(BezierPathType )type{
    self.m_bezierPathType = type;
}
//增加线
- (void)addPoints:(CGPoint)points isNewLine:(NSInteger)newLine ower:(NSString*)ower{
    [self addNetPoints:points isNewLine:newLine ower:ower :_m_bezierPathType :m_lineColor :_m_bezierPathType == kEraser_bezierPath?_m_eraserWidth:m_lineWidth :self.m_currentPage];
}
- (void)addNetPoints:(CGPoint)point isNewLine:(NSInteger)newLine ower:(NSString*)ower :(BezierPathType )shapetype :(NSNumber*)lineColor :(CGFloat)width  :(NSString*)page{
    JLineModel *lineModel = nil;
    if(newLine==1){
        lineModel=[[JLineModel alloc]init];
        lineModel.lineColor=lineColor;
        lineModel.lineWidth= width;
        lineModel.lineColor2 = self.m_lineColor2;
        lineModel.m_bezierPathType=shapetype;
        lineModel.ower = ower;
        if([self.m_currentPage isEqualToString:page]){
            [self.m_myLinesArr addObject:lineModel];
        }else{
            NSMutableArray* lineArr = [self.m_myAllLinesDic objectForKey:page];
            if(!lineArr){
                lineArr =[[NSMutableArray alloc]init];
                [self.m_myAllLinesDic setObject:lineArr forKey:page];
            }
            [lineArr addObject:lineModel];
        }
    }else{
        NSMutableArray* lineArr = nil;
        if([self.m_currentPage isEqualToString:page]){
            lineArr = self.m_myLinesArr;
        }else{
            lineArr = [self.m_myAllLinesDic objectForKey:page];
            if(!lineArr){
                lineArr =[[NSMutableArray alloc]init];
                [self.m_myAllLinesDic setObject:lineArr forKey:page];
            }
        }
        
        for(NSInteger i=lineArr.count-1;i>=0;i--){
            JLineModel *line = lineArr[i];
            if([line.ower isEqualToString:ower]){
                lineModel = lineArr[i];
                if(i<lineArr.count-1){
                    _m_shouldDraw2 = YES;
                }
                break;
            }
        }
    }
    self.m_drawLineTimers = 3;
    if(newLine == 3){
        _needMustReload = YES;
        lineModel.m_addLineTime =[NSDate timeIntervalSinceReferenceDate];
    }
    [lineModel.lineArray addObject:[NSValue valueWithPoint:point]];
    _m_shouldDraw = [self.m_currentPage isEqualToString:page]; //确定是否进入所有刷新
    
}
-(void)funj_addLineToView:(JLineModel*)lineModel :(NSString*)page{
    NSMutableArray *lineArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        lineArr = _m_myLinesArr;
    }else{
        lineArr = [self.m_myAllLinesDic objectForKey:page];
        if(!lineArr){
            lineArr =[[NSMutableArray alloc]init];
        }
        [self.m_myAllLinesDic setObject:lineArr forKey:page];
    }
    @synchronized(self){
        [lineArr addObject:lineModel];
    }
    _needMustReload = YES;
}
//取消 某用户的线最后一条
-(void)funj_cancelLastLine:(NSString*)page :(NSString *)uid :(NSString*)lineKey{
    NSMutableArray *lineArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        lineArr = _m_myLinesArr;
    }else{
        lineArr = [self.m_myAllLinesDic objectForKey:page];
    }
    JLineModel *lineModel = nil;
    for(NSInteger i=lineArr.count-1;i>=0;i--){
        JLineModel *line = lineArr[i];
        if(lineKey && [line.key isEqualToString:lineKey]){
            lineModel = lineArr[i];
            break;
        }
        if(!lineKey && ((line.ower && [line.ower isEqualToString:uid]) || [JWhiteboardConfig share].m_isManager)){
            lineModel = lineArr[i];
            break;
        }

    }
    if(lineModel){
        @synchronized(self){
            [lineArr removeObject:lineModel];
        }
        _m_shouldDraw  =!page || (page && [page isEqualToString:self.m_currentPage]) ;
        _m_shouldDraw2 = _m_shouldDraw ? _m_shouldDraw :_m_shouldDraw2;
    }
}
-(JLineModel*)funj_getCurrentPageLastUserLine:(NSString*)uid{
    NSMutableArray *lineArr = self.m_myLinesArr;
     JLineModel *lineModel = nil;
    for(NSInteger i=lineArr.count-1;i>=0;i--){
        JLineModel *line = lineArr[i];
         if(!uid || (line.ower && [line.ower isEqualToString:uid]) || [JWhiteboardConfig share].m_isManager){
            lineModel = lineArr[i];
            break;
        }
    }
    return lineModel;
}
 
//初始化存储笔记
-(void)funj_reloadToChangeAllPageIndex:(NSDictionary*)changeDic{
    NSMutableArray *lineArr =[self.m_myAllLinesDic objectForKey:self.m_currentPage];
    if(!lineArr){
        lineArr =[[NSMutableArray alloc]init];
        [self.m_myAllLinesDic setObject:lineArr forKey:self.m_currentPage];
    }else{
        [lineArr removeAllObjects];
        [lineArr addObjectsFromArray:self.m_myLinesArr];
    }
 
    NSMutableDictionary *saveAllLineDic =[[NSMutableDictionary alloc]init];
    for(NSString *newPage in changeDic.allKeys){
        NSString *oldPage = changeDic[newPage];
        NSMutableArray *lineArr = [self.m_myAllLinesDic objectForKey:oldPage];
        if(!lineArr ){
            lineArr=[[NSMutableArray alloc]init];
        }
        [saveAllLineDic setObject:lineArr forKey:newPage];
    }
    [self.m_myAllLinesDic removeAllObjects];
    [self.m_myAllLinesDic addEntriesFromDictionary:saveAllLineDic];
    [self.m_myLinesArr removeAllObjects];
    [self.m_myLinesArr addObjectsFromArray:[self.m_myAllLinesDic objectForKey:self.m_currentPage]];
    _m_shouldDraw = _m_shouldDraw2 = YES;
}

//删除所有
- (NSArray*)funj_deleteSomePageAllLines:(NSString*)page  :(NSString*)userId c:(BOOL)isReload{
    NSMutableArray *deleteLineIndexArr =[[NSMutableArray alloc]init];
    NSMutableArray *lineArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        lineArr = _m_myLinesArr;
    }else{
        lineArr = [self.m_myAllLinesDic objectForKey:page];
    }
    if(lineArr.count<=0)return deleteLineIndexArr;
    @synchronized(self){
         if(!userId || (userId && [userId isEqualToString:[JWhiteboardConfig share].m_speakerUserId])){
            [lineArr removeAllObjects];
        }else{
            NSMutableArray *array =[[NSMutableArray alloc]initWithArray:lineArr];
            [lineArr removeAllObjects];
            for(int i=0;i<array.count;i++){
                JLineModel *lineModel = array[i];
                if(![lineModel.ower isEqualToString:userId]){
                    [lineArr addObject:lineModel];
                }else{
                    if(lineModel.key && lineModel.key.length>0)[deleteLineIndexArr addObject: lineModel.key];
                }
            }
        }
    }
    _m_shouldDraw = _m_shouldDraw2 = isReload;
    return deleteLineIndexArr;
}
-(void)funj_deleteAllLinesFrom:(NSString*)page{
    if(!page || [page isEqualToString:self.m_currentPage]){
        [self.m_myLinesArr removeAllObjects];
        _m_shouldDraw = _m_shouldDraw2 = YES;
    }
    NSMutableArray *pageArr =[[NSMutableArray alloc]init];
    for(NSString *index in self.m_myAllLinesDic.allKeys){
        if(index.intValue >= page.intValue){
            [pageArr addObject:index];
        }
    }
    [self.m_myAllLinesDic removeObjectsForKeys:pageArr];
}
-(void)funj_deleteLinesFromIds:(NSString*)page :(NSString*)idkeys{
     NSMutableArray *lineArr = nil;
    if(!page || [page isEqualToString:self.m_currentPage]){
        lineArr = _m_myLinesArr;
    }else{
        lineArr = [self.m_myAllLinesDic objectForKey:page];
    }
    if(lineArr.count<=0)return ;
    @synchronized(self){
        NSMutableArray *array =[[NSMutableArray alloc]initWithArray:lineArr];
        [lineArr removeAllObjects];
        for(int i=0;i<array.count;i++){
            JLineModel *lineModel = array[i];
            if(lineModel.key &&  [idkeys rangeOfString:lineModel.key].length <= 0){
                [lineArr addObject:lineModel];
            }
        }
    }
    _m_shouldDraw = _m_shouldDraw2 = YES;
}
//change ppt page to change line show
//-(void)funj_changeQuestionPageToReloadCurrentLine:(NSString*)page{
//     _m_shouldDraw = _m_shouldDraw2 = YES;
////     [JAppUtility funj_transitionWithType:kCATransitionPush WithSubtype: ([self.m_currentPage intValue] > [page intValue] ?kCATransitionFromLeft:kCATransitionFromRight) ForView:self t:0.3];
//     self.m_currentPage = page;
//}
//更新页面
//-(void)funj_changePageToReloadCurrentLine:(NSString*)page{
//    
//    if(!page || [page isEqualToString: self.m_currentPage] ||!self.m_currentPage)return;
//    @synchronized(self){
//        
//        //保存当前的数据
//        NSMutableArray *currentLineArr = nil;
//        if([self.m_myAllLinesDic objectForKey:self.m_currentPage]){
//            currentLineArr =[self.m_myAllLinesDic objectForKey:self.m_currentPage];
//            [currentLineArr removeAllObjects];
//        }else{
//            currentLineArr =[[NSMutableArray alloc]init];
//        }
//        [currentLineArr addObjectsFromArray:self.m_myLinesArr];
//        [self.m_myAllLinesDic setObject:currentLineArr forKey:self.m_currentPage];
//        
//        
//        //获取新页数的数据
//        [self.m_myLinesArr removeAllObjects];
//        if([self.m_myAllLinesDic objectForKey:page]){
//            [self.m_myLinesArr addObjectsFromArray:[self.m_myAllLinesDic objectForKey:page]];
//        }else{
//            NSMutableArray *lineArr =[[NSMutableArray alloc]init];
//            [self.m_myAllLinesDic setObject:lineArr forKey:page];
//        }
//    }
//    _m_shouldDraw = _m_shouldDraw2 = YES;
//    
////    [JAppUtility funj_transitionWithType:kCATransitionPush WithSubtype: ([self.m_currentPage intValue] > [page intValue] ?kCATransitionFromLeft:kCATransitionFromRight) ForView:self t:0.3];
//    
//    self.m_currentPage = page;
//    
//}
-(BOOL)funj_needDeleteOwerLineFromTime{
    JLineModel *lineModel = [self.m_myLinesArr lastObject];
    NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
     if(nowTime - lineModel.m_addLineTime  >  4 && lineModel.m_addLineTime>1){ // 这个值比较大于规定的3s ,否则最后几笔无法消失
        return NO;
    }
    return YES;
}

#pragma mark - private methods
-(void)funj_onDisplayLinkFire{
    BOOL isNeedReloadSelf = NO;
    if(!_needMustReload){
        if(!_m_shouldDraw){
            if(self.m_drawLineTimers>0) {
                self.m_drawLineTimers --;
                if(self.m_drawLineTimers >0)return;
                isNeedReloadSelf = YES;
             }else{
                if(!([JWhiteboardConfig share].m_isManager || [JWhiteboardConfig share].m_isAssistant || [JWhiteboardConfig share].m_isWebPlaying) &&  [JWhiteboardConfig share].m_interaction == 4 && self.m_fromVC == 3){
                    BOOL isneed = [self funj_needDeleteOwerLineFromTime];
                    isNeedReloadSelf = isneed;
                    if(!isneed)return;
                }else{
                    return;
                }
            }
        }
    }
     self.m_alreayDrawView.m_lineModel = self.m_myLinesArr.lastObject;
    if(!([JWhiteboardConfig share].m_isManager || [JWhiteboardConfig share].m_isAssistant || [JWhiteboardConfig share].m_isWebPlaying) &&  [JWhiteboardConfig share].m_interaction == 4 && self.m_fromVC == 3){
        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
        if(nowTime - self.m_alreayDrawView.m_lineModel.m_addLineTime  >=  2.8  && self.m_alreayDrawView.m_lineModel.m_addLineTime > 1){ // 这个值规定的3s
             self.m_alreayDrawView.m_lineModel = nil;
        }
    }
    [self.m_alreayDrawView setNeedsDisplay:YES];

    if([self.m_currentPage isEqualToString:self.m_alreayDrawView.m_currentPage]){
        JLineModel *lineModel = [self.m_myLinesArr lastObject];
        if(lineModel.m_bezierPathType ==  kEraser_bezierPath/*清除*/ || isNeedReloadSelf/*时间间隔*/ || _needMustReload/*绘制结束*/){
            _m_shouldDraw2 = YES;
        }
        
        if(_m_shouldDraw2){
            [self setNeedsDisplay:YES];
        }
    }else{
        [self setNeedsDisplay:YES];
    }
    self.m_alreayDrawView.m_countDrawLines = self.m_myLinesArr.count-1;
    self.m_alreayDrawView.m_currentPage = self.m_currentPage;
    
    _m_shouldDraw = NO;
    _m_shouldDraw2 = NO;
    _needMustReload = NO;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    @synchronized(self){
        NSInteger maxCount = self.m_myLinesArr.count;
        if(maxCount){
            JLineModel *lineModel =[self.m_myLinesArr lastObject];
            if(lineModel.m_bezierPathType == kEraser_bezierPath){
                maxCount = self.m_myLinesArr.count;
            }
        }
        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
        for (NSUInteger i = 0 ; i < maxCount; i ++) {
            JLineModel *line = [self.m_myLinesArr objectAtIndex:i];
            if(!([JWhiteboardConfig share].m_isManager || [JWhiteboardConfig share].m_isAssistant || [JWhiteboardConfig share].m_isWebPlaying) &&  [JWhiteboardConfig share].m_interaction == 4 && self.m_fromVC == 3){
                if(nowTime - line.m_addLineTime >= 2.8 && line.m_addLineTime > 1)continue;
            }
#if TARGET_OS_IPHONE
              CGContextRef context = UIGraphicsGetCurrentContext();
#else
            CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
#endif
            CGContextSaveGState(context);
            CGContextSetLineWidth(context, 10);
            if(line.m_bezierPathType == kEraser_bezierPath){
                CGContextSetBlendMode(context, kCGBlendModeClear);
            }else{
                CGContextSetBlendMode(context, kCGBlendModeNormal);
            }
            NSColor* color = NSColorFromRGB([line.lineColor intValue]);
            if(line.m_bezierPathType == kMark_Type){
                color = [color colorWithAlphaComponent:0.3];
            }
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineWidth(context, line.lineWidth);
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            [self funj_getBezierPath:context :line];
            CGContextStrokePath(context);
        }
    }
    _m_shouldDraw = _m_shouldDraw2 = NO;
}
-(void)funj_getBezierPath:(CGContextRef)context :(JLineModel *)line {
    switch (line.m_bezierPathType) {
        case kPen_bezierPath: case kMark_Type:{
            [self funj_drawWithPenSubView:context :line ];
        }break;
        case kVectorLine_bezierPath:{
            [self funj_drawToVectorLine:context :line];
        }break;
        case kArc_bezierPath:{
            [self funj_drawToRectOrArc:context :line :YES];
        }break;
        case kRect_bezierPath:{
            [self funj_drawToRectOrArc:context :line :NO];
        }break;
        case kIsoscelesTriangle_bezierPath:{
            [self funj_drawToTriangle:context :line :YES];
        }break;
        case kRightTriangle_bezierPath:{
            [self funj_drawToTriangle:context :line :NO];
        }break;
        case kEraser_bezierPath:{
            [self funj_drawWithPenSubView:context :line];
        }break;
        default:
            break;
    }
}

//通过画笔方式 绘制线条
-(void)funj_drawWithPenSubView:(CGContextRef)context :(JLineModel*)line  {
    for (NSUInteger j = 0 ; j < line.lineArray.count; j ++) {
        CGPoint  p   = [line.lineArray[j] pointValue];
        p = CGPointMake(p.x*kWhiteBoardDrawWidth(self.m_fromVC), p.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
        
        if (j == 0) {
            CGContextMoveToPoint(context, p.x, p.y);
        } else {
            CGPoint prePoint = [line.lineArray[j-1] pointValue];
            prePoint = CGPointMake(prePoint.x*kWhiteBoardDrawWidth(self.m_fromVC), prePoint.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
            CGPoint midP = [self funj_calculateMidPointForPoint:p andPoint:prePoint];
            CGContextAddCurveToPoint(context, midP.x, midP.y,  prePoint.x, prePoint.y, p.x, p.y);
        }
    }
}
- (CGPoint)funj_calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);
}
//绘制矢量直线
-(void)funj_drawToVectorLine:(CGContextRef)context :(JLineModel*)line {
    CGPoint startP = [[line.lineArray firstObject] pointValue];
    CGPoint endP = [[line.lineArray lastObject] pointValue];
    startP = CGPointMake(startP.x*kWhiteBoardDrawWidth(self.m_fromVC), startP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    endP = CGPointMake(endP.x*kWhiteBoardDrawWidth(self.m_fromVC), endP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    CGContextMoveToPoint(context, startP.x, startP.y);
    CGContextAddLineToPoint(context, endP.x, endP.y);
}
//绘制圆形 方形
-(void)funj_drawToRectOrArc:(CGContextRef)context :(JLineModel*)line :(BOOL)isArc{
    CGPoint startP = [[line.lineArray firstObject] pointValue];
    CGPoint endP = [[line.lineArray lastObject] pointValue];
    startP = CGPointMake(startP.x*kWhiteBoardDrawWidth(self.m_fromVC), startP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    endP = CGPointMake(endP.x*kWhiteBoardDrawWidth(self.m_fromVC), endP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    CGFloat width = endP.x - startP.x;
    CGFloat height = endP.y-startP.y ;
    
    if(isArc){
        CGContextAddEllipseInRect(context, CGRectMake(startP.x, startP.y, width, height));
    }else{
        CGContextAddEllipseInRect(context, CGRectMake(startP.x, startP.y,width, height));
    }
}
//绘制三角形
-(void)funj_drawToTriangle:(CGContextRef)context :(JLineModel*)line :(BOOL)isoscelesTriangle{
    CGPoint startP = [[line.lineArray firstObject] pointValue];
    CGPoint endP = [[line.lineArray lastObject] pointValue];
    startP = CGPointMake(startP.x*kWhiteBoardDrawWidth(self.m_fromVC), startP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    endP = CGPointMake(endP.x*kWhiteBoardDrawWidth(self.m_fromVC), endP.y*(kWhiteBoardDrawHeight(self.m_fromVC)));
    if(isoscelesTriangle){
        CGContextMoveToPoint(context, (endP.x-startP.x)/2 + startP.x, startP.y);
    }else{
        CGContextMoveToPoint(context, startP.x, startP.y);
    }
    CGContextAddLineToPoint(context, startP.x, endP.y);
    CGContextAddLineToPoint(context, endP.x, endP.y);
}
-(void)layout{
    [super layout];
    _m_alreayDrawView.frame = self.bounds;
}

//将iOS 左手坐标系转换成osx上的右手坐标系
- (CGPoint )funj_convertiOSCoordinateToMac:(CGPoint)p{
    return [self funj_convertMacCoordinateToiOS:p];
}
//将osx上的右手坐标系 转换成 iOS 左手坐标系
- (CGPoint )funj_convertMacCoordinateToiOS:(CGPoint)p{
    CGFloat x = p.x * self.width;
    CGFloat y = (1 - p.y) * self.height;
    return CGPointMake(x, y);
}

-(void)funj_deallocViews{
    [[JTimerHolder share] funj_removeThreadPools:self  :[NSString stringWithFormat:@"%zd",self.m_fromVC] ];
    [self.m_myLinesArr removeAllObjects];
    self.m_myLinesArr = nil;
}

-(void)dealloc{
    [self funj_deallocViews];
}

@end



