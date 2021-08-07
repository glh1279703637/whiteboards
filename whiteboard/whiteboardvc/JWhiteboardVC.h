//
//  JWhiteboardVC.h
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/5/9.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JBaseWhiteboardVC.h"
#import "JWhiteboardMC.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SelectRightItemType) {
    kPen_tag = 0,//画笔
    kBgPen_tag,//荧光笔
    kShape_tag,//形状
    kColor_tag,//颜色
    kToBack_tag, //返回上一次
    kAddImage_tag,//添加图片
    kImageHandle_tag,//图片操作
    kDeleteAll_tag,//删除全部
    kAddNewPage_tag,//新添页
    kCutOut_tag,//截屏
    
    kClear_tag,//清空
    
    kChangePPT_tag,//切换ppt
    
    //right bottom tag
    kCameraViewVisible_tag = 1005, //摄像头
    kVoice_tag = 1002,//声音
    kConversation_tag = 1004, //全体禁言
    kUserHanding_Tag = 1003,//举手
    
};
@interface JWhiteboardVC : JBaseWhiteboardVC
@property (nonatomic,assign) SelectRightItemType m_currentDrawTypeTag ;

//刷新当前页面是否可点击 学生
-(void)funj_reloadBottomItemUserInfer:(BOOL)isUserInfer;

@end

NS_ASSUME_NONNULL_END
