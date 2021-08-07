//
//  JBaseWhiteboardVC.h
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/6/30.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JBaseImageViewVC.h"
#import "JWhiteBoardView.h"
#import "JWhiteBoardPPTView.h"
#import "JWhiteBoardImageView+JOperationImageView.h"
#import "JWhiteboardConfig.h"
#import "JBottomPenBgView.h"
#import "JScreenShotView.h"
#import "JClassRoomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JBaseWhiteboardVC : JBaseImageViewVC
@property (nonatomic,strong) JWhiteboardBgView *m_whiteboardBgSubView; //白板所有bgview

@property (nonatomic,strong) JWhiteBoardPPTView *m_PPTBgView ;//ppt 页面
@property (nonatomic,strong) JWhiteBoardImageView *m_imageBgView ;//图片操作页面
@property (nonatomic,strong) JWhiteBoardView *m_whiteBoardView ;//白板画面

@property (nonatomic,strong) JBottomPenBgView *m_bottomPenBgView ;//底部工具栏bgview
@property (nonatomic,strong) JBottomBgView *m_bottomBgView ;//底部工具栏bgview

@property(nonatomic,strong)JScreenShotView *m_screenShotView;//截屏页面

@property(nonatomic,assign)NSInteger m_fromVC;

@end

NS_ASSUME_NONNULL_END
