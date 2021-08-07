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
@implementation JWhiteBoardView (JWihteBoardTouch)
int saveType = 0;
#pragma mark UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    saveType = 0;
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint p = [touch locationInView:self];
 
    [self onPointCollected:p type:kWhiteBoardCmdTypePointStart];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint p = [touch locationInView:self];
 
    [self onPointCollected:p type:kWhiteBoardCmdTypePointMove];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint p = [touch locationInView:self];
 
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
      
    if(type == kWhiteBoardCmdTypePointEnd && self.m_fromVC == 1){
        JLineModel *lineModel = [self funj_getCurrentPageLastUserLine:[JWhiteboardConfig share].m_myUserId];
        [[JMeetingHandleManager share] funj_sendAddLinesToServer:lineModel];
    }
}
#pragma mark - note delegate
NSInteger upPPP = 0;
-(void)getRealTimeXYPDelegate:(NSInteger)X withY:(NSInteger)Y withP:(NSInteger)P{
    LRWeakSelf(self);
    dispatch_sync(dispatch_get_main_queue(), ^{
        LRStrongSelf(self);
        NSInteger stype = kWhiteBoardCmdTypePointMove;
        if(upPPP ==0 && P >0){
            stype = kWhiteBoardCmdTypePointStart;
        }else if(upPPP >0 && P<=0){
            stype = kWhiteBoardCmdTypePointEnd;
        }
        upPPP = P;
        
        CGFloat x = 1.0 * Y * kWhiteBoardDrawWidth(self.m_fromVC) / 21000  ;
        CGFloat y = kWhiteBoardDrawHeight(self.m_fromVC) - 1.0 * X*kWhiteBoardDrawHeight(self.m_fromVC) /14800;
        if(P <=0 && stype!=kWhiteBoardCmdTypePointEnd )return;
        
        [self onPointCollected:CGPointMake(x, y ) type:stype];
     });
}

@end
