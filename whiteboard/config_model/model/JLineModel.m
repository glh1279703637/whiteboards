//
//  JLineModel.m
//  8OrangeCloud
//
//  Created by 123 on 2016/12/14.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JLineModel.h"
#define JWhiteboardCmdFormatPagePureCmd @"%zd:%@;"
#define JWhiteboardCmdFormatStartQuestionPureCmd @"%zd:%@,%zd,%@;"
#define JWhiteboardCmdFormatInsertPagePureCmd @"%zd:%@,%@;"
#define JWhiteboardCmdFormatPPTAnimationPureCmd @"%zd:%@,%@,%@,%@,%@;"


@implementation JLineModel
-(void)setm_linePath:(UIBezierPath *)m_linePath{
    _m_linePath = m_linePath;
    _lineArray = nil;
}
-(id)init{
    if(self =[super init]){
        _lineArray=[[NSMutableArray alloc]init];
        self.m_bezierPathType = kPen_bezierPath;
    }
    return self;
}
+ (NSString *)funj_pureInsertPPTPageCommand:(CustomMeetingCommand)type :(NSString*)page :(NSString*)questionIndex{
    return [NSString stringWithFormat:JWhiteboardCmdFormatInsertPagePureCmd, type ,page,questionIndex];
}

+ (NSString *)funj_pureChangePPTTouchAnimateCommand:(NSString*)boardKey :(NSString*)videoState :(NSString*)videoTimer :(NSString*)pptAnimation :(NSString*)pdfprogress{ // videostate -1,1,2 不处理，播放，停止
    return [NSString stringWithFormat:JWhiteboardCmdFormatPPTAnimationPureCmd,kWhiteBoardChangePPTTouchAnimateCmdTypePPT,boardKey, videoState,videoTimer, pptAnimation,pdfprogress];
}

+ (NSString *)funj_pureChangePPTPageCommand:(CustomMeetingCommand)type :(NSString*)page{
    return [NSString stringWithFormat:JWhiteboardCmdFormatPagePureCmd, type, page];
}
+ (NSString *)funj_pureChangeStartQuestionCommand:(CustomMeetingCommand)type :(NSString*)start  :(NSInteger)page :(NSString*)questionList {
    return [NSString stringWithFormat:JWhiteboardCmdFormatStartQuestionPureCmd, type, start,page,questionList];
}

@end
