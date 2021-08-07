//
//  JWhiteBoardImageView.h
//  MZCloudClass
//
//  Created by 123 on 2016/12/19.
//  Copyright © 2016年 Jeffrey. All rights reserved.
//

#import "JBaseView.h"
#import "JWhiteboardCmdHandle.h"
#import "JLoginUserMessage.h"
#import "JImageModel.h"
#import "JOperationImageView.h"
#import "JWhiteboardConfig.h"
 
@interface JWhiteBoardImageView : UIScrollView<JWhiteboardCmdHandleDelegate,JOperationImageViewDelegate>
//操作图片
@property(nonatomic,strong)UIImageView *m_handleImageView;
@property(nonatomic,strong)JOperationImageView *m_handleBgImageView;//操作图片bgview
@property(nonatomic,assign)NSInteger m_fromVC; //来源，白板 还是试题白板

//保存当前操作图片对象
 @property(nonatomic,copy)NSString *m_currentPage;//当前页码
@property(nonatomic,strong)NSMutableArray *m_saveImageItemArr;//当前页 对应的图片组
 @property(nonatomic,strong)NSMutableDictionary *m_saveAllImageItemInfoDic; //所有的图片

@property(nonatomic,assign)BOOL m_isNotNeedSycToOther; //是否需要同步给老师或者其他用户，试题中操作不需要同步给老师或者其他学生
 
//操作
@property(nonatomic,strong)UIImageView *m_copyImage,*m_deleteImage,*m_defaultImage;
-(id)initWithFrame:(CGRect)frame f:(NSInteger)from;
//删除图片
 -(void)funj_deleteOneImageView:(NSString*)page :(NSString*)userId :(NSString*)key;
-(NSArray*)funj_deleteSomePageAllImageView:(NSString*)page :(NSString*)userId;
-(void)funj_deleteAllImageFrom:(NSString*)page;
-(void)funj_deleteSomePageImagesView:(NSString*)page :(NSString*)idkeys;
@end
