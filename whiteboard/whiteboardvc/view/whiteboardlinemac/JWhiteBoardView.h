//
//  JWhiteBoardView.h
//  MZCloudClass
//
//  Created by 123 on 2016/12/14.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JBaseView.h"
#import "JLineModel.h"
#import "JWhiteboardConfig.h"

@protocol JWhiteBoardViewDelegate <NSObject>

-(BOOL)funj_selectTouchDownTo:(BOOL)isMustHidden;

@end

@interface JWhiteBoardView : JBaseView

@property(nonatomic,assign)NSInteger m_fromVC;// 1:白板中，2:其他来源，即不需要传输给其他用户

@property(nonatomic,assign)BezierPathType  m_bezierPathType;
@property(nonatomic,strong)  NSNumber *m_lineColor;
@property(nonatomic,strong)  NSColor *m_lineColor2;

@property(nonatomic,assign)CGFloat m_lineWidth,m_eraserWidth;

@property(nonatomic,assign)int m_drawLineTimers;//保存当时最后一条线未绘画的时间间隔，倒计时，方便刷新全部。
@property (nonatomic,strong) NSArray *m_colorArray ;

@property (nonatomic,weak) id<JWhiteBoardViewDelegate> m_delegate ;

//线的全部数据保存位置
@property(nonatomic,copy)NSString *m_currentPage;
@property(nonatomic,strong)NSMutableArray *m_myLinesArr;//保存当前画面的线路径
@property(nonatomic,strong)NSMutableDictionary *m_myAllLinesDic;//保存所有画面的线路径
@property(nonatomic, assign)BOOL m_shouldDraw;


- (id)initWithFrame:(CGRect)frame :(NSInteger)fromVc;  // 1:白板中，2:其他来源，即不需要传输给其他用户

-(void)funj_reloadAlreadyDrawViewColor;

//设置绘制类型
- (void)setBezierPathType:(BezierPathType)type;
//设置颜色
- (void)setLineColor:(NSNumber*)color :(CGFloat)width :(BOOL) isEraser;
- (void)setLineColor2:(NSColor*)color2;
//增加线
- (void)addPoints:(CGPoint)point isNewLine:(NSInteger)type ower:(NSString*)ower ;
- (void)addNetPoints:(CGPoint)point isNewLine:(NSInteger)type ower:(NSString*)ower :(BezierPathType )shapetype :(NSNumber*)lineColor :(CGFloat)width :(NSString*)page;
-(void)funj_addLineToView:(JLineModel*)lineModel :(NSString*)page;

//取消 某用户的线最后一条
-(void)funj_cancelLastLine:(NSString*)page :(NSString *)uid :(NSString*)lineKey;
-(JLineModel*)funj_getCurrentPageLastUserLine:(NSString*)uid;
//删除所有
- (NSArray*)funj_deleteSomePageAllLines:(NSString*)page  :(NSString*)userId  c:(BOOL)isReload;
-(void)funj_deleteAllLinesFrom:(NSString*)page;
-(void)funj_deleteLinesFromIds:(NSString*)page :(NSString*)idkeys;

 //初始化存储笔记
-(void)funj_reloadToChangeAllPageIndex:(NSDictionary*)changeDic;

//更新页面
//-(void)funj_changePageToReloadCurrentLine:(NSString*)page ;
//-(void)funj_changeQuestionPageToReloadCurrentLine:(NSString*)page;

-(CGMutablePathRef)funj_getBezierPath:(CGContextRef)context :(JLineModel *)line;

-(void)funj_deallocViews;

//将iOS 左手坐标系转换成osx上的右手坐标系
- (CGPoint )funj_convertiOSCoordinateToMac:(CGPoint)p;
//将osx上的右手坐标系 转换成 iOS 左手坐标系
- (CGPoint )funj_convertMacCoordinateToiOS:(CGPoint)p;
@end

