//
//  JWhiteboardVC+JDelegateCallback.m
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/7/2.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JWhiteboardVC+JDelegateCallback.h"
#import "JMeetingRolesManager.h"
#import "JPopPPTListView.h"
#import "JIToolBaseVC.h"
#import "JMeetingHandleManager.h"
#import "JWhiteBoardImageView+JOperationImageView.h"
#import "JSelectCourseWareView.h"
#import "JWhiteboardInterface.h"
#import "JAddQuickVoteView.h"
#import "JClassMeetingRoomMC.h"
#import "JClassMeetingRoomVC+JQuickVote.h"
#import "JClassMeetingRoomMC+JWebVideo.h"
#import "JSelectQuestionView.h"
#import "JExamQuestionItem.h"
#import "JQuestionInterface.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@interface JWhiteboardVC ()<JIToolBaseVCDelegate>

@end
@implementation JWhiteboardVC (JDelegateCallback)
#pragma mark JWhiteboardBgViewDelegate
-(void)funj_changeUserInferfaceLaberCallback:(CanUserInerfaceLayer)type{
    // 编号1—1 切换白板 ppt 时，对控制层进行调整
    [self.m_bottomPenBgView funj_reloadChangePPTOrWhiteboardPen_PPT:(type == kuserIsPPTLayer)];
    [self.m_bottomPenBgView funj_checkPenIsSelectedWhenWhiteboard:(type == kuserIsWhiteboardLayer)];
}
#pragma mark JBottomPenBgViewDelegate
-(NSInteger)funj_selectBottomItemToolAction:(UIButton*)sender s:(NSInteger)upSelected{
    JWhiteboardConfig *config =[JWhiteboardConfig share];
    SelectRightItemType itemIndex = sender.tag - 130;
    
    if(itemIndex != kCutOut_tag){
        BOOL isCanSelect = YES;
        if(config.m_isManager ){
            isCanSelect = ![[JExamQuestionItem share] m_canAnserQuestion];
        }
        if(!isCanSelect){
            [JAppViewTools funj_showTextToast:self.view message:LocalStr(@"Operate prohibited currently")]; return -1;
        }
    }
    //手势在哪个图层上
    self.m_imageBgView.m_handleImageView.hidden = YES;
    self.m_imageBgView.m_handleBgImageView.hidden = YES;

    switch (itemIndex) {
        case kPen_tag:{
            BOOL upDraw = upSelected == kPen_tag;
            [self.m_bottomPenBgView funj_changePenColorImageViewSize:self.m_whiteBoardView.m_lineWidth];
            [self.m_whiteBoardView setBezierPathType:kPen_bezierPath];
            self.m_currentDrawTypeTag = itemIndex;
            self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
            if(self.m_PPTBgView.m_currentISPPT && upDraw && config.m_isManager){
                // 编号1—1 切换白板 ppt 时，对控制层进行调整
                self.m_whiteboardBgSubView.m_upInerfaceLayer = self.m_whiteboardBgSubView.m_canUserInerfaceLayer;
                self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsPPTLayer; return 2;
            }
        }break;
        case kBgPen_tag:{
            self.m_currentDrawTypeTag = itemIndex;
            [self.m_bottomPenBgView funj_changePenColorImageViewSize:self.m_whiteBoardView.m_lineWidth];
            [self.m_whiteBoardView setBezierPathType:kMark_Type];
            self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
        }break;
        case kShape_tag:{
            JIToolBaseVC *vcs = (JIToolBaseVC*)[self funj_getPopoverVC:@"JIToolBaseVC" :sender :nil :CGSizeMake(70, 220) :nil];
            vcs.m_delegate = self; vcs.m_setShapeType = 1;
            vcs.m_isEraser = self.m_whiteBoardView.m_bezierPathType == kEraser_bezierPath;
        }break;
        case kColor_tag:{
            JIToolBaseVC *vcs = (JIToolBaseVC*)[self funj_getPopoverVC:@"JIToolBaseVC" :sender :nil :CGSizeMake(140,170) :nil];
            vcs.m_delegate = self; vcs.m_setShapeType = 2;
            vcs.m_isEraser = self.m_whiteBoardView.m_bezierPathType == kEraser_bezierPath;
            vcs.m_line_eraserWidth = vcs.m_isEraser ? self.m_whiteBoardView.m_eraserWidth : self.m_whiteBoardView.m_lineWidth;
        }break;
        case kToBack_tag:{
            JLineModel *lineModel = [self.m_whiteBoardView funj_getCurrentPageLastUserLine:config.m_myUserId];
            [self.m_whiteBoardView funj_cancelLastLine:nil :config.m_myUserId :lineModel.key];
            [[JMeetingHandleManager share]funj_deleteActionToServer:lineModel.key];
        }break;
        case kAddImage_tag:{
            self.m_currentIsLoadMultPhoto = NO;
            [self funj_editPortraitImageView:sender];
            [self.m_imageBgView funj_startToTouchImageViewWithChangeBt];
            self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsImageLayer;
        }break;
        case kImageHandle_tag:{
            [self.m_imageBgView funj_startToTouchImageViewWithChangeBt];
            self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsImageLayer;
            
        }break;
        case kDeleteAll_tag:{
             [JAppViewTools funj_showSheetBlock:self  :sender :LocalStr(@"Delete mode") :@[LocalStr(@"Eraser"),config.m_isManager?LocalStr(@"Empty this page"):LocalStr(@"Empty their content")] block:^( JWhiteboardVC* strongSelf, NSInteger index) {
                 [strongSelf funj_selectToShowDeletePop:index];
            }];
        }break;
        case kAddNewPage_tag:{
            if(!config.m_isManager)return 0;
            NSMutableArray *array =[[NSMutableArray alloc]initWithArray:@[LocalStr(@"New board"),LocalStr(@"New questions"),LocalStr(@"Import CourseWare"),LocalStr(@"Quick vote")]];
            if(config.m_interaction != 3){
                [array addObject:LocalStr(@"Active answer")];
            }

            [JAppViewTools funj_showSheetBlock:self :sender :LocalStr(@"New Page") :array block:^( id strongSelf, NSInteger index) {
                [self funj_selectToAddNewViews:index];
            }];
        }break;
        case kCutOut_tag:{
            self.m_screenShotView.hidden = NO;
            CGPoint point =[self.m_bottomPenBgView convertPoint:sender.frame.origin toView:self.view];
            self.m_screenShotView.m_senderPoint = point;
            [self.m_screenShotView funj_quickShootScreenView];
         }break;
        case kChangePPT_tag:{
            sender.accessibilityValue = nil; sender.hidden = YES;
            self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
            self.m_whiteboardBgSubView.m_upInerfaceLayer = kuserIsWhiteboardLayer;
        }
        default:
            break;
    }
    return 0;
}

