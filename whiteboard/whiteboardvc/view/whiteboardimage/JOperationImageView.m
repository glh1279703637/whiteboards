//
//  JOperationImageView.m
//  MZCloudClass
//
//  Created by 123 on 2018/3/8.
//  Copyright © 2018年 Jeffrey. All rights reserved.
//

#import "JOperationImageView.h"
#import "JMeetingRolesManager.h"
@interface JOperationImageView()

@end
@implementation JOperationImageView
-(id)initWithFrame:(CGRect)frame{
    if(self =[super initWithFrame:frame]){
        [self funj_addBaseImageViews];
    }
    return self;
}
-(void)funj_addBaseImageViews{
    self.hidden = YES;
     self.backgroundColor = COLOR_CREAR;
    [self funj_setViewShadowLayer];
    UIImageView *bgImageView =[UIImageView funj_getImageView:self.bounds bgColor:COLOR_WHITE_DARK];
    [self addSubview:bgImageView];
    bgImageView.layer.cornerRadius = 8;
    bgImageView.layer.masksToBounds = YES;
    
    
    NSArray *imageArr = @[@"whiteboard_image_copy_n",@"whiteboard_image_reset_n2",@"whiteboard_image_delete_n"];
    for(int i =0;i<imageArr.count;i++){
        UIButton *itemBt =[UIButton funj_getButtons:CGRectMake(i*55, 0, 55, 40) :nil  :JTextFCZero() :@[imageArr[i]] :self  :@"funj_selectOperationTo:" :10+i :nil];
        [self addSubview:itemBt];
    }
 
 }
-(void)funj_selectOperationTo:(UIButton*)sender{
    if(self.m_delegate){
        switch (sender.tag) {
            case 10:[self.m_delegate funj_selectCopyImageViewActions];break;
            case 11:[self.m_delegate funj_selectChangeImageViewActions];break;
            case 12:[self.m_delegate funj_selectDeleteImageViewActions];break;
            default:
                break;
        }
    }
}
-(void)funj_changeItSuperViewsFrames:(UIImageView*)bgView{
     float point_x[4] = {0}, point_y[4] = {0};
     NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for(int i=0;i<4;i++){
        UIImageView *pointViews =[bgView viewWithTag:4000+i];
        CGPoint point = [bgView convertPoint:pointViews.frame.origin toView:bgView.superview];
        point_x[i] = point.x;point_y[i] = point.y;
        [dic setValue:@(i) forKey:[NSString stringWithFormat:@"%.3f",point.y]];
     }
    CGFloat max1 = MAX(MAX( MAX(point_y[0], point_y[1]),point_y[2]),point_y[3]);
    int index = [[dic objectForKey:[NSString stringWithFormat:@"%.3f",max1]]intValue];
    point_y[index] = -10000;
    CGFloat max2 = MAX(MAX( MAX(point_y[0], point_y[1]),point_y[2]),point_y[3]);
    int index2 = [[dic objectForKey:[NSString stringWithFormat:@"%.3f",max2]]intValue];
    
    if(point_x[index] >= point_x[index2]){
        self.left = point_x[index]-self.width;
    }else{
        self.left = point_x[index];
    }
    self.top = max1;
    UIScrollView *superView = (UIScrollView* )bgView.superview;
    CGFloat maxHeight = superView.height;
    if([superView isKindOfClass:[UIScrollView class]]){
        maxHeight = MAX(superView.height, superView.contentSize.height);
    }
    
    if(self.top > maxHeight-self.height){
        self.top =maxHeight-self.height;
    }else if(self.top <=0){
        self.top = 0;
    }
    if(self.left > kSelfWhiteBoardDrawWidth(self.m_fromVC)-self.width){
          self.left = kSelfWhiteBoardDrawWidth(self.m_fromVC) - self.width;
    }else if(self.left < 0){
        self.left = 0;
    }
}


@end
