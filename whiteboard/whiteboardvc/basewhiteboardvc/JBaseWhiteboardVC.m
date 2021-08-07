//
//  JBaseWhiteboardVC.m
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/6/30.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JBaseWhiteboardVC.h"


@interface JBaseWhiteboardVC ()<JBottomPenBgViewDelegate,JWhiteboardBgViewDelegate>
@end

@implementation JBaseWhiteboardVC
-(JBottomPenBgView*)m_bottomPenBgView{
    if(!_m_bottomPenBgView){
        _m_bottomPenBgView =[[JBottomPenBgView alloc]init];
        CGRect frame = CGRectMake(0, KHeight - 50, KWidth , 50);
        _m_bottomBgView =[[JBottomBgView alloc]initWithFrame:frame];
        _m_bottomBgView.m_leftPoint = self.m_bottomPenBgView.right;
        _m_bottomBgView.m_delegate =self;_m_bottomPenBgView.m_delegate = self;
        [self.view addSubview:_m_bottomBgView];
        [self.view addSubview:_m_bottomPenBgView];
    }
    return _m_bottomPenBgView;
}
-(JScreenShotView*)m_screenShotView{
    if(!_m_screenShotView){
        _m_screenShotView =[[JScreenShotView alloc]initWithFrame:CGRectMake(0, 0, KWidth, KHeight)];
        [self.view.superview addSubview:_m_screenShotView];
    }
    return _m_screenShotView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.m_fromVC = 1;

    
    if(![JWhiteboardConfig share].m_isManager){
        UIImageView *bgImageView =[UIImageView funj_getImageView:self.view.bounds image:@"whiteboard_bg_icon"];
        bgImageView.alpha = 0.5;bgImageView.tag = 3821;
        [self.view addSubview:bgImageView];
    }
    [self funj_addWhiteboardContentSubViews];
    self.m_bottomPenBgView.hidden = NO;
}
/**
 Description
 *imagebgview 是图片处理类
 *whiteboard是白板处理类
 */
-(void)funj_addWhiteboardContentSubViews{
    CGFloat left = kLandscapeStatusWidthInIPhonex+!IS_IPAD*45;
    CGFloat left2 = (kSelfWhiteBoardDrawWidth(self.m_fromVC)-kWhiteBoardDrawWidth(self.m_fromVC))/2;
    
    if(![JWhiteboardConfig share].m_isManager  && !IS_IPAD && [JWhiteboardConfig share].m_interaction == 0){
        CGFloat right = KWidth - left - kWhiteBoardDrawWidth(self.m_fromVC);
        if(right <  kWhiteBoardCameraWidth){
            left2 -= (kWhiteBoardCameraWidth - right);
        }
        left += MAX(0, left2);
    }else{
        left += left2;
    }
    CGRect rect = CGRectMake(left, (kSelfWhiteBoardDrawHeight(self.m_fromVC)-kWhiteBoardDrawHeight(self.m_fromVC))/2, kWhiteBoardDrawWidth(self.m_fromVC), kWhiteBoardDrawHeight(self.m_fromVC));
 
    _m_whiteboardBgSubView =[[JWhiteboardBgView alloc] initWithFrame:rect];
    _m_whiteboardBgSubView.m_delegate = self;
    _m_whiteboardBgSubView.backgroundColor = COLOR_WHITE_DARK;
    [self.view addSubview:_m_whiteboardBgSubView];
    
    JWhiteBoardPPTView *pptBgView =[[JWhiteBoardPPTView alloc]init];
    pptBgView.view.frame = CGRectMake(0, 0, kWhiteBoardDrawWidth(self.m_fromVC), kWhiteBoardDrawHeight(self.m_fromVC));
     [self addChildViewController:pptBgView];
    self.m_PPTBgView=pptBgView;
    [self.m_whiteboardBgSubView addSubview:self.m_PPTBgView.view];
 
    JWhiteBoardImageView *imageBgView =[[JWhiteBoardImageView alloc]initWithFrame:CGRectMake(0, 0, kWhiteBoardDrawWidth(self.m_fromVC), kWhiteBoardDrawHeight(self.m_fromVC)) f:self.m_fromVC];
    self.m_imageBgView=imageBgView;
    [self.m_whiteboardBgSubView addSubview:self.m_imageBgView];
    
    JWhiteBoardView* whiteBoardView =[[JWhiteBoardView alloc]initWithFrame:CGRectMake(0, 0, kWhiteBoardDrawWidth(self.m_fromVC), kWhiteBoardDrawHeight(self.m_fromVC)) : self.m_fromVC];
    self.m_whiteBoardView = whiteBoardView;
    [self.m_whiteboardBgSubView addSubview:self.m_whiteBoardView];
    
    self.m_whiteboardBgSubView.m_PPTBgView = self.m_PPTBgView.view;
    self.m_whiteboardBgSubView.m_imageBgView = self.m_imageBgView;
    self.m_whiteboardBgSubView.m_whiteBoardView = self.m_whiteBoardView;
    
    if([JWhiteboardConfig share].m_isManager || [JWhiteboardConfig share].m_isAssistant)self.m_whiteboardBgSubView.m_canUserInerfaceLayer = kuserIsWhiteboardLayer;
    
}
-(void)funj_clickBackButton:(UIButton *)sender{
    [self.m_whiteBoardView funj_deallocViews];
}

@end
