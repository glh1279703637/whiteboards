//
//  JWhiteBoardImageView+JOperationImageView.h
//  MZCloudClass
//
//  Created by 123 on 2016/12/29.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JWhiteBoardImageView.h"
#import "JLineModel.h"
@interface JWhiteBoardImageView (JOperationImageView)

-(void)funj_addDefaultImageView;
//加载新图片
-(UIImageView*)funj_reloadToAddImageViews:(UIImage*)image :(CGSize)size :(BOOL)isNeedSysch :(NSDictionary*)dataUrl;
-(BOOL)funj_modifyToChangeImagePostion:(NSString*)keyId :(NSString*)page :(CGAffineTransform)t;
//通过网络请求图片 加载新图片
-(UIImageView*)funj_reloadToRequestImage:(NSString*)url :(NSString*)fileId :(NSString*)keyId :(CGSize)size :(CGAffineTransform)t :(NSString*)page :(NSString*)userId;
//点击按钮时默认 是选中其中一张图片
-(void)funj_startToTouchImageViewWithChangeBt;
-(void)funj_startToTouchImageView:(UIImageView*)imageView;
//set imageview is current operation view
-(void)funj_changeDefaultSubViewsFrames:(UIImageView*)imageView;

// change new subview with ppt page
-(void)funj_changePageToReloadCurrentImage:(NSString*)page;
//刷新所有图片对象
-(void)funj_reloadToChangeAllPageIndex:(NSDictionary*)changeDic;
//翻页之后刷新当前图片显示
-(void)funj_changeQuestionPageToReloadCurrentImage:(NSString*)page;

@end
