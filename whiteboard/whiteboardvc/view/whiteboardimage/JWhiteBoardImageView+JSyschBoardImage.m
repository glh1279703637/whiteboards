//
//  JWhiteBoardImageView+JSyschBoardImage.m
//  MZCloudClass
//
//  Created by 123 on 2017/1/11.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardImageView+JSyschBoardImage.h"
#import "JWhiteBoardImageView+JOperationImageView.h"
#import "JHttpReqHelp.h"
#import "JLoginUserMessage.h"
#import "JMeetingRolesManager.h"
#import "JBaseInterfaceManager.h"
#import "JWhiteboardCmdHandle+Section.h"
#import "JMeetingHandleManager.h"
@implementation JWhiteBoardImageView (JSyschBoardImage)

-(void)funj_uploadImageToServer:(JImageModel*)imageModel :(NSDictionary*)dataUrl block:(void (^)(NSDictionary *data))callback{
    if(self.m_isNotNeedSycToOther)return ;

    JMeetingRole *myRole = [JMeetingRolesManager share].myRole;
    if(![JWhiteboardConfig share].m_isManager && !myRole.m_isActor) return; //可防止外传
    LRWeakSelf(self);
    LRWeakSelf(imageModel);
    void (^uploadCallback)(NSDictionary*dataDic) = ^(NSDictionary*dataDics){
        LRStrongSelf(self);
        LRStrongSelf(imageModel);
        UIImageView *imageView = imageModel.imageView;
        if(callback) callback(dataDics);
         if(self.m_isNotNeedSycToOther)return ;
        [[JMeetingHandleManager share]funj_sendAddImageToServer:imageModel];
    };
    
    if(dataUrl){
        NSDictionary *dataDic =@{@"fileId":dataUrl[@"userAnswer"]?dataUrl[@"userAnswer"]:@"" ,@"pageIndex":dataUrl[@"pageIndex"]?dataUrl[@"pageIndex"]:@""};
        if(uploadCallback)uploadCallback(dataDic);
    }else{
        NSString *name = [NSString stringWithFormat:@"autodelete/IOS%@_%d.jpg",[JWhiteboardConfig share].m_classroomId,arc4random()];
        [JBaseInterfaceManager funj_uploadFileDataToQNiuWithName:nil :name :imageModel.imageView.image :nil progress:nil  success:^(id strongSelf,NSArray * dataArr,NSDictionary*dataDic) {
            if(dataDic){
                NSDictionary *dic =@{@"fileId":dataDic[@"key"]?[APPQiNiuROOTURL(@"imagess") stringByAppendingString:dataDic[@"key"]]:@""};
                if(uploadCallback)uploadCallback(dic);
            }
        } failure:nil];
    }
    

}
//老师 点击答案中的分享时回调
// 重新加载图片，并重新上传
-(void)funj_requestMessageFromStudentAnswerToShare:(NSArray*)urlArr{
     for(int i=0;i<urlArr.count;i++){
        NSMutableDictionary *dic =[[NSMutableDictionary alloc]initWithDictionary:urlArr[i]];
        [dic setObject:@(i) forKey:@"pageIndex"];
        UIImageView *imageView =[UIImageView funj_getImageView:CGRectZero bgColor:nil];
         [self addSubview:imageView];
        NSString *url =dic[@"userAnswer"];
         __weak typeof(self)weakSelf = self;
         __weak typeof(imageView ) weakImageView= imageView;
         [imageView funj_setInternetImageBlock:url  :@"file_file" :^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             __strong typeof(weakImageView)strongImageView = weakImageView;
            __strong typeof(weakSelf)strongSelf = weakSelf;
             [strongImageView removeFromSuperview];
             
             UIImageView *imageView = [strongSelf funj_reloadToAddImageViews:image :CGSizeZero :YES :dic];
            if(i+1 == urlArr.count ){
                [strongSelf funj_startToTouchImageView:imageView];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"currentIsShareToReloadImageView" object:nil];
            }
          }];

     }
}

@end
