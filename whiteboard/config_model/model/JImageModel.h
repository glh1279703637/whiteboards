//
//  JImageModel.h
//  8OrangeCloud
//
//  Created by 123 on 2017/1/11.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JBaseDataModel.h"
#import <UIKit/UIKit.h>
#import "JMeetingControlAttachment.h"
@interface JImageModel : JBaseDataModel

//唯一标志
@property(nonatomic,copy)NSString *keyId;
//图片对象
@property(nonatomic,copy)NSString *fileId;
//图片在网络中的绝对路径
//@property(nonatomic,copy)NSString* fullUrl;

// 图片是否可以操作
//@property(nonatomic,assign)BOOL isCanOperation;
//原始长宽
@property(nonatomic,assign)CGFloat m_width,m_height;
//图片对象
@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,copy)NSString *ower;

@property(nonatomic,copy)NSString *page;

@end