-(void)funj_selectRightBottomAction:(UIButton*)button{
    JMeetingRole *myRole = [JMeetingRolesManager share].myRole;
    JWhiteboardConfig *config = [JWhiteboardConfig share];
    switch (button.tag) {
         case kVoice_tag:{
            if(!config.m_isManager && !myRole.m_isActor){
                [JAppViewTools funj_showTextToast:self.view message:LocalStr(@"Operate prohibited currently")];
                button.selected = myRole.m_audioOn;
                return;
            }
            [[JMeetingRolesManager share] funj_setMyAudio:!myRole.m_audioOn];
            button.selected = !button.selected;
        }break;
        case kConversation_tag:{
            [self funj_setChatroomAllMute:button];
        }break;
        case kUserHanding_Tag:{
//             if([JWhiteboardConfig share].m_tempCanActor){
//                button.selected = !button.selected;
//                [JAppViewTools funj_showTextToast:self.view message:LocalStr(@"Interaction prohibited in the session")];
//                return ;
//            }
            if(myRole.m_isActor){
                 [JAppViewTools funj_showAlertBlocks:self :nil :LocalStr(@"Confirmed to terminate your interaction rights?") :^( JWhiteboardVC* strongSelf, NSInteger index) {
                     if(index == 1){
                         [[JClassMeetingRoomMC share] funj_postUserActorStateFromOwner:0];
                    }
                }];
            }else{
                button.selected = !button.selected;
                [[JMeetingRolesManager share] funj_changeRaiseHandSend:button.selected];
                if(button.selected){
                    [JWhiteboardInterface funj_requestHandsUp:myRole.m_uid];
                }
            }
        }break;
        case kCameraViewVisible_tag:{
            button.selected = !button.selected;
            [[JMeetingRolesManager share] funj_setMyVideo:button.selected];
        }break;
        default:
            break;
    }
}
-(void)funj_longPresessToShotView:(UIGestureRecognizer*)gesture{
    UIView *sender = gesture.view;
    self.m_screenShotView.hidden = NO;
    CGPoint point =[self.m_bottomPenBgView convertPoint:sender.frame.origin toView:self.view];
    self.m_screenShotView.m_senderPoint = point;
    [self.m_screenShotView funj_reloadToDefault:YES];
}
-(void)funj_textFieldShouldBeginEditing:(UITextField *)textField{
    LRWeakSelf(self);
    NSInteger page = self.m_PPTBgView.m_currentPPTIndex;
    NSInteger totalPage = self.m_PPTBgView.m_totalPPTIndexs;
    BOOL currentIsOneToMorePage = NO;
    if(self.m_PPTBgView.m_currentISPPT && totalPage == 1 && [JWhiteboardMC share].m_totalOneToMorePages > 1){
        currentIsOneToMorePage = YES;
        NSArray *pageArr = [textField.text componentsSeparatedByString:@" / "];
        page = [[pageArr firstObject] integerValue];
        totalPage = [JWhiteboardMC share].m_totalOneToMorePages;
    }
    
    JPopPPTListView *popPPTView =(JPopPPTListView*)[JPopPPTListView funj_getPopoverVC:textField :page :totalPage];
    popPPTView.m_selectReloadPageCallback = ^(NSInteger page) {
        LRStrongSelf(self);
        if(currentIsOneToMorePage){
            NSString *boardKey = [JWhiteboardMC share].m_currentBoardKey;
            NSString* cmd = [JLineModel funj_pureChangePPTTouchAnimateCommand:boardKey :@"-1" :@"-1" :[NSString stringWithFormat:@"%zd",page+1] :@""];
            [self.m_PPTBgView handlePPtContentFromSync:cmd];
            [[JWhiteboardMC share] funj_reloadOneToMorePPT:page t:-1];
        }else{
            page += self.m_PPTBgView.m_minPPTPage;
            [[JWhiteboardMC share] funj_setNewCurrentPage:page k:nil  f:kFROMCHANGEPAGEITEM];
        }
    };
}
-(void)funj_selectShapeActionTo:(NSInteger)bezierPathType{
    [self.m_whiteBoardView setBezierPathType:bezierPathType];
    self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
    [self.m_bottomPenBgView funj_autoChangeMoveToPen:-1];
    [self.m_bottomPenBgView funj_autoChangeMoveToPen:kShape_tag];
}
-(void)funj_selectColorActionTo:(NSNumber*)color{
    [self.m_bottomPenBgView funj_changePenImage];
    [self.m_whiteBoardView setLineColor:color :-1 :NO];
    self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
    [self.m_bottomPenBgView funj_autoChangeMoveToPen:self.m_currentDrawTypeTag];
}
-(void)funj_changesliderSizeTo:(CGFloat)size :(BOOL)isEraser{
    [self.m_whiteBoardView setLineColor:nil :size :isEraser];
    self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
    [self.m_bottomPenBgView funj_changePenColorImageViewSize:size];
    [self.m_bottomPenBgView funj_autoChangeMoveToPen:self.m_currentDrawTypeTag];
}
-(void)funj_selectPhotosFinishToCallback:(NSArray *)photos t:(BOOL)isVideo{
    LRWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LRStrongSelf(self);
        JMeetingRole *myRole =[JMeetingRolesManager share].myRole;
        if(!([JWhiteboardConfig share].m_isManager || myRole.m_isActor))return;
        for(UIImage *portraitImg in photos){
            UIImageView *imageView = [self.m_imageBgView funj_reloadToAddImageViews:portraitImg :CGSizeZero :YES :nil];
            [self.m_imageBgView funj_changeDefaultSubViewsFrames:imageView];
        }
    });
}

