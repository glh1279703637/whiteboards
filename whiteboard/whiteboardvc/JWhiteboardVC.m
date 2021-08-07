//
//  JWhiteboardVC.m
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/5/9.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JWhiteboardVC.h"
#import "JClassMeetingRoomMC+JNIMCallback.h"
#import "JWhiteboardMC+JExamQuestion.h"
@interface JWhiteboardVC ()

@end

@implementation JWhiteboardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self funj_addConfigDefine];
}
-(void)funj_addConfigDefine{
    [[JWhiteboardMC share] setM_whiteboardVC:self];
    [[JWhiteboardMC share] funj_reloadWhiteboardDefaultConfig];
    [[JWhiteboardMC share] funj_addQuestionToWhiteboard];
}
//获取互动权限后 强制为白板权限
-(void)funj_reloadBottomItemUserInfer:(BOOL)isUserInfer{
    self.m_whiteboardBgSubView.m_canUserInerfaceLayer = isUserInfer ? kuserIsWhiteboardLayer : kuserIsNone;
    self.m_imageBgView.m_handleBgImageView.hidden = YES;
    if(isUserInfer){// 主要是由于学生被互动过一次，然后学生点击了操作图片情况 下再被断开互动。这个时候再次被互动。因此调整为默认操作画笔
        self.m_currentDrawTypeTag = kPen_tag;
        [self.m_bottomPenBgView funj_autoChangeMoveToPen:-1];
        [self.m_bottomPenBgView funj_autoChangeMoveToPen:self.m_currentDrawTypeTag];
        [self.m_bottomPenBgView funj_changePenColorImageViewSize:self.m_whiteBoardView.m_lineWidth];
        [self.m_whiteBoardView setBezierPathType:kPen_bezierPath];
    }
}
@end
