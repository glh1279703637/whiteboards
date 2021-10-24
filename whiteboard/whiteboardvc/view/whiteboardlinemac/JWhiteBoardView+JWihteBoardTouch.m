//
//  JWhiteBoardView+JWihteBoardTouch.m
//  MZCloudClass
//
//  Created by 123 on 2017/4/12.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardView+JWihteBoardTouch.h"
#import "JMeetingHandleManager.h"
#import "JMeetingRolesManager.h"
#import "JAppViewExtend.h"
@implementation JWhiteBoardView (JWihteBoardTouch)
int saveType = 0;
#pragma mark UIResponder
-(void)mouseDown:(NSEvent *)event{
    if(self.m_delegate){
        BOOL isHas = [self.m_delegate funj_selectTouchDownTo:NO];
        if(isHas)return;
    }
    saveType = 0;
    CGPoint p =[self convertPoint:event.locationInWindow fromView:nil];
    [self onPointCollected:p type:kWhiteBoardCmdTypePointStart];
}
-(void)mouseDragged:(NSEvent *)event{
    if(self.m_delegate){
        BOOL isHas = [self.m_delegate funj_selectTouchDownTo:NO];
        if(isHas)return;
    }
    CGPoint p =[self convertPoint:event.locationInWindow fromView:nil];
    [self onPointCollected:p type:kWhiteBoardCmdTypePointMove];
}
-(void)mouseUp:(NSEvent *)event{
    if(self.m_delegate){
        BOOL isHas = [self.m_delegate funj_selectTouchDownTo:YES];
        if(isHas)return;
    }
    CGPoint p =[self convertPoint:event.locationInWindow fromView:nil];
    [self onPointCollected:CGPointMake(p.x+0.01, p.y+0.01) type:kWhiteBoardCmdTypePointMove];
    [self onPointCollected:CGPointMake(p.x+0.01, p.y+0.01) type:kWhiteBoardCmdTypePointEnd];
}

- (void)onPointCollected:(CGPoint)p type:(CustomMeetingCommand)type{
    //local render
    if(p.x < fabs(self.left) ||
        p.y < fabs(self.top) ||
        p.x > fabs(self.left) +self.width ||
        p.y > fabs(self.top) + self.height){
        if(saveType ==0){
            type = kWhiteBoardCmdTypePointEnd;
            saveType = 1;
        }else return;
    }else{
        if(saveType == 1){
            type = kWhiteBoardCmdTypePointStart;
        }saveType = 0;
    }
    
    [self addPoints:CGPointMake(p.x/kWhiteBoardDrawWidth(self.m_fromVC), p.y/(kWhiteBoardDrawHeight(self.m_fromVC))) isNewLine:type ower:[JWhiteboardConfig share].m_myUserId];
    JMeetingRole *myRole = [JMeetingRolesManager share].myRole;
    if(![JWhiteboardConfig share].m_isManager && !myRole.m_isActor) return; //可防止外传
      
    if(type == kWhiteBoardCmdTypePointEnd && (self.m_fromVC == 1 || self.m_fromVC == 3)){
        JLineModel *lineModel = [self funj_getCurrentPageLastUserLine:[JWhiteboardConfig share].m_myUserId];
        [[JMeetingHandleManager share] funj_sendAddLinesToServer:lineModel];
    }
}
@end