#pragma mark addwhiteboard action
-(void)funj_selectToShowDeletePop:(NSInteger)index{
    JWhiteboardConfig *config =[JWhiteboardConfig share];
    if(index == 0){
        self.m_currentDrawTypeTag = -1;
        self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
        [self.m_bottomPenBgView funj_changePenColorImageViewSize:self.m_whiteBoardView.m_eraserWidth];
        [self.m_bottomPenBgView funj_autoChangeMoveToPen:-1];
        [self.m_whiteBoardView setBezierPathType:kEraser_bezierPath];
    }else if(index == 1){
        [JAppViewTools funj_showAlertBlocks:self :nil :(config.m_isManager?LocalStr(@"Confirmed to delete everything?"):LocalStr(@"Confirmed to delete your everything?")) :^( JWhiteboardVC* strongSelf, NSInteger index) {
            if(index ==1){ [strongSelf funj_selectToDeleteBoardLine]; }
        }];
    }
}
-(void)funj_selectToDeleteBoardLine{
   JWhiteboardConfig *config =[JWhiteboardConfig share];
   if(config.m_isManager){
       [[JMeetingHandleManager share]funj_clearAllItemsFromWhiteBoard];
       [self.m_whiteBoardView funj_deleteSomePageAllLines:nil :(config.m_isManager ? nil : config.m_myUserId) c:YES];
       [self.m_imageBgView funj_deleteSomePageAllImageView:nil :(config.m_isManager ? nil : config.m_myUserId)];
   }else{
       NSArray *lines = [self.m_whiteBoardView funj_deleteSomePageAllLines:nil :(config.m_isManager ? nil : config.m_myUserId) c:YES];
       NSArray *images = [self.m_imageBgView funj_deleteSomePageAllImageView:nil :(config.m_isManager ? nil : config.m_myUserId)];

       if(lines && lines.count >0)[[JMeetingHandleManager share]funj_deleteObjectToServer:@{@"keys":lines}];
       if(images && images.count >0)[[JMeetingHandleManager share]funj_deleteObjectToServer:@{@"keys":images}];
   }
}
-(void)funj_selectToAddNewViews:(NSInteger)index{
    switch (index) {
        case 0:{
            if(self.m_PPTBgView.m_currentISPPT){
                [JAppViewTools funj_showTextToast:self.view message:LocalStr(@"New page only allowed in whiteboard")]; return;
            }
            [[JMeetingHandleManager share]funj_createBoardWithRoom:nil :nil :nil];
        }break;
        case 1:{
            if(self.m_PPTBgView.m_currentISPPT){
                [JAppViewTools funj_showTextToast:self.view message:LocalStr(@"New page only allowed in whiteboard")]; return;
            }
            [self funj_addSelectQuestionSubView];
        }break;
        case 2:{
            __weak typeof(self) weakSelf = self;
            JSelectCourseWareView *selectCourseWareView =(JSelectCourseWareView*)[self funj_getPresentCallbackVCWithController:@"JSelectCourseWareView" title:nil  :nil  :YES :^(JBaseViewController *vc) {
                JBaseNavigationVC *nav = (JBaseNavigationVC*)vc.navigationController;
                nav.m_currentNavColor = kCURRENTISBLUENAV_TAG;
            }];
            selectCourseWareView.m_selectItemCallback= ^(NSString*courseWareId ){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [JAppViewTools funj_showAlertBlocks:strongSelf  :nil :LocalStr(@"Are you confirmed to change your PPT?") :^(UIViewController *strongSel, NSInteger index) {
                    JWhiteboardVC *strongSelf = (JWhiteboardVC*)strongSel;
                    if(index == 1){
                        [strongSelf funj_selectCourseWareView:courseWareId];
                    }
                }];
            };
        }break;
        case 3:{
            if(![JWhiteboardConfig share].m_livePushing){
                [JAppViewTools funj_showTextToast:[UIApplication sharedApplication].keyWindow message:LocalStr(@"Please do it after the class starts.")];
                return ;
            }
            [[JClassMeetingRoomMC share].m_classMeetingRoom funj_startCreateQuickVoteView];
         }break;
        case 4:{
            if(![JWhiteboardConfig share].m_livePushing){
                [JAppViewTools funj_showTextToast:[UIApplication sharedApplication].keyWindow message:LocalStr(@"Please do it after the class starts.")];
                return ;
            }
            [self funj_getPopoverVC:@"JActiveAnswerView" :nil  :nil :CGSizeMake((IS_IPAD?320:250), 420) : nil];
         }break;
        default:
            break;
    }
 
}
-(void)funj_addSelectQuestionSubView{
    JSelectQuestionView *selectQuestion = (JSelectQuestionView*)[self funj_getPresentVCWithController:@"JSelectQuestionView" title:nil  :nil  :NO];
    __weak typeof(self) weakSelf = self;
    selectQuestion.m_selectQuCallback = ^(NSArray *dataArr, NSDictionary *homeworkDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for(NSString*key in homeworkDic.allKeys){
            NSDictionary *dic = [homeworkDic objectForKey:key];
            if([dic[@"count"] integerValue]>0 && ![[[JWhiteboardConfig share] m_saveHomeworkTitleDic] objectForKey:key]){
                dic = @{@"title":dic[@"title"],@"homeworkId":key};
                [[[JWhiteboardConfig share] m_saveHomeworkTitleDic] removeAllObjects];
                [[[JWhiteboardConfig share] m_saveHomeworkTitleDic] setObject:dic forKey:key];
            }
        }
        if([dataArr count]<=0) return ;
        [[JExamQuestionItem share]funj_addQuestionData:dataArr];
            
        NSString *examStr = @"";NSString *autoType = @"";
        for(int i=0;i<strongSelf.m_PPTBgView.m_dataArr.count;i++){
            BoardMap *map = strongSelf.m_PPTBgView.m_dataArr[i];
            if(map.board.exam && map.board.exam.length>0){
                examStr =[examStr stringByAppendingFormat:@"%@,",map.board.exam];
                NSDictionary *dic =[[[JExamQuestionItem share]m_saveQuestionDic] objectForKey:[NSString stringWithFormat:@"%@",map.board.exam]];
                autoType =[autoType stringByAppendingFormat:@"%@,",dic[@"questionType"]];
            }
        }
        NSString *newExamStr = @"",*autosType = @"";
        for(int i=0;i<dataArr.count;i++){
            NSDictionary *dic = dataArr[i];
            NSString *idStr =[NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            if([examStr rangeOfString:idStr].length<=0){
                NSString *type =[dic objectForKey:@"questionType"];
                newExamStr = [newExamStr stringByAppendingFormat:@"%@,",idStr];
                int index = 2;
                if(([type intValue] == 2 || [type intValue] == 4 || [type intValue] == 5) && [type intValue] == 1) index = 1;
                    autosType=[autosType stringByAppendingFormat:@"%d,",index];
            }
        }
        if([newExamStr length]<=0) return ;
        if(newExamStr.length > 0){
            examStr =[examStr stringByAppendingString:newExamStr];
            autoType =[autoType stringByAppendingString:autosType];
        }
            
        newExamStr =[newExamStr substringToIndex:newExamStr.length-1];
//        autosType =[autosType substringToIndex:autosType.length-1];
        examStr =[examStr substringToIndex:examStr.length-1];
        autoType =[autoType substringToIndex:autoType.length-1];
        [[JMeetingHandleManager share]funj_createBoardWithRoom:newExamStr :nil :nil];
        [JQuestionInterface funj_requestSaveQuestionIdToServer:examStr :autoType :[JWhiteboardConfig share].m_classroomId];
    };

}
-(void)funj_selectCourseWareView:(NSString*)courseWareId{
    [JWhiteboardMC share].m_totalOneToMorePages = 1;
    [self.m_whiteBoardView funj_deleteAllLinesFrom:[NSString stringWithFormat:@"%zd",self.m_PPTBgView.m_dataArr.count+1]];
    [self.m_imageBgView funj_deleteAllImageFrom:[NSString stringWithFormat:@"%zd",self.m_PPTBgView.m_dataArr.count+1]];
    [[JWhiteboardMC share] funj_deleteAllItemsFrom:[NSString stringWithFormat:@"%zd",self.m_PPTBgView.m_dataArr.count+1]];

    NSString *keys = @"";
    for(int i=0;i<self.m_PPTBgView.m_dataArray.count;i++){
        BoardMap *map = self.m_PPTBgView.m_dataArray[i];
        keys =[keys stringByAppendingFormat:@"%@,",map.key];
    }
    if(keys.length>0){
        keys =[keys substringToIndex:keys.length-1];
        [[JMeetingHandleManager share]funj_deleteWhiteboardToServer:keys];
    }
    [JWhiteboardInterface funj_requestFileFromServer:courseWareId :nil :^(id viewController,NSArray * dataArr,NSDictionary*dataDic) {
           dataArr = dataDic[@"data"][@"childList"];
        NSString *courseWareIds = @"";
        for(int i=0;i<dataArr.count;i++){
            courseWareIds =[courseWareIds stringByAppendingFormat:@"%@,",[(NSDictionary*)dataArr[i] objectForKey:@"coursewareContext"]];
        }
        if(courseWareIds.length>0){
            courseWareIds =[courseWareIds substringToIndex:courseWareIds.length-1];
        }else return ;
        [[JMeetingHandleManager share] funj_createBoardWithRoom:nil :courseWareIds :dataDic[@"data"][@"coursewareId"]];
        UIView/*JSegmentedControl*/ *segmentBt = [self.view.superview viewWithTag:3099];
        if(!self.m_PPTBgView.m_currentISPPT){
            segmentBt.accessibilityValue = @"must change first page";
        }
     }];
}
-(void)funj_setChatroomAllMute:(UIButton*)sender{
    [self.view endEditing:YES];
    sender.userInteractionEnabled = NO;
    LRWeakSelf(sender);LRWeakSelf(self);
    [JWhiteboardInterface funj_requestMuteTlistAll:!sender.selected?@"1":@"0" success:^(id viewController,NSArray * dataArr,NSDictionary*dataDic) {
         LRStrongSelf(sender);LRStrongSelf(self);
        sender.userInteractionEnabled = YES;
        if([JBaseInterfaceManager funj_VerifyIsSuccessful:dataDic show:NO callVC:self]){
            [JAppViewTools funj_showTextToast:self.view message:!sender.selected ?LocalStr(@"Complete to Speak prohibited"):LocalStr(@"Completed to Silence lifted")];
            sender.selected = !sender.selected;
        }
     } failure:^(UIViewController *viewController, NSString *error) {
         sender.userInteractionEnabled = YES;
    }];
}
@end
#pragma clang diagnostic pop
