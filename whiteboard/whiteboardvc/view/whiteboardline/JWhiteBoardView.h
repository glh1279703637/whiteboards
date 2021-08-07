//
//  JWhiteBoardView.h
//  MZCloudClass
//
//  Created by 123 on 2016/12/14.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JBaseView.h"
#import "JLineModel.h"
#import <DigitalNote/DigitalNote.h>
#import "JWhiteboardConfig.h"

/*
 白板一共两层，一层只绘制当前画笔对应 的笔迹，另外一层，则绘制其他剩下笔迹
 防止绘制过程中出现卡顿
 */

@interface JWhiteBoardView : JBaseView<DigitalNoteDelegate>

@property(nonatomic,assign)NSInteger m_fromVC;// 1:白板中，2:其他来源，即不需要传输给其他用户

@property(nonatomic,assign)BezierPathType  m_bezierPathType; //绘画类型
@property(nonatomic,strong)  NSNumber *m_lineColor; //画笔颜色
@property(nonatomic,assign)CGFloat m_lineWidth,m_eraserWidth;//画笔大小 或者橡皮檫大小

@property(nonatomic,assign)int m_drawLineTimers;//保存当时最后一条线未绘画的时间间隔，倒计时，方便刷新全部。

//线的全部数据保存位置
@property(nonatomic,copy)NSString *m_currentPage;//白板的当前页，画笔所有的页码
@property(nonatomic,strong)NSMutableArray *m_myLinesArr;//保存当前画面的线路径
@property(nonatomic,strong)NSMutableDictionary *m_myAllLinesDic;//保存所有画面的线路径
@property(nonatomic, assign)BOOL m_shouldDraw;


- (id)initWithFrame:(CGRect)frame :(NSInteger)fromVc;  //1.whiteboard ,2.questionvc
//设置绘制类型
- (void)setBezierPathType:(BezierPathType)type;
//设置颜色
- (void)setLineColor:(NSNumber*)color :(CGFloat)width :(BOOL) isEraser;
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
-(void)funj_changePageToReloadCurrentLine:(NSString*)page ;
-(void)funj_changeQuestionPageToReloadCurrentLine:(NSString*)page;

-(UIBezierPath*)funj_getBezierPath:(JLineModel *)line;

-(void)funj_deallocViews;
@end
