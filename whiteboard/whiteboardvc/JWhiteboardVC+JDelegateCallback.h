//
//  JWhiteboardVC+JDelegateCallback.h
//  8OrangeCloud
//
//  Created by Jeffrey on 2020/7/2.
//  Copyright © 2020 Jeffery. All rights reserved.
//

#import "JWhiteboardVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface JWhiteboardVC (JDelegateCallback)
//操作回调 全体事件 处理
-(NSInteger)funj_selectBottomItemToolAction:(UIButton*)sender s:(NSInteger)upSelected;
@end

NS_ASSUME_NONNULL_END
