//
//  JOperationImageView.h
//  MZCloudClass
//
//  Created by 123 on 2018/3/8.
//  Copyright © 2018年 Jeffrey. All rights reserved.
//

#import "JBaseView.h"

@protocol JOperationImageViewDelegate <NSObject>
@optional
-(void)funj_selectCopyImageViewActions;//复制
-(void)funj_selectChangeImageViewActions;//还原大小位置
-(void)funj_selectDeleteImageViewActions;//删除

@end
//图片操作view
@interface JOperationImageView : JBaseView
 @property(nonatomic,weak)id<JOperationImageViewDelegate>m_delegate;
@property(nonatomic,assign)NSInteger m_fromVC;
//点击不同图片是切换 其bgview
-(void)funj_changeItSuperViewsFrames:(UIImageView*)bgView;
@end
