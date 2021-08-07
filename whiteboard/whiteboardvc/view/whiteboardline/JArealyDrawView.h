//
//  JArealyDrawView.h
//  DevelopArchitecture
//
//  Created by 123 on 2017/5/11.
//  Copyright © 2017年 Jeffrey. All rights reserved.
//

#import "JBaseView.h"
@class JWhiteBoardView;
@class JLineModel;

@interface JArealyDrawView : JBaseView

@property(nonatomic,weak)JWhiteBoardView *m_whiteboareView;
//线的全部数据保存位置
@property(nonatomic,copy)NSString *m_currentPage;
@property(nonatomic,strong)JLineModel *m_lineModel;
@property(nonatomic,assign)NSInteger m_countDrawLines;
@end
