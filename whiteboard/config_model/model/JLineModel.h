//
//  JLineModel.h
//  8OrangeCloud
//
//  Created by 123 on 2016/12/14.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JBaseDataModel.h"
#import <UIKit/UIKit.h>
#import "JMeetingControlAttachment.h"

//线的类型
typedef  NS_ENUM(NSUInteger,BezierPathType){
    kPen_bezierPath = 1,
    kVectorLine_bezierPath,//2
    kArc_bezierPath,//3
    kRect_bezierPath,//4
    kIsoscelesTriangle_bezierPath,//5
    kRightTriangle_bezierPath,//6
    kEraser_bezierPath,//7
    
    kMark_Type,//8
    kPhoto_URL//9
};
@interface JLineModel : JBaseDataModel

//线色
 @property(nonatomic,strong) NSNumber* lineColor;
//线宽
@property(nonatomic,assign) CGFloat lineWidth;
//线坐标
@property(nonatomic,strong)NSMutableArray *lineArray;
@property(nonatomic,strong)UIBezierPath *m_linePath;

@property(nonatomic, copy) NSString *key;

//拥有者
@property(nonatomic,copy)NSString* ower;

//line type 区别当前的画笔是什么类型的
@property(nonatomic,assign) BezierPathType  m_bezierPathType;

@property(nonatomic,assign)NSTimeInterval m_addLineTime;

//+ (NSString *)pointCommand:(CustomMeetingCommand)type :(CGPoint)point :(NSNumber*)color :(CGFloat)size :(int)shadeType :(NSString*)page;
//+ (NSString *)pureCommand:(CustomMeetingCommand)type;
//
//+ (NSString *)syncCommand:(CustomMeetingCommand)type :(NSString *)uid end:(int)end;
//+ (NSString *)syncAllPageCommand:(CustomMeetingCommand)type :(NSString *)uid :(NSString*)page end:(int)end;//线总页数
//
+ (NSString *)funj_pureInsertPPTPageCommand:(CustomMeetingCommand)type :(NSString*)page :(NSString*)questionIndex;
//
//+ (NSString *)pureSyncPPTPageCommand:(CustomMeetingCommand)type :(NSString*)isShow :(NSString*)page :(NSInteger)totalCount :(NSString*)pageUrl;
//
+ (NSString *)funj_pureChangePPTPageCommand:(CustomMeetingCommand)type :(NSString*)page;
+ (NSString *)funj_pureChangeStartQuestionCommand:(CustomMeetingCommand)type :(NSString*)start  :(NSInteger)page :(NSString*)questionList ;
+ (NSString *)funj_pureChangePPTTouchAnimateCommand:(NSString*)boardKey :(NSString*)videoState :(NSString*)videoTimer :(NSString*)pptAnimation :(NSString*)pdfprogress;
//
//+ (NSString *)pureChangeCameraShowCommand:(CustomMeetingCommand)type :(NSString*)isShow;
@end
